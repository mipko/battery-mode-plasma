import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Rectangle {
    id: nav

    property string iconName: ""
    property string text: ""
    property bool selected: false

    signal clicked()

    implicitWidth: Kirigami.Units.gridUnit * 4.6
    implicitHeight: Kirigami.Units.gridUnit * 3.5
    radius: Kirigami.Units.smallSpacing

    color: selected
        ? Qt.rgba(0.18, 0.62, 0.95, 0.20)
        : (mouse.containsMouse ? Qt.rgba(1, 1, 1, 0.045) : "transparent")

    border.width: selected ? 1 : 0
    border.color: Kirigami.Theme.highlightColor

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 2

        Kirigami.Icon {
            source: nav.iconName
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
            Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
        }

        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            text: nav.text
            font.bold: nav.selected
            color: nav.selected ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
            font.pointSize: Kirigami.Theme.smallFont.pointSize
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: nav.clicked()
    }
}
