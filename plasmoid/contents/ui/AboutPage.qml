import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

ColumnLayout {
    id: page

    property var controller

    spacing: Kirigami.Units.largeSpacing

    // ------------------------------------------------------------------
    // Hero / product identity
    // ------------------------------------------------------------------
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: heroRow.implicitHeight + Kirigami.Units.largeSpacing * 2
        radius: Kirigami.Units.smallSpacing * 1.4
        color: Qt.rgba(1, 1, 1, 0.035)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.075)

        RowLayout {
            id: heroRow

            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing

            Rectangle {
                Layout.preferredWidth: Kirigami.Units.iconSizes.huge + Kirigami.Units.largeSpacing
                Layout.preferredHeight: Layout.preferredWidth
                radius: Kirigami.Units.smallSpacing * 1.5
                color: Qt.rgba(0.20, 0.85, 0.43, 0.08)
                border.width: 1
                border.color: Qt.rgba(0.20, 0.85, 0.43, 0.18)

                Image {
                    anchors.centerIn: parent
                    width: parent.width - Kirigami.Units.largeSpacing
                    height: width
                    fillMode: Image.PreserveAspectFit
                    source: page.controller.stateIconSource()
                    smooth: true
                    mipmap: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        text: "Battery Mode for Plasma"
                        font.bold: true
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize + 3
                    }

                    Rectangle {
                        implicitWidth: versionText.implicitWidth + Kirigami.Units.largeSpacing
                        implicitHeight: versionText.implicitHeight + Kirigami.Units.smallSpacing
                        radius: height / 2
                        color: Qt.rgba(1, 1, 1, 0.055)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.09)

                        PlasmaComponents.Label {
                            id: versionText
                            anchors.centerIn: parent
                            text: "v" + page.controller.appVersion
                            font.bold: true
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                            opacity: 0.88
                        }
                    }
                }

                PlasmaComponents.Label {
                    text: "Battery charge-threshold manager"
                    opacity: 0.76
                }

                PlasmaComponents.Label {
                    text: "Linux · KDE Plasma 6 · power_supply"
                    opacity: 0.56
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                }

                RowLayout {
                    spacing: Kirigami.Units.smallSpacing

                    Rectangle {
                        implicitWidth: ossBadgeRow.implicitWidth + Kirigami.Units.largeSpacing
                        implicitHeight: ossBadgeRow.implicitHeight + Kirigami.Units.smallSpacing
                        radius: height / 2
                        color: Qt.rgba(0.20, 0.85, 0.43, 0.10)
                        border.width: 1
                        border.color: Qt.rgba(0.20, 0.85, 0.43, 0.22)

                        RowLayout {
                            id: ossBadgeRow
                            anchors.centerIn: parent
                            spacing: 4

                            Kirigami.Icon {
                                source: "code-context"
                                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                            }

                            PlasmaComponents.Label {
                                text: "OPEN SOURCE"
                                font.bold: true
                                font.pointSize: Kirigami.Theme.smallFont.pointSize
                                color: "#55d77a"
                            }
                        }
                    }

                    Rectangle {
                        implicitWidth: mitBadgeRow.implicitWidth + Kirigami.Units.largeSpacing
                        implicitHeight: mitBadgeRow.implicitHeight + Kirigami.Units.smallSpacing
                        radius: height / 2
                        color: Qt.rgba(0.22, 0.60, 0.95, 0.10)
                        border.width: 1
                        border.color: Qt.rgba(0.22, 0.60, 0.95, 0.22)

                        RowLayout {
                            id: mitBadgeRow
                            anchors.centerIn: parent
                            spacing: 4

                            Kirigami.Icon {
                                source: "documentinfo"
                                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                            }

                            PlasmaComponents.Label {
                                text: "MIT LICENSE"
                                font.bold: true
                                font.pointSize: Kirigami.Theme.smallFont.pointSize
                                color: Kirigami.Theme.highlightColor
                            }
                        }
                    }
                }
            }
        }
    }

    // ------------------------------------------------------------------
    // Author credit
    // ------------------------------------------------------------------
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: authorRow.implicitHeight + Kirigami.Units.largeSpacing * 2
        radius: Kirigami.Units.smallSpacing * 1.25
        color: Qt.rgba(1, 1, 1, 0.025)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)

        RowLayout {
            id: authorRow

            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing

            Rectangle {
                Layout.preferredWidth: Kirigami.Units.iconSizes.large
                Layout.preferredHeight: Layout.preferredWidth
                radius: width / 2
                color: Qt.rgba(1, 1, 1, 0.055)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.10)

                Kirigami.Icon {
                    anchors.centerIn: parent
                    source: "user-identity"
                    width: Kirigami.Units.iconSizes.medium
                    height: width
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                PlasmaComponents.Label {
                    text: "Created by"
                    opacity: 0.58
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                }

                PlasmaComponents.Label {
                    text: "Mirko Cetkovic"
                    font.bold: true
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize + 1
                }

                PlasmaComponents.Label {
                    text: "Copyright © 2026"
                    opacity: 0.62
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                }
            }
        }
    }

    // ------------------------------------------------------------------
    // License summary
    // ------------------------------------------------------------------
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: licenseRow.implicitHeight + Kirigami.Units.largeSpacing * 2
        radius: Kirigami.Units.smallSpacing * 1.25
        color: Qt.rgba(1, 1, 1, 0.025)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)

        RowLayout {
            id: licenseRow

            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing

            Rectangle {
                Layout.preferredWidth: Kirigami.Units.iconSizes.large
                Layout.preferredHeight: Layout.preferredWidth
                radius: Kirigami.Units.smallSpacing
                color: Qt.rgba(0.22, 0.60, 0.95, 0.075)
                border.width: 1
                border.color: Qt.rgba(0.22, 0.60, 0.95, 0.16)

                Kirigami.Icon {
                    anchors.centerIn: parent
                    source: "documentinfo"
                    width: Kirigami.Units.iconSizes.medium
                    height: width
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                PlasmaComponents.Label {
                    text: "MIT License"
                    font.bold: true
                    color: Kirigami.Theme.highlightColor
                }

                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    opacity: 0.74
                    text: "Free to use, copy, modify, merge, publish, distribute, sublicense and sell, subject to the MIT License terms."
                }

                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    opacity: 0.50
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    text: "The complete license text is included with the application package."
                }
            }
        }
    }

    // ------------------------------------------------------------------
    // Project note / footer
    // ------------------------------------------------------------------
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: footerRow.implicitHeight + Kirigami.Units.largeSpacing * 2
        radius: Kirigami.Units.smallSpacing
        color: Qt.rgba(1, 1, 1, 0.016)

        RowLayout {
            id: footerRow

            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: "emblem-favorite"
                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                opacity: 0.72
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: "Built as a hardware-aware Linux utility for battery telemetry and charging-threshold control."
                opacity: 0.62
                font.pointSize: Kirigami.Theme.smallFont.pointSize
            }
        }
    }
}
