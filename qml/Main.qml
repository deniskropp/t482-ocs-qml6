// Main.qml — OCS/Node QML6 Display Engine
// Run: qml6 qml/Main.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import "parser/OcsParser.js" as OcsParser
import "llm/LlmClient.js" as LlmClient

ApplicationWindow {
    id: window
    width: 1100
    height: 750
    visible: true
    title: "OCS/Node QML6 Engine v0.1 (QtQuick 6)"
    color: Theme.bgPrimary

    ListModel { id: displayModel }
    ListModel { id: protocolModel }

    // C++ host sets this from XAI_API_KEY. qml6 path uses --llm-key-file instead.
    property string hostApiKey: ""
    property string llmApiKey: ""
    property bool llmBusy: false
    property string llmBody: ""
    property string llmStatus: "idle"
    property var llmSpec: ({
        active: false,
        stream: false,
        halt: false,
        verb: "",
        model: LlmClient.defaultModel(),
        prompt: "",
        system: "",
        provider: "spacexai"
    })

    readonly property string defaultPayload:
        "⫻protocol/ocs:\n" +
        "  Context:\n" +
        "    ⫻context/klmx: KickLang-v4.1 / QML6 Engine\n" +
        "    ⫻context/node: OCS/Display · Berlin Node\n" +
        "  Directives:\n" +
        "    ⫻cmd/mode: Fluid QML6 Pipeline\n" +
        "    ⫻cmd/llm: stream\n" +
        "  Payloads:\n" +
        "    ⫻data/obj: Render parsed ⫻display blocks via QtQuick 6\n" +
        "    ⫻data/model: grok-4.6\n" +
        "    ⫻data/prompt: In one sentence, what is the OCS Display protocol surface?\n" +
        "    ⫻flow/nexus: t482-ocs-qml6 surface\n" +
        "    ⫻flow/llm: spacexai\n" +
        "\n⫻display/header:\n" +
        "  Subject: MetaForge QML6 Protocol Display Engine Active\n" +
        "\n⫻display/content:\n" +
        "The OCS protocol handler parses ⫻-sigil markers in QML6 and elevates them into DisplayCard and SigilBadge components.\n\n" +
        "Surface contract (aligned with t482 Widgets):\n" +
        " • Live AST extraction of context/cmd/data/flow\n" +
        " • Dedicated header and content cards\n" +
        " • Open ⫻display/<surface> and ⫻<domain>/<key> extension slots\n" +
        " • KickGuard-gated live SpaceXAI invocation (⫻cmd/llm: stream)\n" +
        " • High-contrast terminal telemetry styling"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        HeaderBar {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
        }

        LlmInvokeBar {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            keyReady: window.llmApiKey.length > 0
            invokeReady: String(window.llmSpec.prompt || "").length > 0
            busy: window.llmBusy
            modelName: LlmClient.sanitizeModel(window.llmSpec.model)
            verb: String(window.llmSpec.verb || "")
            statusText: window.llmStatus
            onInvokeRequested: window.consentAndInvoke()
            onHaltRequested: window.haltLlm()
        }

        SplitView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: Qt.Horizontal

            Rectangle {
                SplitView.preferredWidth: 420
                SplitView.minimumWidth: 280
                color: Theme.bgPanel
                border.color: Theme.border
                radius: 4

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Text {
                        text: "RAW OCS PAYLOAD INPUT"
                        color: Theme.accent
                        font.pixelSize: 11
                        font.bold: true
                        font.family: Theme.fontFamily
                    }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        TextArea {
                            id: payloadInput
                            color: Theme.editorText
                            selectionColor: Theme.accent
                            selectedTextColor: "#000000"
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            wrapMode: TextEdit.Wrap
                            background: null
                            text: window.defaultPayload
                            onTextChanged: window.parsePayload(text)
                        }
                    }
                }
            }

            Rectangle {
                SplitView.fillWidth: true
                SplitView.minimumWidth: 360
                color: Theme.bgPanel
                border.color: Theme.border
                radius: 4

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Text {
                        text: "PARSED ⫻DISPLAY QML6 VIEW"
                        color: Theme.accent
                        font.pixelSize: 11
                        font.bold: true
                        font.family: Theme.fontFamily
                    }

                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        contentWidth: width
                        contentHeight: cardsColumn.implicitHeight

                        Column {
                            id: cardsColumn
                            width: parent.width
                            spacing: 12

                            Repeater {
                                model: displayModel
                                DisplayCard {
                                    required property string type
                                    required property string text
                                    width: cardsColumn.width
                                    cardType: type
                                    body: text
                                }
                            }

                            DisplayCard {
                                visible: window.llmBody.length > 0 || window.llmBusy
                                width: cardsColumn.width
                                cardType: "llm"
                                body: window.llmBusy && window.llmBody.length === 0
                                      ? "streaming…"
                                      : window.llmBody
                            }

                            Text {
                                visible: displayModel.count === 0 && window.llmBody.length === 0 && !window.llmBusy
                                width: cardsColumn.width
                                text: "No ⫻display/<surface> blocks parsed."
                                color: Theme.textMuted
                                wrapMode: Text.WordWrap
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: Math.max(56, telemetryFlow.implicitHeight + 16)
                        color: Theme.bgTelemetry
                        border.color: Theme.borderTelemetry
                        radius: 4

                        Item {
                            anchors.fill: parent
                            anchors.margins: 8

                            Flow {
                                id: telemetryFlow
                                width: parent.width
                                spacing: 8

                                Repeater {
                                    model: protocolModel
                                    Item {
                                        id: badgeWrap
                                        required property string sigil
                                        required property string value
                                        required property string domain
                                        implicitWidth: innerBadge.implicitWidth
                                        implicitHeight: innerBadge.implicitHeight
                                        width: implicitWidth
                                        height: implicitHeight
                                        SigilBadge {
                                            id: innerBadge
                                            sigil: badgeWrap.sigil
                                            value: badgeWrap.value
                                            domain: badgeWrap.domain
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        parsePayload(payloadInput.text)
        resolveApiKey()
    }

    function parsePayload(input) {
        displayModel.clear()
        protocolModel.clear()

        var result = OcsParser.parse(input)
        var i
        for (i = 0; i < result.cards.length; ++i)
            displayModel.append(result.cards[i])
        for (i = 0; i < result.sigils.length; ++i)
            protocolModel.append(result.sigils[i])

        window.llmSpec = OcsParser.extractLlmInvoke(input)
        refreshLlmStatus()
    }

    function refreshLlmStatus() {
        if (window.llmBusy)
            return
        if (!window.llmApiKey.length)
            window.llmStatus = "key missing · export XAI_API_KEY and rerun ./scripts/run.sh"
        else if (!String(window.llmSpec.prompt || "").length)
            window.llmStatus = "no prompt"
        else if (window.llmSpec.active)
            window.llmStatus = "ready · consent required"
        else
            window.llmStatus = "ready · editor fallback"
    }

    function resolveApiKey() {
        if (window.hostApiKey && window.hostApiKey.length) {
            window.llmApiKey = window.hostApiKey
            refreshLlmStatus()
            return
        }
        var path = LlmClient.resolveKeyFileFromArgs(Qt.application.arguments)
        if (!path.length) {
            refreshLlmStatus()
            return
        }
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return
            if (xhr.status === 0 || xhr.status === 200) {
                var raw = String(xhr.responseText || "").trim()
                var key = raw
                var lines = raw.split("\n")
                var i
                for (i = 0; i < lines.length; ++i) {
                    var line = lines[i].replace(/^\s+|\s+$/g, "")
                    if (!line.length || line.charAt(0) === "#")
                        continue
                    if (line.indexOf("XAI_API_KEY=") === 0)
                        key = line.substring("XAI_API_KEY=".length)
                    else
                        key = line
                    break
                }
                window.llmApiKey = key.replace(/^\s+|\s+$/g, "")
            }
            refreshLlmStatus()
        }
        xhr.open("GET", path.indexOf("file:") === 0 ? path : ("file://" + path))
        xhr.send()
    }

    function consentAndInvoke() {
        var spec = window.llmSpec
        if (!String(spec.prompt || "").length) {
            spec = OcsParser.extractLlmInvoke(payloadInput.text)
            if (!String(spec.prompt || "").length) {
                spec.prompt = payloadInput.text
                spec.model = spec.model || LlmClient.defaultModel()
            }
        }

        window.llmBusy = true
        window.llmBody = ""
        window.llmStatus = "streaming " + LlmClient.sanitizeModel(spec.model)

        var result = LlmClient.invoke({
            consent: true,
            apiKey: window.llmApiKey,
            spec: spec,
            onDelta: function (piece, full) {
                window.llmBody = full
            },
            onDone: function (full) {
                window.llmBusy = false
                window.llmBody = full && full.length ? full : window.llmBody
                window.llmStatus = "complete · " + LlmClient.sanitizeModel(spec.model)
            },
            onError: function (message) {
                window.llmBusy = false
                if (!window.llmBody.length)
                    window.llmBody = message
                window.llmStatus = message
            }
        })

        if (!result.ok) {
            window.llmBusy = false
            window.llmStatus = result.error
            if (!window.llmBody.length)
                window.llmBody = result.error
        }
    }

    function haltLlm() {
        LlmClient.halt()
        window.llmBusy = false
        window.llmStatus = "halted"
    }
}
