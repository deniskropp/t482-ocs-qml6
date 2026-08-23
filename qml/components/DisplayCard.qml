import QtQuick
import QtQuick.Layouts

Rectangle {
    id: card

    required property string cardType
    required property string body

    readonly property bool isHeader: cardType === "header"

    color: isHeader ? "#18241b" : "#16161e"
    border.color: isHeader ? "#00ff41" : "#3d3d5c"
    border.width: 1
    radius: 6
    implicitHeight: cardLayout.implicitHeight + 24

    ColumnLayout {
        id: cardLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 8

        Rectangle {
            color: card.isHeader ? "#00ff41" : "#7928ca"
            implicitWidth: tagLabel.implicitWidth + 12
            implicitHeight: 20
            radius: 3

            Text {
                id: tagLabel
                anchors.centerIn: parent
                text: card.isHeader ? " ⫻DISPLAY / HEADER " : " ⫻DISPLAY / CONTENT "
                color: card.isHeader ? "#000000" : "#ffffff"
                font.pixelSize: 10
                font.bold: true
                font.family: "FreeMono"
            }
        }

        Text {
            Layout.fillWidth: true
            text: card.body
            color: card.isHeader ? "#ffffff" : "#d1d5db"
            font.pixelSize: card.isHeader ? 14 : 12
            font.bold: card.isHeader
            font.family: "FreeMono"
            wrapMode: Text.WordWrap
            textFormat: Text.PlainText
        }
    }
}
