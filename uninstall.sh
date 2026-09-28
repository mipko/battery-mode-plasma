#!/usr/bin/env bash
set -euo pipefail

PLUGIN_ID="com.mirko.x1battery"

if [[ $EUID -eq 0 ]]; then
    echo "Run ./uninstall.sh as your normal desktop user; it invokes sudo itself." >&2
    exit 1
fi

echo "Removing Battery Mode for Plasma completely..."

if [[ -x /usr/local/bin/battery-tray-unregister ]]; then
    /usr/local/bin/battery-tray-unregister >/dev/null 2>&1 || true
fi

if command -v qdbus6 >/dev/null 2>&1; then
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
fi

if command -v kpackagetool6 >/dev/null 2>&1; then
    kpackagetool6 --type Plasma/Applet --remove "$PLUGIN_ID" >/dev/null 2>&1 || true
fi

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

echo "Removed widget, System Tray registration, daemon, commands, state and settings."
