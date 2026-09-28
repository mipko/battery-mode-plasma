import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: page

    property var controller
    implicitWidth: Kirigami.Units.gridUnit * 21.5
    implicitHeight: overviewLayout.implicitHeight + Kirigami.Units.largeSpacing * 2

    ColumnLayout {
        id: overviewLayout
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.smallSpacing

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: summaryRow.implicitHeight + Kirigami.Units.largeSpacing * 2
            radius: Kirigami.Units.smallSpacing * 1.25
            color: Qt.rgba(1, 1, 1, 0.045)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.08)

            RowLayout {
                id: summaryRow
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                spacing: Kirigami.Units.largeSpacing

                Rectangle {
                    width: Kirigami.Units.iconSizes.large + Kirigami.Units.smallSpacing * 2
                    height: width
                    radius: Kirigami.Units.smallSpacing
                    color: Qt.rgba(1, 1, 1, 0.035)

                    Image {
                        anchors.centerIn: parent
                        width: parent.width - Kirigami.Units.smallSpacing * 2
                        height: width
                        fillMode: Image.PreserveAspectFit
                        source: page.controller.stateIconSource()
                        smooth: true
                        mipmap: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    RowLayout {
                        spacing: Kirigami.Units.smallSpacing

                        PlasmaComponents.Label {
                            visible: page.controller.requestedMode === "auto"
                            text: "AUTO"
                            font.bold: true
                            color: page.controller.modeColor("auto")
                        }

                        PlasmaComponents.Label {
                            visible: page.controller.requestedMode === "auto"
                            text: "→"
                            opacity: 0.75
                            font.bold: true
                        }

                        PlasmaComponents.Label {
                            text: page.controller.requestedMode === "auto"
                                ? page.controller.effectiveMode.toUpperCase()
                                : page.controller.requestedMode.toUpperCase()
                            font.bold: true
                            color: page.controller.requestedMode === "auto"
                                ? page.controller.modeColor(page.controller.effectiveMode)
                                : page.controller.modeColor(page.controller.requestedMode)
                        }
                    }

                    PlasmaComponents.Label {
                        text: page.controller.requestedMode === "auto"
                            ? "Automatic charging policy"
                            : "Manual override"
                        opacity: 0.62
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    spacing: 0

                    PlasmaComponents.Label {
                        Layout.alignment: Qt.AlignRight
                        text: page.controller.capacity >= 0
                            ? page.controller.capacity + "%"
                            : "—"
                        font.bold: true
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize + 2
                    }

                    PlasmaComponents.Label {
                        Layout.alignment: Qt.AlignRight
                        text: page.controller.thresholdStart >= 0 && page.controller.thresholdEnd >= 0
                            ? page.controller.thresholdStart + "–" + page.controller.thresholdEnd + "%"
                            : "—"
                        opacity: 0.66
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                    }
                }

            }
        }

        Item {
            Layout.fillHeight: true
            Layout.minimumHeight: Kirigami.Units.smallSpacing
            Layout.preferredHeight: Kirigami.Units.largeSpacing
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            ModeButton {
                modeName: "AUTO"
                iconSource: page.controller.modeIconSource("auto")
                checked: page.controller.requestedMode === "auto"
                controlEnabled: page.controller.thresholdSupported
                description: page.controller.thresholdCapability === "end_only"
                    ? "Automatic selection of the DESK or TRAVEL stop threshold. Hardware controls charging restart."
                    : "Automatic selection: DESK when AC is connected and an external display or real TB/USB4 device is present; otherwise TRAVEL."
                onClicked: page.controller.runMode("battery-auto")
            }

            ModeButton {
                modeName: "DESK"
                iconSource: page.controller.modeIconSource("desk")
                checked: page.controller.requestedMode === "desk"
                controlEnabled: page.controller.thresholdSupported
                description: page.controller.thresholdCapability === "end_only"
                    ? "Manual DESK stop threshold: " + page.controller.deskEnd + "%. Hardware controls charging restart."
                    : "Manual DESK mode. Charging window: "
                        + page.controller.deskStart + "–" + page.controller.deskEnd
                        + "%. Best for desk/docked use."
                onClicked: page.controller.runMode("battery-desk")
            }

            ModeButton {
                modeName: "TRAVEL"
                iconSource: page.controller.modeIconSource("travel")
                checked: page.controller.requestedMode === "travel"
                controlEnabled: page.controller.thresholdSupported
                description: page.controller.thresholdCapability === "end_only"
                    ? "Manual TRAVEL stop threshold: " + page.controller.travelEnd + "%. Hardware controls charging restart."
                    : "Manual TRAVEL mode. Charging window: "
                        + page.controller.travelStart + "–" + page.controller.travelEnd
                        + "%. Keeps the battery close to full for mobile use."
                onClicked: page.controller.runMode("battery-travel")
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.minimumHeight: Kirigami.Units.smallSpacing
            Layout.preferredHeight: Kirigami.Units.largeSpacing
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            StatusChip {
                Layout.fillWidth: true
                Layout.minimumWidth: Kirigami.Units.gridUnit * 6.2
                iconName: "battery-charging"
                title: "AC"
                valueText: page.controller.acOnline ? "On" : "Off"
                active: page.controller.acOnline
                activeColor: "#55d77a"
            }

            StatusChip {
                Layout.fillWidth: true
                Layout.minimumWidth: Kirigami.Units.gridUnit * 6.2
                iconName: "video-display"
                title: "Display"
                valueText: page.controller.extMonitor ? "Yes" : "No"
                active: page.controller.extMonitor
                activeColor: page.controller.modeColor("desk")
            }

            StatusChip {
                Layout.fillWidth: true
                Layout.minimumWidth: Kirigami.Units.gridUnit * 6.2
                iconName: "network-wired"
                title: "TB/USB4"
                valueText: page.controller.thunderbolt ? "Yes" : "No"
                active: page.controller.thunderbolt
                activeColor: page.controller.modeColor("desk")
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.minimumHeight: Kirigami.Units.smallSpacing
            Layout.preferredHeight: Kirigami.Units.largeSpacing
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: hintRow.implicitHeight + Kirigami.Units.smallSpacing * 2
            radius: Kirigami.Units.smallSpacing
            color: Qt.rgba(1, 1, 1, 0.025)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.055)

            RowLayout {
                id: hintRow
                anchors.fill: parent
                anchors.leftMargin: Kirigami.Units.smallSpacing
                anchors.rightMargin: Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    source: "dialog-information"
                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                    opacity: 0.7
                }

                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    text: !page.controller.thresholdSupported
                        ? "Status-only hardware · charging thresholds are not exposed by the kernel driver"
                        : (page.controller.thresholdCapability === "end_only"
                            ? "STOP-only hardware · AUTO switches the stop limit between DESK and TRAVEL"
                            : (page.controller.requestedMode === "auto"
                                ? "AUTO: AC + external display/TB → DESK · otherwise TRAVEL"
                                : "Manual override is active · switch to AUTO for automatic selection"))
                    elide: Text.ElideRight
                    opacity: 0.72
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                }

            }
        }

    }
}
