// parse_smoke.qml — headless parser contract check
// Run: QT_QPA_PLATFORM=offscreen qml6 tests/parse_smoke.qml

import QtQuick
import "../qml/parser/OcsParser.js" as OcsParser

QtObject {
    property string sample:
        "⫻protocol/ocs:\n" +
        "    ⫻context/klmx: KickLang-v4.1 / QML6 Engine\n" +
        "    ⫻cmd/mode: Fluid\n" +
        "    ⫻data/obj: parse smoke\n" +
        "    ⫻flow/nexus: t482-ocs-qml6\n" +
        "\n⫻display/header:\n" +
        "  Subject: Smoke Header\n" +
        "\n⫻display/content:\n" +
        "Smoke content body.\n"

    Component.onCompleted: {
        var result = OcsParser.parse(sample)
        var ok = true
        var reasons = []

        if (result.cards.length !== 2) {
            ok = false
            reasons.push("cards=" + result.cards.length + " expected 2")
        }
        if (result.sigils.length !== 4) {
            ok = false
            reasons.push("sigils=" + result.sigils.length + " expected 4")
        }
        if (!result.cards.length || result.cards[0].type !== "header") {
            ok = false
            reasons.push("first card is not header")
        }
        if (result.cards.length < 2 || result.cards[1].type !== "content") {
            ok = false
            reasons.push("second card is not content")
        }

        var domains = {}
        for (var i = 0; i < result.sigils.length; ++i)
            domains[result.sigils[i].domain] = result.sigils[i].sigil
        if (!domains.context || !domains.cmd || !domains.data || !domains.flow) {
            ok = false
            reasons.push("missing domain coverage")
        }

        if (ok) {
            console.error("parse_smoke: PASSED cards=2 sigils=4")
            Qt.exit(0)
        } else {
            console.error("parse_smoke: FAILED " + reasons.join("; "))
            Qt.exit(1)
        }
    }
}
