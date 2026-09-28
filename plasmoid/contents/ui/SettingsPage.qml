import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

ColumnLayout {
    id: page

    property var controller
    property bool loading: true

    spacing: Kirigami.Units.smallSpacing

    function applyFromController() {
        if (!page.controller)
            return

        page.loading = true
        deskStart.value = page.controller.deskStart
        deskEnd.value = page.controller.deskEnd
        travelStart.value = page.controller.travelStart
        travelEnd.value = page.controller.travelEnd
        persist.checked = page.controller.persistMode
        page.loading = false
    }

    function scheduleSave() {
        if (!page.loading) {
            page.controller.settingsCommandPending = true
            page.controller.settingsSaveState = "editing"
            page.controller.settingsSaveError = ""
            saveTimer.restart()
        }
    }

    Component.onCompleted: applyFromController()

    Connections {
        target: page.controller

        function onDeskStartChanged() { page.applyFromController() }
        function onDeskEndChanged() { page.applyFromController() }
        function onTravelStartChanged() { page.applyFromController() }
        function onTravelEndChanged() { page.applyFromController() }
        function onPersistModeChanged() { page.applyFromController() }
    }

    Timer {
        id: saveTimer
        interval: 450
        repeat: false

        onTriggered: {
            // START is irrelevant on STOP-only hardware, but the shared
            // settings schema still keeps a valid start < stop pair so the
            // same configuration remains portable to START+STOP machines.
            const deskStartToSave = page.controller.thresholdCapability === "end_only"
                ? Math.min(deskStart.value, deskEnd.value - 1)
                : deskStart.value
            const travelStartToSave = page.controller.thresholdCapability === "end_only"
                ? Math.min(travelStart.value, travelEnd.value - 1)
                : travelStart.value

            const valid = page.controller.thresholdCapability === "end_only"
                || (deskStart.value < deskEnd.value && travelStart.value < travelEnd.value)

            if (valid) {
                page.controller.saveSettings(
                    deskStartToSave,
                    deskEnd.value,
                    travelStartToSave,
                    travelEnd.value,
                    persist.checked
                )
            } else {
                page.controller.settingsCommandPending = false
                page.controller.settingsSaveState = "idle"
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            source: "configure"
            Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
            Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
        }

        PlasmaComponents.Label {
            text: "Battery thresholds"
            font.bold: true
            font.pointSize: Kirigami.Theme.defaultFont.pointSize + 1
        }
    }

    Kirigami.Separator {
        Layout.fillWidth: true
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: capabilityRow.implicitHeight + Kirigami.Units.largeSpacing * 2
        radius: Kirigami.Units.smallSpacing
        color: page.controller.thresholdSupported ? Qt.rgba(0.20, 0.85, 0.43, 0.045) : Qt.rgba(1, 1, 1, 0.025)
        border.width: 1
        border.color: page.controller.thresholdSupported ? Qt.rgba(0.20, 0.85, 0.43, 0.12) : Qt.rgba(1, 1, 1, 0.055)

        RowLayout {
            id: capabilityRow
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.smallSpacing
            Kirigami.Icon {
                source: page.controller.thresholdSupported ? "dialog-ok-apply" : "dialog-information"
                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
            }
            PlasmaComponents.Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                opacity: 0.74
                text: page.controller.thresholdCapability === "start_end"
                    ? "Hardware supports independent START and STOP charging thresholds."
                    : (page.controller.thresholdCapability === "end_only"
                        ? "Hardware exposes only a STOP threshold. START values are stored but battery firmware decides when charging restarts."
                        : "This machine does not expose a writable charging threshold through Linux power_supply. Battery status remains available.")
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: deskColumn.implicitHeight + Kirigami.Units.largeSpacing * 2
        radius: Kirigami.Units.smallSpacing
        color: Qt.rgba(1, 1, 1, 0.025)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.055)

        ColumnLayout {
            id: deskColumn
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true

                Rectangle {
                    width: 4
                    height: Kirigami.Units.iconSizes.smallMedium
                    radius: 2
                    color: page.controller.modeColor("desk")
                }

                Kirigami.Icon {
                    source: "video-display"
                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                }

                PlasmaComponents.Label {
                    text: "DESK mode"
                    font.bold: true
                    color: page.controller.modeColor("desk")
                }

                Item { Layout.fillWidth: true }

                QQC2.SpinBox {
                    id: deskStart
                    visible: page.controller.thresholdCapability === "start_end"
                    enabled: visible
                    from: 1
                    to: 99
                    editable: true
                    onValueModified: page.scheduleSave()
                }

                PlasmaComponents.Label {
                    text: "–"
                    visible: page.controller.thresholdCapability === "start_end"
                }

                PlasmaComponents.Label {
                    text: "Stop"
                    visible: page.controller.thresholdCapability === "end_only"
                    opacity: 0.66
                }

                QQC2.SpinBox {
                    id: deskEnd
                    enabled: page.controller.thresholdSupported
                    from: 2
                    to: 100
                    editable: true
                    onValueModified: page.scheduleSave()
                }

                PlasmaComponents.Label { text: "%" }
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                opacity: 0.66
                text: "Lower charging window for desk/docked use."
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: travelColumn.implicitHeight + Kirigami.Units.largeSpacing * 2
        radius: Kirigami.Units.smallSpacing
        color: Qt.rgba(1, 1, 1, 0.025)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.055)

        ColumnLayout {
            id: travelColumn
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true

                Rectangle {
                    width: 4
                    height: Kirigami.Units.iconSizes.smallMedium
                    radius: 2
                    color: page.controller.modeColor("travel")
                }

                Kirigami.Icon {
                    source: "go-jump"
                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                }

                PlasmaComponents.Label {
                    text: "TRAVEL mode"
                    font.bold: true
                    color: page.controller.modeColor("travel")
                }

                Item { Layout.fillWidth: true }

                QQC2.SpinBox {
                    id: travelStart
                    visible: page.controller.thresholdCapability === "start_end"
                    enabled: visible
                    from: 1
                    to: 99
                    editable: true
                    onValueModified: page.scheduleSave()
                }

                PlasmaComponents.Label {
                    text: "–"
                    visible: page.controller.thresholdCapability === "start_end"
                }

                PlasmaComponents.Label {
                    text: "Stop"
                    visible: page.controller.thresholdCapability === "end_only"
                    opacity: 0.66
                }

                QQC2.SpinBox {
                    id: travelEnd
                    enabled: page.controller.thresholdSupported
                    from: 2
                    to: 100
                    editable: true
                    onValueModified: page.scheduleSave()
                }

                PlasmaComponents.Label { text: "%" }
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                opacity: 0.66
                text: "Higher charging window for mobile use."
            }
        }
    }

    Kirigami.Separator {
        Layout.fillWidth: true
    }

    RowLayout {
        Layout.fillWidth: true

        Kirigami.Icon {
            source: "view-refresh"
            Layout.preferredWidth: Kirigami.Units.iconSizes.small
            Layout.preferredHeight: Kirigami.Units.iconSizes.small
        }

        QQC2.CheckBox {
            id: persist
            Layout.fillWidth: true
            text: "Persist selected mode across reboot"
            onToggled: page.scheduleSave()
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: page.controller.requestedMode !== "auto"

        PlasmaComponents.Label {
            Layout.fillWidth: true
            text: "Manual override is active."
            opacity: 0.66
        }

        PlasmaComponents.Button {
            text: "Switch to AUTO"
            onClicked: page.controller.runMode("battery-auto")
        }
    }

    PlasmaComponents.Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        visible: page.controller.thresholdCapability === "start_end"
            && (deskStart.value >= deskEnd.value || travelStart.value >= travelEnd.value)
        color: Kirigami.Theme.negativeTextColor
        text: "Start threshold must be lower than stop threshold."
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            visible: page.controller.settingsSaveState !== "idle"
            source: page.controller.settingsSaveState === "error"
                ? "dialog-error"
                : (page.controller.settingsSaveState === "saved"
                    ? "dialog-ok-apply"
                    : "document-save")
            Layout.preferredWidth: Kirigami.Units.iconSizes.small
            Layout.preferredHeight: Kirigami.Units.iconSizes.small
        }

        PlasmaComponents.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            opacity: page.controller.settingsSaveState === "error" ? 1.0 : 0.62
            color: page.controller.settingsSaveState === "error"
                ? Kirigami.Theme.negativeTextColor
                : Kirigami.Theme.textColor
            text: {
                if (page.controller.settingsSaveState === "editing")
                    return "Editing…"
                if (page.controller.settingsSaveState === "saving")
                    return "Saving…"
                if (page.controller.settingsSaveState === "saved")
                    return "Saved."
                if (page.controller.settingsSaveState === "error")
                    return "Save failed: " + page.controller.settingsSaveError
                return "Changes are saved automatically."
            }
        }
    }

}
