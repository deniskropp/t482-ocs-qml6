import QtQuick
import QtQuick.Layouts

Rectangle {
    id: headerBar

    color: Theme.bgSecondary
    border.color: Theme.accent
    border.width: 1
    radius: 4
    implicitHeight: 48

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 12

        Text {
            text: "⫻ OCS/NODE QML6 ENGINE"
            color: Theme.accent
            font.pixelSize: 14
            font.bold: true
            font.family: Theme.fontFamily
        }

        Item { Layout.fillWidth: true }

        Text {
            text: "ENGINE: QtQuick 6 / QML6 | NODE: Berlin"
            color: Theme.textMuted
            font.pixelSize: 11
            font.family: Theme.fontFamily
        }
    }
}
