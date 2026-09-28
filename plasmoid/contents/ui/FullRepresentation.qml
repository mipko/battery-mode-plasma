import QtQuick
import QtQuick.Layouts

Item {
    id: full

    property var controller
    property int currentPage: 0

    implicitWidth: navigationShell.implicitWidth
    implicitHeight: navigationShell.implicitHeight

    Layout.minimumWidth: implicitWidth
    Layout.preferredWidth: implicitWidth
    Layout.maximumWidth: implicitWidth

    Layout.minimumHeight: implicitHeight
    Layout.preferredHeight: implicitHeight
    Layout.maximumHeight: implicitHeight

    DetailShell {
        id: navigationShell
        anchors.fill: parent

        controller: full.controller
        pageIndex: full.currentPage

        onBackToOverview: full.currentPage = 0
        onSelectPage: function(pageIndex) {
            full.currentPage = pageIndex
        }
    }
}
