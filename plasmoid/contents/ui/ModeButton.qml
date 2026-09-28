import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore

PlasmaCore.ToolTipArea {
    id: root

    property string modeName: "AUTO"
    property string description: ""
    property url iconSource
    property bool checked: false
    property bool controlEnabled: true

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: button.implicitHeight

    mainItem: RowLayout {
        spacing: Kirigami.Units.largeSpacing

        Image {
            Layout.preferredWidth: Kirigami.Units.iconSizes.large
            Layout.preferredHeight: Kirigami.Units.iconSizes.large
            fillMode: Image.PreserveAspectFit
            source: root.iconSource
            smooth: true
            mipmap: true
        }

        ColumnLayout {
            spacing: 2

            PlasmaComponents.Label {
                text: root.modeName
                font.bold: true
            }

            PlasmaComponents.Label {
                Layout.maximumWidth: Kirigami.Units.gridUnit * 15
                wrapMode: Text.WordWrap
                text: root.description
                opacity: 0.78
            }
        }
    }

    PlasmaComponents.Button {
        id: button
        anchors.fill: parent
        text: root.modeName
        enabled: root.controlEnabled
        checkable: true
        checked: root.checked
        onClicked: root.clicked()
    }
}
