.pragma library

// Mirrors t482 Widgets MainWindow::parseInput for the default grammar:
//   ⫻(context|cmd|data|flow)/<key>: <value>
//   ⫻display/header|content:\n ... until next ⫻ or EOF
//
// Extension surface (KickForge):
//   - Any ⫻<domain>/<key>:  except protocol/ and display/ is a telemetry sigil.
//   - Any ⫻display/<surface>:\n ... is a card (header keeps per-line indent strip).
//   - registerDomain / registerDisplaySurface record known names and surface options.
//   - resetExtensions() restores the t482 default grammar tables.

var DEFAULT_DOMAINS = ["context", "cmd", "data", "flow"]
var DEFAULT_SURFACES = {
    header: { stripLeading: true },
    content: { stripLeading: false }
}

var _domains = DEFAULT_DOMAINS.slice()
var _surfaces = {
    header: { stripLeading: true },
    content: { stripLeading: false }
}

function registeredDomains() {
    return _domains.slice()
}

function registeredSurfaces() {
    var names = []
    for (var name in _surfaces) {
        if (Object.prototype.hasOwnProperty.call(_surfaces, name))
            names.push(name)
    }
    names.sort()
    return names
}

function resetExtensions() {
    _domains = DEFAULT_DOMAINS.slice()
    _surfaces = {
        header: { stripLeading: true },
        content: { stripLeading: false }
    }
}

function registerDomain(name) {
    name = String(name || "").toLowerCase()
    if (!_isToken(name) || name === "protocol" || name === "display")
        return false
    if (_domains.indexOf(name) === -1)
        _domains.push(name)
    return true
}

function registerDisplaySurface(name, options) {
    name = String(name || "").toLowerCase()
    if (!_isToken(name))
        return false
    var opts = options || {}
    _surfaces[name] = {
        stripLeading: opts.stripLeading === true
    }
    return true
}

function parse(input) {
    var cards = []
    var sigils = []
    if (!input)
        return { cards: cards, sigils: sigils }

    var sigilRegex = /⫻(?!display\/|protocol\/)([a-z][a-z0-9_-]*)\/([a-z0-9_-]+):\s*(.*)/g
    var match
    while ((match = sigilRegex.exec(input)) !== null) {
        var domain = match[1]
        registerDomain(domain)
        sigils.push({
            domain: domain,
            key: match[2],
            sigil: "⫻" + domain + "/" + match[2],
            value: String(match[3]).trim(),
            known: DEFAULT_DOMAINS.indexOf(domain) !== -1
        })
    }

    var displayRegex = /⫻display\/([a-z0-9_-]+):\n([\s\S]*?)(?=\n⫻|$)/g
    while ((match = displayRegex.exec(input)) !== null) {
        var type = match[1]
        var spec = _surfaces[type]
        if (!spec)
            spec = { stripLeading: false }
        var text = String(match[2])
        if (spec.stripLeading)
            text = text.replace(/^\s+/gm, "")
        text = text.trim()
        if (text.length > 0) {
            cards.push({
                type: type,
                text: text,
                known: Object.prototype.hasOwnProperty.call(DEFAULT_SURFACES, type)
            })
        }
    }

    return { cards: cards, sigils: sigils }
}

function _isToken(name) {
    return /^[a-z][a-z0-9_-]*$/.test(name)
}
