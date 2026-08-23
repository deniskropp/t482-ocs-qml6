import QtQuick
import QtQuick.Layouts

Rectangle {
    id: headerBar

    color: "#141419"
    border.color: "#00ff41"
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
            color: "#00ff41"
            font.pixelSize: 14
            font.bold: true
            font.family: "FreeMono"
        }

        Item { Layout.fillWidth: true }

        Text {
            text: "ENGINE: QtQuick 6 / QML6 | NODE: Berlin"
            color: "#888888"
            font.pixelSize: 11
            font.family: "FreeMono"
        }
    }
}
