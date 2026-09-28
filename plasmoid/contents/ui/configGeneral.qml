import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    // Plasma copies the actual KConfig values into these cfg_* aliases.
    property alias cfg_deskStart: deskStart.value
    property alias cfg_deskEnd: deskEnd.value
    property alias cfg_travelStart: travelStart.value
    property alias cfg_travelEnd: travelEnd.value
    property alias cfg_persistMode: persistMode.checked

    QQC2.Label {
        Kirigami.FormData.isSection: true
        text: i18n("DESK")
    }

    QQC2.SpinBox {
        id: deskStart
        Kirigami.FormData.label: i18n("Start charging:")
        from: 1
        to: 99
        editable: true
    }

    QQC2.SpinBox {
        id: deskEnd
        Kirigami.FormData.label: i18n("Stop charging:")
        from: 2
        to: 100
        editable: true
    }

    QQC2.Label {
        Kirigami.FormData.isSection: true
        text: i18n("TRAVEL")
    }

    QQC2.SpinBox {
        id: travelStart
        Kirigami.FormData.label: i18n("Start charging:")
        from: 1
        to: 99
        editable: true
    }

    QQC2.SpinBox {
        id: travelEnd
        Kirigami.FormData.label: i18n("Stop charging:")
        from: 2
        to: 100
        editable: true
    }

    QQC2.Label {
        Kirigami.FormData.isSection: true
        text: i18n("Mode")
    }

    QQC2.CheckBox {
        id: persistMode
        text: i18n("Persist selected mode across reboot")
    }

    QQC2.Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        visible: deskStart.value >= deskEnd.value || travelStart.value >= travelEnd.value
        color: Kirigami.Theme.negativeTextColor
        text: i18n("Start threshold must be lower than stop threshold.")
    }
}
