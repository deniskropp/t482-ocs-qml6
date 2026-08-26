// parse_extensions.qml — open domain/surface slots + registry
// Run: QT_QPA_PLATFORM=offscreen qml6 tests/parse_extensions.qml

import QtQuick
import "../qml/parser/OcsParser.js" as OcsParser

QtObject {
    property string sample:
        "⫻protocol/ocs:\n" +
        "    ⫻context/klmx: KickLang-v4.1 / QML6 Engine\n" +
        "    ⫻cmd/mode: Fluid\n" +
        "    ⫻data/obj: parse extensions\n" +
        "    ⫻flow/nexus: t482-ocs-qml6\n" +
        "    ⫻logic/gate: open-slot\n" +
        "\n⫻display/header:\n" +
        "  Subject: Extension Header\n" +
        "\n⫻display/aside:\n" +
        "Sidebar body.\n" +
        "\n⫻display/content:\n" +
        "Main body.\n"

    Component.onCompleted: {
        OcsParser.resetExtensions()
        var result = OcsParser.parse(sample)
        var ok = true
        var reasons = []

        if (result.cards.length !== 3) {
            ok = false
            reasons.push("cards=" + result.cards.length + " expected 3")
        }
        if (result.sigils.length !== 5) {
            ok = false
            reasons.push("sigils=" + result.sigils.length + " expected 5")
        }

        if (!result.cards.length || result.cards[0].type !== "header" || result.cards[0].known !== true) {
            ok = false
            reasons.push("first card is not known header")
        }
        if (result.cards.length < 2 || result.cards[1].type !== "aside" || result.cards[1].known !== false) {
            ok = false
            reasons.push("second card is not unknown aside")
        }
        if (result.cards.length < 3 || result.cards[2].type !== "content") {
            ok = false
            reasons.push("third card is not content")
        }

        var domains = {}
        var protocolLeak = false
        var displayLeak = false
        for (var i = 0; i < result.sigils.length; ++i) {
            var s = result.sigils[i]
            domains[s.domain] = s
            if (s.domain === "protocol")
                protocolLeak = true
            if (s.domain === "display")
                displayLeak = true
        }
        if (protocolLeak)
            reasons.push("protocol/ocs leaked into telemetry"), ok = false
        if (displayLeak)
            reasons.push("display surface leaked into telemetry"), ok = false
        if (!domains.context || !domains.cmd || !domains.data || !domains.flow) {
            ok = false
            reasons.push("missing default domain coverage")
        }
        if (!domains.logic || domains.logic.value !== "open-slot" || domains.logic.known !== false) {
            ok = false
            reasons.push("unknown ⫻logic/gate slot not parsed")
        }

        if (OcsParser.registeredDomains().indexOf("logic") === -1) {
            ok = false
            reasons.push("logic domain not registered on parse")
        }

        if (!OcsParser.registerDisplaySurface("aside", { stripLeading: true })) {
            ok = false
            reasons.push("registerDisplaySurface(aside) failed")
        }
        if (OcsParser.registerDomain("protocol") || OcsParser.registerDomain("display")) {
            ok = false
            reasons.push("protocol/display must stay reserved")
        }

        OcsParser.resetExtensions()
        var restored = OcsParser.registeredDomains()
        if (restored.indexOf("logic") !== -1) {
            ok = false
            reasons.push("resetExtensions did not drop logic")
        }
        var surfaces = OcsParser.registeredSurfaces()
        if (surfaces.indexOf("aside") !== -1) {
            ok = false
            reasons.push("resetExtensions did not drop aside")
        }
        if (surfaces.indexOf("header") === -1 || surfaces.indexOf("content") === -1) {
            ok = false
            reasons.push("resetExtensions dropped default surfaces")
        }

        var baseline = OcsParser.parse(
            "⫻context/node: n\n⫻cmd/mode: m\n⫻data/obj: d\n⫻flow/nexus: f\n" +
            "⫻display/header:\nH\n⫻display/content:\nC\n"
        )
        if (baseline.cards.length !== 2 || baseline.sigils.length !== 4) {
            ok = false
            reasons.push("default grammar contract drifted")
        }

        if (ok) {
            console.error("parse_extensions: PASSED cards=3 sigils=5 open-slots")
            Qt.exit(0)
        } else {
            console.error("parse_extensions: FAILED " + reasons.join("; "))
            Qt.exit(1)
        }
    }
}
