import QtQuick
import QtQuick.Layouts

Rectangle {
    id: card

    required property string cardType
    required property string body

    color: Theme.cardBackground(cardType)
    border.color: Theme.cardBorder(cardType)
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
            color: Theme.cardBadge(card.cardType)
            implicitWidth: tagLabel.implicitWidth + 12
            implicitHeight: 20
            radius: 3

            Text {
                id: tagLabel
                anchors.centerIn: parent
                text: Theme.cardTag(card.cardType)
                color: Theme.cardBadgeText(card.cardType)
                font.pixelSize: 10
                font.bold: true
                font.family: Theme.fontFamily
            }
        }

        Text {
            Layout.fillWidth: true
            text: card.body
            color: Theme.cardBodyColor(card.cardType)
            font.pixelSize: Theme.cardBodySize(card.cardType)
            font.bold: Theme.cardBodyBold(card.cardType)
            font.family: Theme.fontFamily
            wrapMode: Text.WordWrap
            textFormat: Text.PlainText
        }
    }
}
