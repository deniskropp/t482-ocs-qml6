// llm_invoke.qml — live LLM extract / KickGuard / SSE contract (no network)
// Run: QT_QPA_PLATFORM=offscreen qml6 tests/llm_invoke.qml

import QtQuick
import "../qml/parser/OcsParser.js" as OcsParser
import "../qml/llm/LlmClient.js" as LlmClient
import "../qml/components"

Item {
    width: 320
    height: 120

    DisplayCard {
        id: llmCard
        width: 300
        cardType: "llm"
        body: "delta"
    }

    Component.onCompleted: {
        var ok = true
        var reasons = []

        OcsParser.resetExtensions()
        var spec = OcsParser.extractLlmInvoke(
            "⫻cmd/llm: stream\n" +
            "⫻data/model: grok-4.6\n" +
            "⫻data/prompt: What is OCS Display?\n" +
            "⫻flow/llm: spacexai\n"
        )
        if (!spec.active || !spec.stream || spec.verb !== "stream") {
            ok = false
            reasons.push("cmd/llm stream not active")
        }
        if (spec.model !== "grok-4.6" || spec.prompt !== "What is OCS Display?") {
            ok = false
            reasons.push("model/prompt not extracted")
        }
        if (spec.provider !== "spacexai") {
            ok = false
            reasons.push("provider not spacexai")
        }

        var alt = OcsParser.extractLlmInvoke("⫻cmd/invoke: llm\n⫻data/obj: from-obj\n")
        if (!alt.active || alt.prompt !== "from-obj") {
            ok = false
            reasons.push("cmd/invoke llm / data/obj fallback failed")
        }

        var cards = OcsParser.extractLlmInvoke(
            "⫻display/header:\n  Subject: H\n\n⫻display/content:\nBody.\n"
        )
        if (cards.active) {
            ok = false
            reasons.push("display-only payload should not be auto-active")
        }
        if (cards.prompt.indexOf("Subject: H") === -1 || cards.prompt.indexOf("Body.") === -1) {
            ok = false
            reasons.push("header+content prompt fallback failed")
        }

        var idle = OcsParser.extractLlmInvoke("⫻cmd/llm: idle\n⫻data/prompt: p\n")
        if (idle.active || idle.halt) {
            ok = false
            reasons.push("idle verb must not activate transport")
        }

        var halted = OcsParser.extractLlmInvoke("⫻cmd/llm: halt\n")
        if (!halted.halt || halted.active) {
            ok = false
            reasons.push("halt verb not parsed")
        }

        var denied = LlmClient.guardInvoke({
            consent: false,
            apiKey: "xai-test-key-not-real-00000000",
            spec: { prompt: "hi", model: "grok-4.6" }
        })
        if (denied.ok || denied.code !== "consent") {
            ok = false
            reasons.push("KickGuard consent gate failed")
        }

        var nokey = LlmClient.guardInvoke({
            consent: true,
            apiKey: "",
            spec: { prompt: "hi", model: "grok-4.6" }
        })
        if (nokey.ok || nokey.code !== "key") {
            ok = false
            reasons.push("missing key gate failed")
        }

        var noprompt = LlmClient.guardInvoke({
            consent: true,
            apiKey: "xai-test-key-not-real-00000000",
            spec: { prompt: "  ", model: "grok-4.6" }
        })
        if (noprompt.ok || noprompt.code !== "prompt") {
            ok = false
            reasons.push("empty prompt gate failed")
        }

        var allowed = LlmClient.guardInvoke({
            consent: true,
            apiKey: "xai-test-key-not-real-00000000",
            spec: { prompt: "What is OCS Display?", model: "not-a-model" }
        })
        if (!allowed.ok) {
            ok = false
            reasons.push("valid consent+key+prompt rejected")
        } else {
            if (allowed.request.url !== "https://api.x.ai/v1/chat/completions") {
                ok = false
                reasons.push("base url drifted")
            }
            if (allowed.request.body.model !== "grok-4.6") {
                ok = false
                reasons.push("invalid model not sanitized to grok-4.6")
            }
            if (allowed.request.body.stream !== true) {
                ok = false
                reasons.push("stream flag not set")
            }
            if (allowed.request.body.messages[1].content !== "What is OCS Display?") {
                ok = false
                reasons.push("user message mismatch")
            }
        }

        var redacted = LlmClient.redactSecrets("keep xai-AAAAAAAAAAAAAAAAAAAA drop")
        if (redacted.indexOf("xai-AAAAAAAAAAAAAAAAAAAA") !== -1 || redacted.indexOf("[redacted]") === -1) {
            ok = false
            reasons.push("secret redaction failed")
        }

        var path = LlmClient.resolveKeyFileFromArgs(["qml6", "Main.qml", "--", "--llm-key-file", "/tmp/ocs-qml6/xai.env"])
        if (path !== "/tmp/ocs-qml6/xai.env") {
            ok = false
            reasons.push("key file arg parse failed")
        }

        var sse = LlmClient.consumeSse(
            "data: {\"choices\":[{\"delta\":{\"content\":\"Ah\"}}]}\n\n" +
            "data: {\"choices\":[{\"delta\":{\"content\":\",\"}}]}\n\n" +
            "data: [DONE]\n\npartial"
        )
        if (sse.text !== "Ah," || sse.done !== true || sse.rest !== "partial") {
            ok = false
            reasons.push("SSE consume failed text=" + sse.text + " done=" + sse.done + " rest=" + sse.rest)
        }

        if (String(Theme.cardBadge("llm")) !== String(Theme.sigilContext)) {
            ok = false
            reasons.push("llm badge color drifted")
        }
        if (String(llmCard.color) !== String(Theme.cardBackground("llm"))) {
            ok = false
            reasons.push("llm card bg not themed")
        }
        if (Theme.cardTag("llm").indexOf("LLM") === -1) {
            ok = false
            reasons.push("llm card tag missing LLM")
        }

        if (ok) {
            console.error("llm_invoke: PASSED extract+guard+sse+theme")
            Qt.exit(0)
        } else {
            console.error("llm_invoke: FAILED " + reasons.join("; "))
            Qt.exit(1)
        }
    }
}
