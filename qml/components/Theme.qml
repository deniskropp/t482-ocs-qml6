pragma Singleton
import QtQuick

QtObject {
    id: theme

    readonly property color bgPrimary: "#0a0a0c"
    readonly property color bgSecondary: "#141419"
    readonly property color bgPanel: "#111115"
    readonly property color bgCardHeader: "#18241b"
    readonly property color bgCardContent: "#16161e"
    readonly property color bgCardLlm: "#0d1a1f"
    readonly property color bgBadge: "#181820"
    readonly property color bgTelemetry: "#09090c"

    readonly property color accent: "#00ff41"
    readonly property color textPrimary: "#ffffff"
    readonly property color textBody: "#d1d5db"
    readonly property color textMuted: "#888888"
    readonly property color editorText: "#00e5ff"
    readonly property color border: "#22222a"
    readonly property color borderContent: "#3d3d5c"
    readonly property color borderTelemetry: "#222222"

    readonly property color sigilContext: "#00e5ff"
    readonly property color sigilCmd: "#00b0ff"
    readonly property color sigilData: "#76ff03"
    readonly property color sigilFlow: "#d500f9"
    readonly property color sigilUnknown: "#ffab00"
    readonly property color contentBadge: "#7928ca"
    readonly property color unknownBadge: "#00e5ff"

    readonly property string fontFamily: "PlexMono"

    function colorForDomain(domain) {
        switch (String(domain)) {
        case "cmd": return sigilCmd
        case "data": return sigilData
        case "flow": return sigilFlow
        case "context": return sigilContext
        default: return sigilUnknown
        }
    }

    function cardBackground(type) {
        if (type === "header")
            return bgCardHeader
        if (type === "llm")
            return bgCardLlm
        return bgCardContent
    }

    function cardBorder(type) {
        if (type === "header")
            return accent
        if (type === "llm")
            return sigilContext
        return borderContent
    }

    function cardBadge(type) {
        if (type === "header")
            return accent
        if (type === "content")
            return contentBadge
        if (type === "llm")
            return sigilContext
        return unknownBadge
    }

    function cardBadgeText(type) {
        return type === "header" ? "#000000" : "#ffffff"
    }

    function cardTag(type) {
        var label = String(type || "block").toUpperCase()
        return " ⫻DISPLAY / " + label + " "
    }

    function cardBodyColor(type) {
        return type === "header" ? textPrimary : textBody
    }

    function cardBodySize(type) {
        return type === "header" ? 14 : 12
    }

    function cardBodyBold(type) {
        return type === "header"
    }
}
