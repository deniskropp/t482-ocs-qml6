import QtQuick

Rectangle {
    id: badge

    property string sigil: ""
    property string value: ""
    property string domain: ""

    readonly property color accent: {
        switch (domain) {
        case "cmd": return "#00b0ff"
        case "data": return "#76ff03"
        case "flow": return "#d500f9"
        default: return "#00e5ff"
        }
    }

    color: "#181820"
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
        font.family: "FreeMono"
        textFormat: Text.RichText
    }
}
