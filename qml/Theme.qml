import QtQuick

QtObject {
    id: theme

    readonly property color bgPrimary: "#0a0a0c"
    readonly property color bgSecondary: "#141419"
    readonly property color bgPanel: "#111115"
    readonly property color bgCardHeader: "#18241b"
    readonly property color bgCardContent: "#16161e"
    readonly property color bgBadge: "#181820"

    readonly property color accent: "#00ff41"
    readonly property color textPrimary: "#ffffff"
    readonly property color textBody: "#d1d5db"
    readonly property color textMuted: "#888888"
    readonly property color editorText: "#00e5ff"
    readonly property color border: "#22222a"
    readonly property color borderContent: "#3d3d5c"

    readonly property color sigilContext: "#00e5ff"
    readonly property color sigilCmd: "#00b0ff"
    readonly property color sigilData: "#76ff03"
    readonly property color sigilFlow: "#d500f9"
    readonly property color contentBadge: "#7928ca"

    readonly property string fontFamily: "FreeMono"
}
