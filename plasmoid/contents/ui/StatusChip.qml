import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Rectangle {
    id: chip

    property string iconName: ""
    property string title: ""
    property string valueText: ""
    property bool active: false
    property color activeColor: Kirigami.Theme.highlightColor

    implicitWidth: chipRow.implicitWidth + Kirigami.Units.smallSpacing * 3
    implicitHeight: Math.max(Kirigami.Units.gridUnit * 3.0,
                             chipRow.implicitHeight + Kirigami.Units.smallSpacing * 2)
    radius: Kirigami.Units.smallSpacing
    color: Qt.rgba(1, 1, 1, chip.active ? 0.060 : 0.030)
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, chip.active ? 0.13 : 0.065)

    RowLayout {
        id: chipRow
        anchors.fill: parent
        anchors.leftMargin: Kirigami.Units.smallSpacing * 1.5
        anchors.rightMargin: Kirigami.Units.smallSpacing * 1.5
        spacing: Kirigami.Units.smallSpacing

        Rectangle {
            width: 4
            height: Kirigami.Units.iconSizes.medium + 8
            radius: 2
            color: chip.active ? chip.activeColor : Qt.rgba(1, 1, 1, 0.18)
        }

        Rectangle {
            Layout.preferredWidth: Kirigami.Units.iconSizes.large
            Layout.preferredHeight: Kirigami.Units.iconSizes.large
            radius: Kirigami.Units.smallSpacing
            color: chip.active
                ? Qt.rgba(chip.activeColor.r, chip.activeColor.g, chip.activeColor.b, 0.11)
                : Qt.rgba(1, 1, 1, 0.025)

            Kirigami.Icon {
                anchors.centerIn: parent
                width: Kirigami.Units.iconSizes.medium
                height: width
                source: chip.iconName
                opacity: chip.active ? 1.0 : 0.70
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            PlasmaComponents.Label {
                text: chip.title
                opacity: 0.94
                font.pointSize: Kirigami.Theme.smallFont.pointSize
            }

            PlasmaComponents.Label {
                text: chip.valueText
                color: chip.active ? chip.activeColor : Kirigami.Theme.disabledTextColor
                font.bold: true
                font.pointSize: Kirigami.Theme.defaultFont.pointSize
            }
        }
    }
}
