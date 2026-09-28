#!/usr/bin/env python3
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INFO = ROOT / "bin" / "battery-info"


def put(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(str(value), encoding="utf-8")


def run_info(sysroot):
    env = os.environ.copy()
    env["BATTERY_MODE_SYSFS_ROOT"] = str(sysroot)
    out = subprocess.check_output([sys.executable, str(INFO), "--json"], env=env, text=True)
    return json.loads(out)


with tempfile.TemporaryDirectory() as td:
    s = Path(td)
    put(s / "class/dmi/id/sys_vendor", "TestVendor")
    put(s / "class/dmi/id/product_name", "TestBook")

    b0 = s / "class/power_supply/BAT0"
    put(b0 / "type", "Battery")
    put(b0 / "capacity", 77)
    put(b0 / "status", "Discharging")
    put(b0 / "cycle_count", 123)
    put(b0 / "energy_now", 42000000)
    put(b0 / "energy_full", 54000000)
    put(b0 / "energy_full_design", 60000000)
    put(b0 / "voltage_now", 12000000)
    put(b0 / "current_now", -2000000)
    put(b0 / "temp", 315)
    put(b0 / "charge_control_start_threshold", 75)
    put(b0 / "charge_control_end_threshold", 80)

    b1 = s / "class/power_supply/BAT1"
    put(b1 / "type", "Battery")
    put(b1 / "capacity", 90)
    put(b1 / "charge_full", 4000000)
    put(b1 / "charge_full_design", 5000000)
    put(b1 / "charge_control_end_threshold", 85)

    (s / "class/drm").mkdir(parents=True, exist_ok=True)
    (s / "bus/thunderbolt").mkdir(parents=True, exist_ok=True)

    d = run_info(s)
    assert d["battery_count"] == 2, d
    assert d["controllable_battery_count"] == 2, d
    assert d["support_level"] == "full", d
    assert d["primary"]["name"] == "BAT0", d
    assert d["primary"]["threshold_capability"] == "start_end", d
    assert d["primary"]["cycle_count"] == 123, d
    assert abs(d["primary"]["energy_full_wh"] - 54.0) < 0.001, d
    assert abs(d["primary"]["health_percent"] - 90.0) < 0.001, d
    assert abs(d["primary"]["temperature_c"] - 31.5) < 0.001, d
    assert abs(d["primary"]["power_w"] - 24.0) < 0.001, d
    assert d["primary"]["power_derived"] is True, d

with tempfile.TemporaryDirectory() as td:
    s = Path(td)
    b = s / "class/power_supply/BAT0"
    put(b / "type", "Battery")
    put(b / "capacity", 50)
    d = run_info(s)
    assert d["support_level"] == "status_only", d
    assert d["primary"]["threshold_capability"] == "none", d

print("battery-info self-test: PASS")
