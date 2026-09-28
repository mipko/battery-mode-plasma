import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: surface

    property var controller
    property alias currentPage: content.currentPage

    signal requestClose()

    focus: true

    implicitWidth: Math.max(content.implicitWidth, Kirigami.Units.gridUnit * 21.5)
    implicitHeight: shellLayout.implicitHeight

    width: implicitWidth
    height: implicitHeight

    Layout.minimumWidth: implicitWidth
    Layout.preferredWidth: implicitWidth
    Layout.maximumWidth: implicitWidth

    Layout.minimumHeight: implicitHeight
    Layout.preferredHeight: implicitHeight
    Layout.maximumHeight: implicitHeight

    Keys.onEscapePressed: event => {
        surface.requestClose()
        event.accepted = true
    }

    ColumnLayout {
        id: shellLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: titleRow.implicitHeight + Kirigami.Units.largeSpacing * 2
            color: Qt.rgba(1, 1, 1, 0.018)

            RowLayout {
                id: titleRow
                anchors.fill: parent
                anchors.leftMargin: Kirigami.Units.largeSpacing
                anchors.rightMargin: Kirigami.Units.largeSpacing
                anchors.topMargin: Kirigami.Units.smallSpacing
                anchors.bottomMargin: Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.smallSpacing

                Image {
                    Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                    fillMode: Image.PreserveAspectFit
                    source: surface.controller.stateIconSource()
                    smooth: true
                    mipmap: true
                }

                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    text: "Battery Mode"
                    font.bold: true
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize + 2
                    elide: Text.ElideRight
                }
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        FullRepresentation {
            id: content
            controller: surface.controller

            Layout.fillWidth: true
            Layout.minimumHeight: implicitHeight
            Layout.preferredHeight: implicitHeight
            Layout.maximumHeight: implicitHeight
        }
    }
}
