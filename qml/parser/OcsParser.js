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

// KickForge: live LLM invoke spec from ⫻cmd/llm|invoke plus prompt/model/system.
// Does not call the network. KickGuard consent lives in LlmClient.invoke.
function extractLlmInvoke(input) {
    var parsed = parse(input)
    var verb = ""
    var model = ""
    var prompt = ""
    var system = ""
    var objFallback = ""
    var providerRaw = ""
    var i

    for (i = 0; i < parsed.sigils.length; ++i) {
        var s = parsed.sigils[i]
        if (s.domain === "cmd" && s.key === "llm")
            verb = String(s.value || "").trim().toLowerCase()
        else if (s.domain === "cmd" && s.key === "invoke") {
            var invokeVal = String(s.value || "").trim().toLowerCase()
            if (invokeVal === "llm" || invokeVal === "stream")
                verb = "stream"
            else if (invokeVal === "spacexai" || invokeVal === "xai" || invokeVal === "grok" ||
                     invokeVal === "gemini" || invokeVal === "google" || invokeVal === "googleai") {
                verb = "stream"
                providerRaw = invokeVal
            }
        } else if (s.domain === "data" && s.key === "model")
            model = String(s.value || "").trim()
        else if (s.domain === "data" && s.key === "prompt")
            prompt = String(s.value || "").trim()
        else if (s.domain === "data" && s.key === "system")
            system = String(s.value || "").trim()
        else if (s.domain === "data" && s.key === "provider")
            providerRaw = String(s.value || "").trim()
        else if (s.domain === "data" && s.key === "obj")
            objFallback = String(s.value || "").trim()
        else if (s.domain === "flow" && s.key === "llm")
            providerRaw = String(s.value || "").trim()
    }

    if (!prompt) {
        var headerText = ""
        var contentText = ""
        for (i = 0; i < parsed.cards.length; ++i) {
            if (parsed.cards[i].type === "header" && !headerText)
                headerText = parsed.cards[i].text
            else if (parsed.cards[i].type === "content" && !contentText)
                contentText = parsed.cards[i].text
        }
        if (headerText && contentText)
            prompt = headerText + "\n\n" + contentText
        else if (contentText)
            prompt = contentText
        else if (headerText)
            prompt = headerText
        else
            prompt = objFallback
    }

    if (verb === "gemini" || verb === "google" || verb === "spacexai" || verb === "xai" || verb === "grok") {
        if (!providerRaw)
            providerRaw = verb
        verb = "stream"
    }

    var provider = _normalizeLlmProvider(providerRaw, model)
    var stream = (verb === "stream" || verb === "invoke")
    return {
        active: stream,
        stream: stream,
        halt: verb === "halt",
        verb: verb,
        model: model,
        prompt: prompt,
        system: system,
        provider: provider
    }
}

function _normalizeLlmProvider(raw, model) {
    var p = String(raw || "").trim().toLowerCase()
    if (p === "gemini" || p === "google" || p === "googleai" || p === "google-ai")
        return "gemini"
    if (p === "spacexai" || p === "xai" || p === "grok" || p === "x.ai")
        return "spacexai"
    var m = String(model || "").trim().toLowerCase()
    if (m.indexOf("gemini") === 0)
        return "gemini"
    return "spacexai"
}

function _isToken(name) {
    return /^[a-z][a-z0-9_-]*$/.test(name)
}
