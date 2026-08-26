import QtQuick

Rectangle {
    id: badge

    property string sigil: ""
    property string value: ""
    property string domain: ""

    readonly property color accent: Theme.colorForDomain(domain)

    color: Theme.bgBadge
    border.color: accent
    border.width: 1
    radius: 4
    implicitWidth: label.implicitWidth + 16
    implicitHeight: 32

    Text {
        id: label
        anchors.centerIn: parent
        text: "<b>" + badge.sigil + ":</b> " + badge.value
        color: badge.accent
        font.pixelSize: 10
        font.family: Theme.fontFamily
        textFormat: Text.RichText
    }
}
