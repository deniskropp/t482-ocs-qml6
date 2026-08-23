// Main.qml — OCS/Node QML6 Display Engine
// Run: qml6 qml/Main.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import "parser/OcsParser.js" as OcsParser

ApplicationWindow {
    id: window
    width: 1100
    height: 750
    visible: true
    title: "OCS/Node QML6 Engine v0.1 (QtQuick 6)"
    color: "#0a0a0c"

    ListModel { id: displayModel }
    ListModel { id: protocolModel }

    readonly property string defaultPayload:
        "⫻protocol/ocs:\n" +
        "  Context:\n" +
        "    ⫻context/klmx: KickLang-v4.1 / QML6 Engine\n" +
        "    ⫻context/node: OCS/Display · Berlin Node\n" +
        "  Directives:\n" +
        "    ⫻cmd/mode: Fluid QML6 Pipeline\n" +
        "  Payloads:\n" +
        "    ⫻data/obj: Render parsed ⫻display blocks via QtQuick 6\n" +
        "    ⫻flow/nexus: t482-ocs-qml6 surface\n" +
        "\n⫻display/header:\n" +
        "  Subject: MetaForge QML6 Protocol Display Engine Active\n" +
        "\n⫻display/content:\n" +
        "The OCS protocol handler parses ⫻-sigil markers in QML6 and elevates them into DisplayCard and SigilBadge components.\n\n" +
        "Surface contract (aligned with t482 Widgets):\n" +
        " • Live AST extraction of context/cmd/data/flow\n" +
        " • Dedicated header and content cards\n" +
        " • High-contrast terminal telemetry styling"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        HeaderBar {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
        }

        SplitView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: Qt.Horizontal

            Rectangle {
                SplitView.preferredWidth: 420
                SplitView.minimumWidth: 280
                color: "#111115"
                border.color: "#22222a"
                radius: 4

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Text {
                        text: "RAW OCS PAYLOAD INPUT"
                        color: "#00ff41"
                        font.pixelSize: 11
                        font.bold: true
                        font.family: "FreeMono"
                    }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        TextArea {
                            id: payloadInput
                            color: "#00e5ff"
                            selectionColor: "#00ff41"
                            selectedTextColor: "#000000"
                            font.family: "FreeMono"
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
                color: "#111115"
                border.color: "#22222a"
                radius: 4

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Text {
                        text: "PARSED ⫻DISPLAY QML6 VIEW"
                        color: "#00ff41"
                        font.pixelSize: 11
                        font.bold: true
                        font.family: "FreeMono"
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

                            Text {
                                visible: displayModel.count === 0
                                width: cardsColumn.width
                                text: "No ⫻display/header or ⫻display/content blocks parsed."
                                color: "#888888"
                                wrapMode: Text.WordWrap
                                font.family: "FreeMono"
                                font.pixelSize: 12
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: Math.max(56, telemetryFlow.implicitHeight + 16)
                        color: "#09090c"
                        border.color: "#222222"
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

    Component.onCompleted: parsePayload(payloadInput.text)

    function parsePayload(input) {
        displayModel.clear()
        protocolModel.clear()

        var result = OcsParser.parse(input)
        var i
        for (i = 0; i < result.cards.length; ++i)
            displayModel.append(result.cards[i])
        for (i = 0; i < result.sigils.length; ++i)
            protocolModel.append(result.sigils[i])
    }
}
