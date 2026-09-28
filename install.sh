#!/usr/bin/env bash
set -euo pipefail

PKG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_USER="${SUDO_USER:-$USER}"
INSTALL_GROUP="$(id -gn "$INSTALL_USER")"
PLUGIN_ID="com.mirko.x1battery"
RESET_SETTINGS=0

case "${1:-}" in
    "") ;;
    --reset-settings) RESET_SETTINGS=1 ;;
    -h|--help)
        echo "Usage: ./install.sh [--reset-settings]"
        echo "  default           preserve existing thresholds/mode on upgrade"
        echo "  --reset-settings  reset thresholds to defaults and mode to AUTO"
        exit 0
        ;;
    *)
        echo "Unknown option: $1" >&2
        echo "Usage: ./install.sh [--reset-settings]" >&2
        exit 2
        ;;
esac

if [[ $EUID -eq 0 ]]; then
    echo "Run ./install.sh as your normal desktop user; it invokes sudo itself." >&2
    exit 1
fi

echo "Battery Mode for Plasma v7.0.5 installer"
echo "================================================"
echo

need=(bash sudo systemctl journalctl python3 install cat tee basename kpackagetool6 qdbus6)
missing=()

for cmd in "${need[@]}"; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done

if ((${#missing[@]})); then
    echo "Missing commands: ${missing[*]}"
    echo

    if command -v pacman >/dev/null 2>&1; then
        pkgs=()

        for cmd in "${missing[@]}"; do
            case "$cmd" in
                python3) pkgs+=(python) ;;
                systemctl|journalctl) pkgs+=(systemd) ;;
                bash) pkgs+=(bash) ;;
                sudo) pkgs+=(sudo) ;;
                install|cat|tee|basename) pkgs+=(coreutils) ;;
                kpackagetool6) pkgs+=(kpackage) ;;
                qdbus6) pkgs+=(qt6-tools) ;;
            esac
        done

        mapfile -t pkgs < <(printf '%s\n' "${pkgs[@]}" | sort -u)

        echo "Installing missing Arch/CachyOS dependencies:"
        printf '  %s\n' "${pkgs[@]}"
        sudo pacman -S --needed -- "${pkgs[@]}"
    else
        echo "Automatic dependency installation is implemented only for pacman systems." >&2
        exit 1
    fi
fi

echo "Hardware capability detection:"
if ! "$PKG_DIR/bin/battery-info" --capabilities; then
    echo
    echo "ERROR: no Linux power_supply battery was found." >&2
    exit 1
fi
echo

echo "Validating packaged QML before touching the current installation..."
mapfile -t qml_files < <(find "$PKG_DIR/plasmoid/contents/ui" -maxdepth 1 -type f -name '*.qml' -print | sort)
python3 "$PKG_DIR/tools/qml_sanity.py" "${qml_files[@]}"
echo

PRESERVED_SETTINGS=""
PRESERVED_MODE="auto"

if [[ $RESET_SETTINGS -eq 0 ]]; then
    if [[ -r /var/lib/x1-battery-auto/settings.json ]]; then
        candidate_settings="$(cat /var/lib/x1-battery-auto/settings.json 2>/dev/null || true)"
        if python3 -c '''import json,sys; d=json.loads(sys.argv[1]); vals=[int(d[k]) for k in ("desk_start","desk_end","travel_start","travel_end")]; assert 0 <= vals[0] < vals[1] <= 100; assert 0 <= vals[2] < vals[3] <= 100; assert isinstance(d.get("persist_mode", False), (bool,int,str))''' "$candidate_settings" 2>/dev/null; then
            PRESERVED_SETTINGS="$candidate_settings"
            echo "Preserving existing charging thresholds/settings."
        else
            echo "Existing settings are invalid; defaults will be installed."
        fi
    fi

    if [[ -r /var/lib/x1-battery-auto/mode ]]; then
        candidate_mode="$(cat /var/lib/x1-battery-auto/mode 2>/dev/null || true)"
        case "$candidate_mode" in
            auto|desk|travel) PRESERVED_MODE="$candidate_mode" ;;
        esac
    fi
else
    echo "--reset-settings requested: factory thresholds + AUTO mode will be installed."
fi

echo

echo "Purging previous Battery Mode / X1 Battery Auto installation..."

# Remove old standalone panel/desktop instances.
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript \
'const type = "com.mirko.x1battery";
function purge(list) {
    for (let i = 0; i < list.length; ++i) {
        const widgets = list[i].widgets(type);
        for (let j = widgets.length - 1; j >= 0; --j) {
            widgets[j].remove();
        }
    }
}
purge(desktops());
purge(panels());' >/dev/null 2>&1 || true

# Remove previous registration from System Tray config if present.
if [[ -x /usr/local/bin/battery-tray-unregister ]]; then
    /usr/local/bin/battery-tray-unregister >/dev/null 2>&1 || true
else
    "$PKG_DIR/bin/battery-tray-unregister" >/dev/null 2>&1 || true
fi

# Remove old plasmoid package/files.
kpackagetool6 --type Plasma/Applet --remove "$PLUGIN_ID" >/dev/null 2>&1 || true
rm -rf "$HOME/.local/share/plasma/plasmoids/$PLUGIN_ID"

sudo systemctl disable --now x1-battery-auto.service >/dev/null 2>&1 || true

sudo rm -f \
    /usr/local/sbin/x1-battery-auto \
    /usr/local/bin/battery-auto \
    /usr/local/bin/battery-desk \
    /usr/local/bin/battery-travel \
    /usr/local/bin/battery-auto-status \
    /usr/local/bin/battery-info \
    /usr/local/bin/battery-mode \
    /usr/local/bin/battery-settings \
    /usr/local/bin/battery-tray-register \
    /usr/local/bin/battery-tray-unregister \
    /etc/systemd/system/x1-battery-auto.service \
    /etc/x1-battery-auto.conf

sudo rm -rf \
    /var/lib/x1-battery-auto \
    /usr/share/doc/x1-battery-auto \
    /usr/share/doc/battery-mode-plasma

sudo systemctl daemon-reload

echo "Installing Battery Mode for Plasma v7.0.5..."

sudo install -Dm755 "$PKG_DIR/src/x1-battery-auto.py" /usr/local/sbin/x1-battery-auto
sudo install -Dm644 "$PKG_DIR/systemd/x1-battery-auto.service" /etc/systemd/system/x1-battery-auto.service

for f in \
    battery-auto \
    battery-desk \
    battery-travel \
    battery-auto-status \
    battery-info \
    battery-mode \
    battery-settings \
    battery-tray-register \
    battery-tray-unregister
do
    sudo install -Dm755 "$PKG_DIR/bin/$f" "/usr/local/bin/$f"
done

sudo install -d -m 755 /usr/share/doc/battery-mode-plasma
sudo install -Dm644 "$PKG_DIR/README.md" /usr/share/doc/battery-mode-plasma/README.md
sudo install -Dm644 "$PKG_DIR/LICENSE" /usr/share/doc/battery-mode-plasma/LICENSE

sudo install -d -m 755 /var/lib/x1-battery-auto

printf '%s\n' "$PRESERVED_MODE" | sudo tee /var/lib/x1-battery-auto/mode >/dev/null

if [[ -n "$PRESERVED_SETTINGS" ]]; then
    printf '%s\n' "$PRESERVED_SETTINGS" \
        | sudo tee /var/lib/x1-battery-auto/settings.json >/dev/null
else
    printf '%s\n' \
    '{"desk_end":80,"desk_start":75,"persist_mode":false,"travel_end":100,"travel_start":95}' \
        | sudo tee /var/lib/x1-battery-auto/settings.json >/dev/null
fi

sudo touch /var/lib/x1-battery-auto/boot-id

sudo chown "$INSTALL_USER:$INSTALL_GROUP" \
    /var/lib/x1-battery-auto/mode \
    /var/lib/x1-battery-auto/settings.json

sudo chmod 644 \
    /var/lib/x1-battery-auto/mode \
    /var/lib/x1-battery-auto/settings.json

sudo chown root:root /var/lib/x1-battery-auto/boot-id
sudo chmod 644 /var/lib/x1-battery-auto/boot-id

sudo systemctl daemon-reload
sudo systemctl enable --now x1-battery-auto.service

echo "Installing Plasma System Tray package..."
kpackagetool6 --type Plasma/Applet --install "$PKG_DIR/plasmoid"

# Restart shell once so metadata/package discovery is unquestionably fresh.
if systemctl --user is-active --quiet plasma-plasmashell.service 2>/dev/null; then
    systemctl --user restart plasma-plasmashell.service
    sleep 2
fi

echo "Registering Battery Mode in System Tray as Always Shown..."
tray_result="$(/usr/local/bin/battery-tray-register 2>&1 || true)"
printf '%s\n' "$tray_result"

if [[ "$tray_result" == *"registered-in-trays=0"* ]]; then
    echo
    echo "WARNING: No System Tray containment was found."
    echo "The widget package is installed, but automatic tray registration could not be completed."
fi

echo
echo "Installation complete."
echo
battery-auto-status
echo
echo "System Tray integration:"
echo "  category: Hardware"
echo "  visibility: Always Shown"
echo "  plugin: $PLUGIN_ID"
echo
echo "No manual Add Widgets step is required when a System Tray is present."
