import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

ColumnLayout {
    id: page

    property var controller

    spacing: Kirigami.Units.smallSpacing

    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            source: "help-contextual"
            Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
            Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
        }

        PlasmaComponents.Label {
            text: "How Battery Mode works"
            font.bold: true
            font.pointSize: Kirigami.Theme.defaultFont.pointSize + 1
        }
    }

    Kirigami.Separator {
        Layout.fillWidth: true
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: autoHelp.implicitHeight + Kirigami.Units.largeSpacing * 2
        radius: Kirigami.Units.smallSpacing
        color: Qt.rgba(1, 1, 1, 0.025)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.055)

        RowLayout {
            id: autoHelp
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Icon {
                source: "view-refresh"
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                PlasmaComponents.Label {
                    text: "AUTO mode"
                    font.bold: true
                    color: page.controller.modeColor("auto")
                }

                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    opacity: 0.76
                    text: "AUTO selects DESK when AC is connected and either an external display or a real Thunderbolt/USB4 device is present. Otherwise it selects TRAVEL."
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: deskHelp.implicitHeight + Kirigami.Units.largeSpacing * 2
        radius: Kirigami.Units.smallSpacing
        color: Qt.rgba(1, 1, 1, 0.025)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.055)

        RowLayout {
            id: deskHelp
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Icon {
                source: "video-display"
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                PlasmaComponents.Label {
                    text: "DESK mode"
                    font.bold: true
                    color: page.controller.modeColor("desk")
                }

                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    opacity: 0.76
                    text: "Uses the lower charging window to reduce time spent at a high state of charge while the laptop is effectively docked."
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: travelHelp.implicitHeight + Kirigami.Units.largeSpacing * 2
        radius: Kirigami.Units.smallSpacing
        color: Qt.rgba(1, 1, 1, 0.025)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.055)

        RowLayout {
            id: travelHelp
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Icon {
                source: "go-jump"
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                PlasmaComponents.Label {
                    text: "TRAVEL mode"
                    font.bold: true
                    color: page.controller.modeColor("travel")
                }

                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    opacity: 0.76
                    text: "Uses the higher charging window so the battery stays close to full before mobile use."
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: thresholdHelp.implicitHeight + Kirigami.Units.largeSpacing * 2
        radius: Kirigami.Units.smallSpacing
        color: Qt.rgba(1, 1, 1, 0.025)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.055)

        RowLayout {
            id: thresholdHelp
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Icon {
                source: "battery"
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                PlasmaComponents.Label {
                    text: "Charging thresholds"
                    font.bold: true
                }

                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    opacity: 0.76
                    text: "A 75–80% window means charging resumes below 75% and stops at 80%. Current defaults are DESK 75–80% and TRAVEL 95–100%."
                }
            }
        }
    }

}
