// theme_extensions.qml — DisplayCard/SigilBadge style helpers for extra slots
// Run: QT_QPA_PLATFORM=offscreen qml6 tests/theme_extensions.qml

import QtQuick
import "../qml/components"

Item {
    width: 320
    height: 200

    DisplayCard {
        id: asideCard
        width: 300
        cardType: "aside"
        body: "Sidebar body"
    }

    SigilBadge {
        id: logicBadge
        anchors.top: asideCard.bottom
        sigil: "⫻logic/gate"
        value: "open-slot"
        domain: "logic"
    }

    Component.onCompleted: {
        var ok = true
        var reasons = []

        if (Theme.cardTag("aside").indexOf("ASIDE") === -1) {
            ok = false
            reasons.push("cardTag(aside) missing ASIDE")
        }
        if (String(Theme.cardBadge("aside")) !== String(Theme.unknownBadge)) {
            ok = false
            reasons.push("unknown surface badge not fallback")
        }
        if (String(Theme.colorForDomain("logic")) !== String(Theme.sigilUnknown)) {
            ok = false
            reasons.push("unknown domain color not amber")
        }
        if (String(Theme.colorForDomain("flow")) !== String(Theme.sigilFlow)) {
            ok = false
            reasons.push("flow domain color drifted")
        }
        if (String(asideCard.color) !== String(Theme.cardBackground("aside"))) {
            ok = false
            reasons.push("aside card bg not themed")
        }
        if (String(logicBadge.accent) !== String(Theme.sigilUnknown)) {
            ok = false
            reasons.push("logic badge accent not unknown")
        }

        if (ok) {
            console.error("theme_extensions: PASSED aside+logic fallbacks")
            Qt.exit(0)
        } else {
            console.error("theme_extensions: FAILED " + reasons.join("; "))
            Qt.exit(1)
        }
    }
}
