import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: shell

    property var controller
    property int pageIndex: 0

    signal backToOverview()
    signal selectPage(int pageIndex)

    readonly property real outerMargin: Kirigami.Units.largeSpacing

    readonly property real railImplicitHeight:
        navColumn.implicitHeight + Kirigami.Units.smallSpacing * 2

    readonly property real contentImplicitHeight:
        contentLoader.item
            ? contentLoader.item.implicitHeight
                + (shell.pageIndex === 0 ? 0 : Kirigami.Units.largeSpacing * 2)
            : Kirigami.Units.gridUnit * 12

    implicitWidth: Kirigami.Units.gridUnit * 30
    implicitHeight: Math.max(railImplicitHeight, contentImplicitHeight)
        + outerMargin * 2

    RowLayout {
        anchors.fill: parent
        anchors.margins: shell.outerMargin
        spacing: Kirigami.Units.largeSpacing

        Rectangle {
            id: navRail

            Layout.fillHeight: true
            Layout.preferredWidth: Kirigami.Units.gridUnit * 4.8

            implicitHeight: shell.railImplicitHeight

            radius: Kirigami.Units.smallSpacing * 1.2
            color: Qt.rgba(1, 1, 1, 0.028)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.06)

            ColumnLayout {
                id: navColumn

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Kirigami.Units.smallSpacing

                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents.ToolButton {
                    visible: shell.pageIndex !== 0
                    Layout.alignment: Qt.AlignHCenter
                    icon.name: "go-previous"
                    onClicked: shell.backToOverview()
                    PlasmaComponents.ToolTip.text: "Overview"
                    PlasmaComponents.ToolTip.visible: hovered
                }

                Kirigami.Separator {
                    visible: shell.pageIndex !== 0
                    Layout.fillWidth: true
                }

                NavButton {
                    Layout.fillWidth: true
                    iconName: "view-list-details"
                    text: "Status"
                    selected: shell.pageIndex === 1
                    onClicked: shell.selectPage(1)
                }

                NavButton {
                    Layout.fillWidth: true
                    iconName: "configure"
                    text: "Settings"
                    selected: shell.pageIndex === 2
                    onClicked: shell.selectPage(2)
                }

                Kirigami.Separator {
                    Layout.fillWidth: true
                    Layout.topMargin: Kirigami.Units.smallSpacing
                    Layout.bottomMargin: Kirigami.Units.smallSpacing
                }

                NavButton {
                    Layout.fillWidth: true
                    iconName: "help-contextual"
                    text: "Help"
                    selected: shell.pageIndex === 3
                    onClicked: shell.selectPage(3)
                }

                NavButton {
                    Layout.fillWidth: true
                    iconName: "dialog-information"
                    text: "About"
                    selected: shell.pageIndex === 4
                    onClicked: shell.selectPage(4)
                }
            }
        }

        Rectangle {
            id: contentPanel

            Layout.fillWidth: true
            Layout.fillHeight: true

            implicitHeight: shell.contentImplicitHeight

            radius: Kirigami.Units.smallSpacing * 1.2
            color: shell.pageIndex === 0 ? "transparent" : Qt.rgba(1, 1, 1, 0.025)
            border.width: shell.pageIndex === 0 ? 0 : 1
            border.color: Qt.rgba(1, 1, 1, 0.055)

            Loader {
                id: contentLoader

                anchors.fill: parent
                anchors.margins: shell.pageIndex === 0 ? 0 : Kirigami.Units.largeSpacing

                sourceComponent: shell.pageIndex === 0
                    ? overviewComponent
                    : (shell.pageIndex === 1
                        ? statusComponent
                        : (shell.pageIndex === 2
                            ? settingsComponent
                            : (shell.pageIndex === 3 ? helpComponent : aboutComponent)))
            }
        }
    }

    Component {
        id: overviewComponent

        OverviewPage {
            controller: shell.controller
        }
    }

    Component {
        id: statusComponent

        StatusPage {
            controller: shell.controller
        }
    }

    Component {
        id: settingsComponent

        SettingsPage {
            controller: shell.controller
        }
    }

    Component {
        id: helpComponent

        HelpPage {
            controller: shell.controller
        }
    }

    Component {
        id: aboutComponent

        AboutPage {
            controller: shell.controller
        }
    }
}
