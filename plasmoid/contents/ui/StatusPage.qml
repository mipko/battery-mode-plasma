import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

ColumnLayout {
    id: page
    property var controller
    spacing: Kirigami.Units.smallSpacing

    function absReal(v) { return v < 0 ? -v : v }

    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            source: "view-statistics"
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            PlasmaComponents.Label {
                text: "Battery status"
                font.bold: true
                font.pointSize: Kirigami.Theme.defaultFont.pointSize + 1
            }
            PlasmaComponents.Label {
                text: page.controller.systemVendor.length > 0 || page.controller.systemProduct.length > 0
                    ? (page.controller.systemVendor + " " + page.controller.systemProduct).trim()
                    : "Linux power_supply"
                opacity: 0.58
                font.pointSize: Kirigami.Theme.smallFont.pointSize
            }
        }

        Rectangle {
            implicitWidth: supportLabel.implicitWidth + Kirigami.Units.largeSpacing
            implicitHeight: supportLabel.implicitHeight + Kirigami.Units.smallSpacing
            radius: height / 2
            color: page.controller.thresholdSupported ? Qt.rgba(0.20, 0.85, 0.43, 0.10) : Qt.rgba(1, 1, 1, 0.045)
            border.width: 1
            border.color: page.controller.thresholdSupported ? Qt.rgba(0.20, 0.85, 0.43, 0.22) : Qt.rgba(1, 1, 1, 0.08)
            PlasmaComponents.Label {
                id: supportLabel
                anchors.centerIn: parent
                text: page.controller.thresholdCapabilityText()
                font.bold: true
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                color: page.controller.thresholdSupported ? "#55d77a" : Kirigami.Theme.textColor
            }
        }
    }

    Kirigami.Separator { Layout.fillWidth: true }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: currentGrid.implicitHeight + Kirigami.Units.largeSpacing * 2
        radius: Kirigami.Units.smallSpacing
        color: Qt.rgba(1, 1, 1, 0.025)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.055)
        GridLayout {
            id: currentGrid
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            columns: 4
            columnSpacing: Kirigami.Units.largeSpacing
            rowSpacing: Kirigami.Units.smallSpacing
            PlasmaComponents.Label { text: "Charge"; opacity: 0.60 }
            PlasmaComponents.Label { text: page.controller.capacity >= 0 ? page.controller.capacity + "%" : "—"; font.bold: true }
            PlasmaComponents.Label { text: "State"; opacity: 0.60 }
            PlasmaComponents.Label { text: page.controller.batteryStatus.length > 0 ? page.controller.batteryStatus : "—"; font.bold: true }
            PlasmaComponents.Label { text: "Requested"; opacity: 0.60 }
            PlasmaComponents.Label { text: page.controller.requestedMode.toUpperCase(); font.bold: true; color: page.controller.modeColor(page.controller.requestedMode) }
            PlasmaComponents.Label { text: "Effective"; opacity: 0.60 }
            PlasmaComponents.Label { text: page.controller.effectiveMode.toUpperCase(); font.bold: true; color: page.controller.modeColor(page.controller.effectiveMode) }
            PlasmaComponents.Label { text: "Thresholds"; opacity: 0.60 }
            PlasmaComponents.Label {
                text: page.controller.thresholdCapability === "start_end" && page.controller.thresholdStart >= 0 && page.controller.thresholdEnd >= 0
                    ? page.controller.thresholdStart + "–" + page.controller.thresholdEnd + "%"
                    : (page.controller.thresholdCapability === "end_only" && page.controller.thresholdEnd >= 0 ? "Stop " + page.controller.thresholdEnd + "%" : "—")
            }
            PlasmaComponents.Label { text: "Capacity level"; opacity: 0.60 }
            PlasmaComponents.Label { text: page.controller.batteryCapacityLevel.length > 0 ? page.controller.batteryCapacityLevel : "—" }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: healthGrid.implicitHeight + Kirigami.Units.largeSpacing * 2
        radius: Kirigami.Units.smallSpacing
        color: Qt.rgba(1, 1, 1, 0.025)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.055)
        GridLayout {
            id: healthGrid
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            columns: 4
            columnSpacing: Kirigami.Units.largeSpacing
            rowSpacing: Kirigami.Units.smallSpacing
            PlasmaComponents.Label { text: "Health (full/design)"; opacity: 0.60; visible: page.controller.batteryHealthPercent >= 0 }
            PlasmaComponents.Label { text: page.controller.batteryHealthPercent >= 0 ? page.controller.batteryHealthPercent.toFixed(1) + "%" : "—"; font.bold: true; visible: page.controller.batteryHealthPercent >= 0 }
            PlasmaComponents.Label { text: "Cycle count"; opacity: 0.60; visible: page.controller.cycleCount >= 0 }
            PlasmaComponents.Label { text: page.controller.cycleCount >= 0 ? page.controller.cycleCount : "—"; font.bold: true; visible: page.controller.cycleCount >= 0 }
            PlasmaComponents.Label { text: "Full charge"; opacity: 0.60; visible: page.controller.energyFullWh >= 0 || page.controller.chargeFullAh >= 0 }
            PlasmaComponents.Label { text: page.controller.energyFullWh >= 0 ? page.controller.energyFullWh.toFixed(2) + " Wh" : (page.controller.chargeFullAh >= 0 ? page.controller.chargeFullAh.toFixed(3) + " Ah" : "—"); visible: page.controller.energyFullWh >= 0 || page.controller.chargeFullAh >= 0 }
            PlasmaComponents.Label { text: "Design capacity"; opacity: 0.60; visible: page.controller.energyDesignWh >= 0 || page.controller.chargeDesignAh >= 0 }
            PlasmaComponents.Label { text: page.controller.energyDesignWh >= 0 ? page.controller.energyDesignWh.toFixed(2) + " Wh" : (page.controller.chargeDesignAh >= 0 ? page.controller.chargeDesignAh.toFixed(3) + " Ah" : "—"); visible: page.controller.energyDesignWh >= 0 || page.controller.chargeDesignAh >= 0 }
            PlasmaComponents.Label { text: "Stored now"; opacity: 0.60; visible: page.controller.energyNowWh >= 0 || page.controller.chargeNowAh >= 0 }
            PlasmaComponents.Label { text: page.controller.energyNowWh >= 0 ? page.controller.energyNowWh.toFixed(2) + " Wh" : (page.controller.chargeNowAh >= 0 ? page.controller.chargeNowAh.toFixed(3) + " Ah" : "—"); visible: page.controller.energyNowWh >= 0 || page.controller.chargeNowAh >= 0 }
            PlasmaComponents.Label { text: "Kernel health"; opacity: 0.60; visible: page.controller.batteryHealth.length > 0 }
            PlasmaComponents.Label { text: page.controller.batteryHealth; visible: page.controller.batteryHealth.length > 0 }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        visible: page.controller.voltageV >= 0 || page.controller.currentA > -100000 || page.controller.powerW >= 0 || page.controller.temperatureC > -100000 || page.controller.timeToEmptySec >= 0 || page.controller.timeToFullSec >= 0
        implicitHeight: electricalGrid.implicitHeight + Kirigami.Units.largeSpacing * 2
        radius: Kirigami.Units.smallSpacing
        color: Qt.rgba(1, 1, 1, 0.025)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.055)
        GridLayout {
            id: electricalGrid
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            columns: 4
            columnSpacing: Kirigami.Units.largeSpacing
            rowSpacing: Kirigami.Units.smallSpacing
            PlasmaComponents.Label { text: "Voltage"; opacity: 0.60; visible: page.controller.voltageV >= 0 }
            PlasmaComponents.Label { text: page.controller.voltageV >= 0 ? page.controller.voltageV.toFixed(2) + " V" : "—"; visible: page.controller.voltageV >= 0 }
            PlasmaComponents.Label { text: "Current"; opacity: 0.60; visible: page.controller.currentA > -100000 }
            PlasmaComponents.Label { text: page.controller.currentA > -100000 ? page.absReal(page.controller.currentA).toFixed(2) + " A" : "—"; visible: page.controller.currentA > -100000 }
            PlasmaComponents.Label { text: "Power"; opacity: 0.60; visible: page.controller.powerW >= 0 }
            PlasmaComponents.Label { text: page.controller.powerW >= 0 ? page.absReal(page.controller.powerW).toFixed(2) + " W" + (page.controller.powerDerived ? " *" : "") : "—"; visible: page.controller.powerW >= 0 }
            PlasmaComponents.Label { text: "Temperature"; opacity: 0.60; visible: page.controller.temperatureC > -100000 }
            PlasmaComponents.Label { text: page.controller.temperatureC > -100000 ? page.controller.temperatureC.toFixed(1) + " °C" : "—"; visible: page.controller.temperatureC > -100000 }
            PlasmaComponents.Label { text: "Time to empty"; opacity: 0.60; visible: page.controller.timeToEmptySec >= 0 }
            PlasmaComponents.Label { text: page.controller.formatTime(page.controller.timeToEmptySec); visible: page.controller.timeToEmptySec >= 0 }
            PlasmaComponents.Label { text: "Time to full"; opacity: 0.60; visible: page.controller.timeToFullSec >= 0 }
            PlasmaComponents.Label { text: page.controller.formatTime(page.controller.timeToFullSec); visible: page.controller.timeToFullSec >= 0 }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: identityGrid.implicitHeight + Kirigami.Units.largeSpacing * 2
        radius: Kirigami.Units.smallSpacing
        color: Qt.rgba(1, 1, 1, 0.020)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.050)
        GridLayout {
            id: identityGrid
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            columns: 4
            columnSpacing: Kirigami.Units.largeSpacing
            rowSpacing: Kirigami.Units.smallSpacing
            PlasmaComponents.Label { text: "Battery device"; opacity: 0.60 }
            PlasmaComponents.Label { text: page.controller.batteryName.length > 0 ? page.controller.batteryName : "—" }
            PlasmaComponents.Label { text: "Batteries"; opacity: 0.60 }
            PlasmaComponents.Label { text: page.controller.batteryCount > 0 ? page.controller.batteryCount + " (" + page.controller.controllableBatteryCount + " controllable)" : "—" }
            PlasmaComponents.Label { text: "Manufacturer"; opacity: 0.60; visible: page.controller.batteryManufacturer.length > 0 }
            PlasmaComponents.Label { text: page.controller.batteryManufacturer; visible: page.controller.batteryManufacturer.length > 0 }
            PlasmaComponents.Label { text: "Model"; opacity: 0.60; visible: page.controller.batteryModel.length > 0 }
            PlasmaComponents.Label { text: page.controller.batteryModel; visible: page.controller.batteryModel.length > 0 }
            PlasmaComponents.Label { text: "Technology"; opacity: 0.60; visible: page.controller.batteryTechnology.length > 0 }
            PlasmaComponents.Label { text: page.controller.batteryTechnology; visible: page.controller.batteryTechnology.length > 0 }
            PlasmaComponents.Label { text: "Serial"; opacity: 0.60; visible: page.controller.batterySerial.length > 0 }
            PlasmaComponents.Label { text: page.controller.batterySerial; visible: page.controller.batterySerial.length > 0 }
            PlasmaComponents.Label { text: "Manufactured"; opacity: 0.60; visible: page.controller.batteryManufactured.length > 0 }
            PlasmaComponents.Label { text: page.controller.batteryManufactured; visible: page.controller.batteryManufactured.length > 0 }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing
        StatusChip { Layout.fillWidth: true; Layout.minimumWidth: Kirigami.Units.gridUnit * 6.2; iconName: "battery-charging"; title: "AC"; valueText: page.controller.acOnline ? "On" : "Off"; active: page.controller.acOnline; activeColor: "#55d77a" }
        StatusChip { Layout.fillWidth: true; Layout.minimumWidth: Kirigami.Units.gridUnit * 6.2; iconName: "video-display"; title: "Display"; valueText: page.controller.extMonitor ? "Yes" : "No"; active: page.controller.extMonitor; activeColor: page.controller.modeColor("desk") }
        StatusChip { Layout.fillWidth: true; Layout.minimumWidth: Kirigami.Units.gridUnit * 6.2; iconName: "network-wired"; title: "TB/USB4"; valueText: page.controller.thunderbolt ? "Yes" : "No"; active: page.controller.thunderbolt; activeColor: page.controller.modeColor("desk") }
    }

    PlasmaComponents.Label {
        Layout.fillWidth: true
        visible: page.controller.powerDerived
        wrapMode: Text.WordWrap
        opacity: 0.50
        font.pointSize: Kirigami.Theme.smallFont.pointSize
        text: "* Power calculated from voltage × current because the driver does not expose power_now."
    }
}
