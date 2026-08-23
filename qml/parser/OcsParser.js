.pragma library

// Mirrors t482 Widgets MainWindow::parseInput regex contract:
//   ⫻(context|cmd|data|flow)/<key>: <value>
//   ⫻display/header:\n ... until next ⫻ or EOF
//   ⫻display/content:\n ... until next ⫻ or EOF

function parse(input) {
    var cards = []
    var sigils = []
    if (!input)
        return { cards: cards, sigils: sigils }

    var sigilRegex = /⫻(context|cmd|data|flow)\/([a-z0-9_-]+):\s*(.*)/g
    var match
    while ((match = sigilRegex.exec(input)) !== null) {
        sigils.push({
            domain: match[1],
            key: match[2],
            sigil: "⫻" + match[1] + "/" + match[2],
            value: String(match[3]).trim()
        })
    }

    var headerRegex = /⫻display\/header:\n([\s\S]*?)(?=\n⫻|$)/g
    while ((match = headerRegex.exec(input)) !== null) {
        var headerText = String(match[1]).replace(/^\s+/gm, "").trim()
        if (headerText.length > 0)
            cards.push({ type: "header", text: headerText })
    }

    var contentRegex = /⫻display\/content:\n([\s\S]*?)(?=\n⫻|$)/g
    while ((match = contentRegex.exec(input)) !== null) {
        var contentText = String(match[1]).trim()
        if (contentText.length > 0)
            cards.push({ type: "content", text: contentText })
    }

    return { cards: cards, sigils: sigils }
}
