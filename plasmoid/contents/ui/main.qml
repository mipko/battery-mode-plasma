import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    Plasmoid.status: PlasmaCore.Types.ActiveStatus

    property string appVersion: "7.0.5"
    property string requestedMode: "auto"
    property string effectiveMode: "travel"
    property string modeLabel: "AUTO→TRAVEL"

    property string batteryName: ""
    property string batteryStatus: ""
    property int capacity: -1
    property int thresholdStart: -1
    property int thresholdEnd: -1
    property int expectedStart: -1
    property int expectedEnd: -1

    property bool acOnline: false
    property bool extMonitor: false
    property bool thunderbolt: false

    // Generic Linux power_supply capabilities and telemetry.
    property string thresholdCapability: "none"
    property bool thresholdSupported: false
    property string supportLevel: "status_only"
    property int batteryCount: 0
    property int controllableBatteryCount: 0

    property string systemVendor: ""
    property string systemProduct: ""
    property string systemVersion: ""

    property string batteryManufacturer: ""
    property string batteryModel: ""
    property string batterySerial: ""
    property string batteryTechnology: ""
    property string batteryHealth: ""
    property string batteryCapacityLevel: ""
    property string batteryManufactured: ""

    property int cycleCount: -1
    property real batteryHealthPercent: -1
    property real energyNowWh: -1
    property real energyFullWh: -1
    property real energyDesignWh: -1
    property real chargeNowAh: -1
    property real chargeFullAh: -1
    property real chargeDesignAh: -1
    property real voltageV: -1
    property real currentA: -999999
    property real powerW: -1
    property bool powerDerived: false
    property real temperatureC: -999999
    property int timeToEmptySec: -1
    property int timeToFullSec: -1


    property int deskStart: 75
    property int deskEnd: 80
    property int travelStart: 95
    property int travelEnd: 100
    property bool persistMode: false

    property bool syncingSettings: false
    property bool settingsCommandPending: false
    property string settingsSaveState: "idle"
    property string settingsSaveError: ""

    function modeIconSource(mode) {
        if (mode === "desk")
            return Qt.resolvedUrl("../images/battery-desk.png")
        if (mode === "travel")
            return Qt.resolvedUrl("../images/battery-travel.png")
        return Qt.resolvedUrl("../images/battery-auto.png")
    }

    function stateIconSource() {
        return modeIconSource(requestedMode)
    }

    function modeColor(mode) {
        if (mode === "auto")
            return "#55d77a"
        if (mode === "desk")
            return "#58b9ed"
        return "#f0c74e"
    }

    toolTipMainText: "Battery Mode: " + modeLabel
    toolTipSubText: {
        let pieces = []
        if (capacity >= 0)
            pieces.push(capacity + "%")
        if (thresholdStart >= 0 && thresholdEnd >= 0)
            pieces.push("charge " + thresholdStart + "–" + thresholdEnd + "%")
        pieces.push(acOnline ? "AC" : "battery")
        if (extMonitor)
            pieces.push("external display")
        if (thunderbolt)
            pieces.push("Thunderbolt/USB4")
        return pieces.join(" · ")
    }

    function consumeStatus(stdoutText) {
        try {
            const d = JSON.parse(stdoutText.trim())
            requestedMode = d.requested || "auto"
            effectiveMode = d.effective || "travel"
            modeLabel = d.label || "AUTO→TRAVEL"

            batteryName = d.battery || ""
            batteryStatus = d.status || ""

            capacity = d.capacity === null ? -1 : d.capacity
            thresholdStart = d.start === null ? -1 : d.start
            thresholdEnd = d.end === null ? -1 : d.end
            expectedStart = d.expected_start === null ? -1 : d.expected_start
            expectedEnd = d.expected_end === null ? -1 : d.expected_end

            acOnline = !!d.ac
            extMonitor = !!d.external_monitor
            thunderbolt = !!d.thunderbolt
            thresholdCapability = d.threshold_capability || thresholdCapability
            thresholdSupported = !!d.threshold_supported
        } catch (e) {
            console.log("Battery Mode: cannot parse mode status:", e)
        }
    }

    function consumeBatteryInfo(stdoutText) {
        try {
            const d = JSON.parse(stdoutText.trim())
            const b = d.primary || {}
            const s = d.system || {}

            supportLevel = d.support_level || "status_only"
            batteryCount = d.battery_count || 0
            controllableBatteryCount = d.controllable_battery_count || 0
            systemVendor = s.vendor || ""
            systemProduct = s.product || ""
            systemVersion = s.version || ""

            batteryName = b.name || batteryName
            batteryStatus = b.status || batteryStatus
            capacity = b.capacity === null || b.capacity === undefined ? capacity : b.capacity
            thresholdCapability = b.threshold_capability || "none"
            thresholdSupported = thresholdCapability !== "none"
            thresholdStart = b.threshold_start === null || b.threshold_start === undefined ? -1 : b.threshold_start
            thresholdEnd = b.threshold_end === null || b.threshold_end === undefined ? -1 : b.threshold_end

            batteryManufacturer = b.manufacturer || ""
            batteryModel = b.model_name || ""
            batterySerial = b.serial_number || ""
            batteryTechnology = b.technology || ""
            batteryHealth = b.health || ""
            batteryCapacityLevel = b.capacity_level || ""
            batteryManufactured = b.manufactured || ""
            cycleCount = b.cycle_count === null || b.cycle_count === undefined ? -1 : b.cycle_count
            batteryHealthPercent = b.health_percent === null || b.health_percent === undefined ? -1 : b.health_percent
            energyNowWh = b.energy_now_wh === null || b.energy_now_wh === undefined ? -1 : b.energy_now_wh
            energyFullWh = b.energy_full_wh === null || b.energy_full_wh === undefined ? -1 : b.energy_full_wh
            energyDesignWh = b.energy_full_design_wh === null || b.energy_full_design_wh === undefined ? -1 : b.energy_full_design_wh
            chargeNowAh = b.charge_now_ah === null || b.charge_now_ah === undefined ? -1 : b.charge_now_ah
            chargeFullAh = b.charge_full_ah === null || b.charge_full_ah === undefined ? -1 : b.charge_full_ah
            chargeDesignAh = b.charge_full_design_ah === null || b.charge_full_design_ah === undefined ? -1 : b.charge_full_design_ah
            voltageV = b.voltage_v === null || b.voltage_v === undefined ? -1 : b.voltage_v
            currentA = b.current_a === null || b.current_a === undefined ? -999999 : b.current_a
            powerW = b.power_w === null || b.power_w === undefined ? -1 : b.power_w
            powerDerived = !!b.power_derived
            temperatureC = b.temperature_c === null || b.temperature_c === undefined ? -999999 : b.temperature_c
            timeToEmptySec = b.time_to_empty_s === null || b.time_to_empty_s === undefined ? -1 : b.time_to_empty_s
            timeToFullSec = b.time_to_full_s === null || b.time_to_full_s === undefined ? -1 : b.time_to_full_s
        } catch (e) {
            console.log("Battery Mode: cannot parse battery telemetry:", e)
        }
    }

    function consumeSettings(stdoutText) {
        try {
            const d = JSON.parse(stdoutText.trim())

            deskStart = d.desk_start
            deskEnd = d.desk_end
            travelStart = d.travel_start
            travelEnd = d.travel_end
            persistMode = !!d.persist_mode

            syncingSettings = true
            if (plasmoid.configuration.deskStart !== deskStart)
                plasmoid.configuration.deskStart = deskStart
            if (plasmoid.configuration.deskEnd !== deskEnd)
                plasmoid.configuration.deskEnd = deskEnd
            if (plasmoid.configuration.travelStart !== travelStart)
                plasmoid.configuration.travelStart = travelStart
            if (plasmoid.configuration.travelEnd !== travelEnd)
                plasmoid.configuration.travelEnd = travelEnd
            if (plasmoid.configuration.persistMode !== persistMode)
                plasmoid.configuration.persistMode = persistMode
            syncingSettings = false
        } catch (e) {
            syncingSettings = false
            console.log("Battery Mode: cannot parse settings:", e)
        }
    }

    function formatTime(seconds) {
        if (seconds === undefined || seconds === null || seconds < 0)
            return "—"
        const h = Math.floor(seconds / 3600)
        const m = Math.floor((seconds % 3600) / 60)
        return h > 0 ? h + "h " + (m < 10 ? "0" + m : m) + "m" : m + "m"
    }

    function thresholdCapabilityText() {
        if (thresholdCapability === "start_end")
            return "START + STOP"
        if (thresholdCapability === "end_only")
            return "STOP only"
        return "Status only"
    }

    function runMode(command) {
        commandSource.connectSource("/usr/local/bin/" + command)
    }

    function saveSettings(ds, de, ts, te, persist) {
        const persistArg = persist ? "true" : "false"
        const command =
            "/usr/local/bin/battery-settings set-all "
            + ds + " " + de + " " + ts + " " + te + " " + persistArg

        // Protect the in-flight edit from the 1-second settings poll.
        settingsCommandPending = true
        settingsSaveState = "saving"
        settingsSaveError = ""

        // Optimistic local state keeps tooltips/config UI aligned with what
        // the user just selected while the tiny helper process commits it.
        deskStart = ds
        deskEnd = de
        travelStart = ts
        travelEnd = te
        persistMode = persist

        settingsCommandSource.connectSource(command)
    }

    function requestKConfigPush() {
        if (syncingSettings)
            return
        kconfigPushTimer.restart()
    }

    Connections {
        target: plasmoid.configuration
        function onDeskStartChanged() { root.requestKConfigPush() }
        function onDeskEndChanged() { root.requestKConfigPush() }
        function onTravelStartChanged() { root.requestKConfigPush() }
        function onTravelEndChanged() { root.requestKConfigPush() }
        function onPersistModeChanged() { root.requestKConfigPush() }
    }

    Timer {
        id: kconfigPushTimer
        interval: 350
        repeat: false
        onTriggered: {
            if (root.syncingSettings)
                return

            root.saveSettings(
                plasmoid.configuration.deskStart,
                plasmoid.configuration.deskEnd,
                plasmoid.configuration.travelStart,
                plasmoid.configuration.travelEnd,
                plasmoid.configuration.persistMode
            )
        }
    }

    Plasma5Support.DataSource {
        id: statusSource
        engine: "executable"
        connectedSources: ["/usr/local/bin/battery-mode --json"]
        interval: 1000

        onNewData: function(sourceName, data) {
            if (data["stdout"] !== undefined)
                root.consumeStatus(data["stdout"])
        }
    }

    Plasma5Support.DataSource {
        id: settingsSource
        engine: "executable"
        connectedSources: ["/usr/local/bin/battery-settings --json"]
        interval: 1000

        onNewData: function(sourceName, data) {
            // Never overwrite values while an edit/save is in flight.
            if (!root.settingsCommandPending && data["stdout"] !== undefined)
                root.consumeSettings(data["stdout"])
        }
    }

    Plasma5Support.DataSource {
        id: batteryInfoSource
        engine: "executable"
        connectedSources: ["/usr/local/bin/battery-info --json"]
        interval: 2000

        onNewData: function(sourceName, data) {
            if (data["stdout"] !== undefined)
                root.consumeBatteryInfo(data["stdout"])
        }
    }

    Plasma5Support.DataSource {
        id: commandSource
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)
            statusRefreshTimer.restart()
        }
    }

    Plasma5Support.DataSource {
        id: settingsCommandSource
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)

            const out = data["stdout"] !== undefined ? data["stdout"].trim() : ""
            const err = data["stderr"] !== undefined ? data["stderr"].trim() : ""

            if (out.length > 0) {
                root.consumeSettings(out)
                root.settingsSaveState = "saved"
                root.settingsSaveError = ""
            } else {
                root.settingsSaveState = "error"
                root.settingsSaveError = err.length > 0 ? err : "Could not save settings."
            }

            root.settingsCommandPending = false
            settingsRefreshTimer.restart()
            statusRefreshTimer.restart()
            settingsSavedClearTimer.restart()
        }
    }

    Timer {
        id: settingsSavedClearTimer
        interval: 2200
        repeat: false
        onTriggered: {
            if (root.settingsSaveState === "saved")
                root.settingsSaveState = "idle"
        }
    }

    Timer {
        id: statusRefreshTimer
        interval: 350
        repeat: false

        onTriggered: {
            statusSource.disconnectSource("/usr/local/bin/battery-mode --json")
            statusSource.connectSource("/usr/local/bin/battery-mode --json")
        }
    }

    Timer {
        id: settingsRefreshTimer
        interval: 350
        repeat: false

        onTriggered: {
            settingsSource.disconnectSource("/usr/local/bin/battery-settings --json")
            settingsSource.connectSource("/usr/local/bin/battery-settings --json")
        }
    }

    compactRepresentation: MouseArea {
        id: compact

        property bool wasPopupVisible: false

        implicitWidth: Kirigami.Units.iconSizes.smallMedium
        implicitHeight: implicitWidth

        Layout.minimumWidth: 1
        Layout.minimumHeight: 1
        Layout.preferredWidth: implicitWidth
        Layout.preferredHeight: implicitHeight
        Layout.fillWidth: true
        Layout.fillHeight: true

        acceptedButtons: Qt.LeftButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        // Plasma's System Tray wrapper forwards press/click to this MouseArea.
        // We deliberately do NOT toggle root.expanded: doing that would invoke
        // the System Tray's own 24x24-grid minimum popup.
        onPressed: wasPopupVisible = customPopup.visible
        onClicked: customPopup.visible = !wasPopupVisible

        Image {
            anchors.fill: parent
            anchors.margins: 0
            fillMode: Image.PreserveAspectFit
            source: root.stateIconSource()
            smooth: true
            mipmap: true
        }
    }

    PlasmaCore.AppletPopup {
        id: customPopup

        objectName: "x1BatteryPopup"

        // KDE System Tray reparents the whole child applet (root) into its
        // real iconContainer. Anchor to that container so Wayland placement
        // uses the actual tray cell on the panel.
        // Before reparenting, use root: compact is scoped to its Component.
        visualParent: root.parent ? root.parent : root

        popupDirection: switch (Plasmoid.location) {
            case PlasmaCore.Types.TopEdge:
                return Qt.BottomEdge
            case PlasmaCore.Types.LeftEdge:
                return Qt.RightEdge
            case PlasmaCore.Types.RightEdge:
                return Qt.LeftEdge
            default:
                return Qt.TopEdge
        }

        hideOnWindowDeactivate: true
        animated: true
        floating: false
        margin: 0

        onVisibleChanged: {
            if (visible) {
                popupSurface.forceActiveFocus()
            } else {
                popupSurface.currentPage = 0
            }
        }

        mainItem: PopupSurface {
            id: popupSurface
            controller: root

            onRequestClose: customPopup.visible = false
        }
    }

    // Kept for Plasma's applet contract / keyboard activation fallback.
    // Normal tray left-click uses customPopup above.
    fullRepresentation: FullRepresentation {
        controller: root
    }
}
