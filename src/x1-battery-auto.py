#!/usr/bin/env python3
import fcntl
import glob
import json
import os
import socket
import time

STATE_DIR = "/var/lib/x1-battery-auto"  # retained for upgrade compatibility
MODE_FILE = os.path.join(STATE_DIR, "mode")
SETTINGS_FILE = os.path.join(STATE_DIR, "settings.json")
BOOT_ID_FILE = os.path.join(STATE_DIR, "boot-id")
SYSFS_ROOT = os.environ.get("BATTERY_MODE_SYSFS_ROOT", "/sys")

VALID_MODES = {"auto", "desk", "travel"}
POLL_SECONDS = 0.25
DEFAULTS = {
    "desk_start": 75,
    "desk_end": 80,
    "travel_start": 95,
    "travel_end": 100,
    "persist_mode": False,
}


def sp(*parts):
    return os.path.join(SYSFS_ROOT, *parts)


def read_text(path, default=None):
    try:
        with open(path, "r", encoding="utf-8") as f:
            return f.read().strip()
    except OSError:
        return default


def write_text(path, value):
    with open(path, "w", encoding="utf-8") as f:
        f.write(value)


def current_boot_id():
    return read_text("/proc/sys/kernel/random/boot_id", "")


def validate_settings(raw):
    cfg = DEFAULTS.copy()
    if isinstance(raw, dict):
        for key in cfg:
            if key in raw:
                cfg[key] = raw[key]
    for key in ("desk_start", "desk_end", "travel_start", "travel_end"):
        if isinstance(cfg[key], bool):
            raise ValueError(f"{key} must be an integer")
        cfg[key] = int(cfg[key])
    persist = cfg["persist_mode"]
    if isinstance(persist, str):
        persist = persist.strip().lower() in ("1", "true", "yes", "on")
    cfg["persist_mode"] = bool(persist)
    if not (0 <= cfg["desk_start"] < cfg["desk_end"] <= 100):
        raise ValueError("DESK thresholds must satisfy 0 <= start < end <= 100")
    if not (0 <= cfg["travel_start"] < cfg["travel_end"] <= 100):
        raise ValueError("TRAVEL thresholds must satisfy 0 <= start < end <= 100")
    return cfg


def load_settings():
    try:
        with open(SETTINGS_FILE, "r", encoding="utf-8") as f:
            fcntl.flock(f.fileno(), fcntl.LOCK_SH)
            try:
                return validate_settings(json.load(f))
            finally:
                fcntl.flock(f.fileno(), fcntl.LOCK_UN)
    except (OSError, ValueError, TypeError, json.JSONDecodeError) as exc:
        print(f"battery-mode: invalid settings, using defaults: {exc}", flush=True)
        return DEFAULTS.copy()


def get_mode():
    mode = read_text(MODE_FILE, "auto")
    return mode if mode in VALID_MODES else "auto"


def handle_boot_persistence(settings):
    boot_id = current_boot_id()
    previous_boot_id = read_text(BOOT_ID_FILE, "")
    if previous_boot_id != boot_id:
        if not settings["persist_mode"]:
            write_text(MODE_FILE, "auto\n")
            print("battery-mode: new boot, persistence disabled -> mode=AUTO", flush=True)
        else:
            print(f"battery-mode: new boot, persistence enabled -> keeping mode={get_mode()}", flush=True)
        write_text(BOOT_ID_FILE, boot_id + "\n")


def threshold_paths(path):
    start = end = None
    for name in ("charge_control_start_threshold", "charge_start_threshold"):
        p = os.path.join(path, name)
        if os.path.exists(p):
            start = p
            break
    for name in ("charge_control_end_threshold", "charge_stop_threshold"):
        p = os.path.join(path, name)
        if os.path.exists(p):
            end = p
            break
    return start, end


def battery_descriptors():
    result = []
    for path in sorted(glob.glob(sp("class", "power_supply", "*"))):
        if read_text(os.path.join(path, "type")) != "Battery":
            continue
        start, end = threshold_paths(path)
        capability = "start_end" if start and end else ("end_only" if end else "none")
        result.append({"path": path, "name": os.path.basename(path), "start": start, "end": end, "capability": capability})
    return result


def ac_online():
    for p in glob.glob(sp("class", "power_supply", "*")):
        if read_text(os.path.join(p, "type")) == "Battery":
            continue
        if read_text(os.path.join(p, "online")) == "1":
            return True
    return False


def external_monitor_connected():
    for status_path in glob.glob(sp("class", "drm", "card*-*", "status")):
        connector = os.path.basename(os.path.dirname(status_path))
        if any(tag in connector for tag in ("-eDP-", "-LVDS-", "-DSI-")):
            continue
        if read_text(status_path) == "connected":
            return True
    return False


def is_external_thunderbolt_router_name(name):
    if name.startswith("domain") or "-" not in name:
        return False
    domain_text, route_text = name.split("-", 1)
    try:
        int(domain_text, 10)
        route = int(route_text, 16)
    except ValueError:
        return False
    return route != 0


def thunderbolt_device_connected():
    for p in glob.glob(sp("bus", "thunderbolt", "devices", "*")):
        name = os.path.basename(p)
        if not is_external_thunderbolt_router_name(name):
            continue
        auth = read_text(os.path.join(p, "authorized"))
        try:
            if auth is not None and int(auth) > 0:
                return True
        except ValueError:
            pass
    return False


def write_if_needed(path, value):
    if path is None or read_text(path) == str(value):
        return False
    with open(path, "w", encoding="utf-8") as f:
        f.write(str(value))
    return True


def set_thresholds(desc, start, end):
    if desc["capability"] == "none":
        return False
    if desc["capability"] == "end_only":
        return write_if_needed(desc["end"], end)

    try:
        current_start = int(read_text(desc["start"], "-1"))
    except ValueError:
        current_start = None
    try:
        current_end = int(read_text(desc["end"], "-1"))
    except ValueError:
        current_end = None

    changed = False
    # Lowering both: lower START first. Raising both: raise END first.
    if current_start is not None and end <= current_start:
        changed |= write_if_needed(desc["start"], start)
        changed |= write_if_needed(desc["end"], end)
    elif current_end is not None and start >= current_end:
        changed |= write_if_needed(desc["end"], end)
        changed |= write_if_needed(desc["start"], start)
    else:
        changed |= write_if_needed(desc["end"], end)
        changed |= write_if_needed(desc["start"], start)
    return changed


def evaluate(settings, reason):
    batteries = battery_descriptors()
    controllable = [b for b in batteries if b["capability"] != "none"]
    requested = get_mode()
    ac = ac_online()
    monitor = external_monitor_connected()
    thunderbolt = thunderbolt_device_connected()

    if requested == "desk":
        start, end, effective = settings["desk_start"], settings["desk_end"], "FORCE-DESK"
    elif requested == "travel":
        start, end, effective = settings["travel_start"], settings["travel_end"], "FORCE-TRAVEL"
    elif ac and (monitor or thunderbolt):
        start, end, effective = settings["desk_start"], settings["desk_end"], "AUTO-DESK"
    else:
        start, end, effective = settings["travel_start"], settings["travel_end"], "AUTO-TRAVEL"

    changed = 0
    errors = []
    for battery in controllable:
        try:
            changed += int(set_thresholds(battery, start, end))
        except OSError as exc:
            errors.append(f"{battery['name']}:{exc}")

    capabilities = ",".join(f"{b['name']}={b['capability']}" for b in batteries) or "none"
    print(
        "battery-mode: "
        f"requested={requested} effective={effective} ac={int(ac)} "
        f"external-monitor={int(monitor)} thunderbolt={int(thunderbolt)} "
        f"profile={start}/{end} batteries={capabilities} changed={changed} "
        f"persist={int(settings['persist_mode'])} reason={reason}"
        + (f" errors={' | '.join(errors)}" if errors else ""),
        flush=True,
    )


def file_stamp(path):
    try:
        st = os.stat(path)
        return (st.st_mtime_ns, st.st_size)
    except OSError:
        return None


def main():
    settings = load_settings()
    handle_boot_persistence(settings)
    evaluate(settings, "startup")
    last_mode_stamp = file_stamp(MODE_FILE)
    last_settings_stamp = file_stamp(SETTINGS_FILE)

    sock = socket.socket(socket.AF_NETLINK, socket.SOCK_DGRAM, 15)
    sock.bind((os.getpid(), 1))
    sock.settimeout(POLL_SECONDS)
    relevant = {"power_supply", "drm", "thunderbolt"}

    while True:
        subsystem = None
        try:
            data = sock.recv(64 * 1024)
            for field in data.decode("utf-8", errors="ignore").split("\0"):
                if field.startswith("SUBSYSTEM="):
                    subsystem = field.split("=", 1)[1]
                    break
        except socket.timeout:
            pass

        current_settings_stamp = file_stamp(SETTINGS_FILE)
        if current_settings_stamp != last_settings_stamp:
            last_settings_stamp = current_settings_stamp
            settings = load_settings()
            evaluate(settings, "settings-change")
            continue

        current_mode_stamp = file_stamp(MODE_FILE)
        if current_mode_stamp != last_mode_stamp:
            last_mode_stamp = current_mode_stamp
            evaluate(settings, "mode-change")
            continue

        if subsystem in relevant:
            time.sleep(0.5)
            evaluate(settings, subsystem)


if __name__ == "__main__":
    main()
