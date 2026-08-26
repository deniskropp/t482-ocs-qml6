import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: bar

    property bool keyReady: false
    property bool invokeReady: false
    property bool busy: false
    property string modelName: "grok-4.6"
    property string statusText: "idle"
    property string verb: ""

    signal invokeRequested
    signal haltRequested

    color: Theme.bgSecondary
    border.color: Theme.border
    border.width: 1
    radius: 4
    implicitHeight: 40

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Rectangle {
            color: "#141c18"
            border.color: Theme.accent
            border.width: 1
            radius: 3
            implicitWidth: guardLabel.implicitWidth + 12
            implicitHeight: 22

            Text {
                id: guardLabel
                anchors.centerIn: parent
                text: "KICKGUARD"
                color: Theme.accent
                font.pixelSize: 9
                font.bold: true
                font.family: Theme.fontFamily
            }
        }

        Text {
            text: "LIVE LLM ⫻ SpaceXAI"
            color: Theme.sigilContext
            font.pixelSize: 11
            font.bold: true
            font.family: Theme.fontFamily
        }

        Text {
            text: bar.modelName
            color: Theme.textMuted
            font.pixelSize: 11
            font.family: Theme.fontFamily
        }

        Text {
            text: bar.verb.length ? ("⫻cmd/llm: " + bar.verb) : "editor prompt"
            color: Theme.sigilCmd
            font.pixelSize: 11
            font.family: Theme.fontFamily
        }

        Item { Layout.fillWidth: true }

        Text {
            text: bar.statusText
            color: bar.keyReady ? Theme.textBody : Theme.sigilUnknown
            font.pixelSize: 11
            font.family: Theme.fontFamily
            elide: Text.ElideRight
            Layout.maximumWidth: 280
        }

        Button {
            id: invokeBtn
            text: bar.busy ? "STREAMING…" : "CONSENT & INVOKE"
            enabled: !bar.busy && bar.keyReady && bar.invokeReady
            onClicked: bar.invokeRequested()
            contentItem: Text {
                text: invokeBtn.text
                color: invokeBtn.enabled ? "#000000" : Theme.textMuted
                font.pixelSize: 10
                font.bold: true
                font.family: Theme.fontFamily
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: invokeBtn.enabled ? Theme.accent : Theme.bgPanel
                border.color: invokeBtn.enabled ? Theme.accent : Theme.border
                radius: 3
            }
        }

        Button {
            id: haltBtn
            text: "HALT"
            enabled: bar.busy
            onClicked: bar.haltRequested()
            contentItem: Text {
                text: haltBtn.text
                color: haltBtn.enabled ? Theme.sigilUnknown : Theme.textMuted
                font.pixelSize: 10
                font.bold: true
                font.family: Theme.fontFamily
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: Theme.bgPanel
                border.color: haltBtn.enabled ? Theme.sigilUnknown : Theme.border
                radius: 3
            }
        }
    }
}
