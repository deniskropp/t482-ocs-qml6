.pragma library

// Live LLM invocation for the QML6 surface.
// Providers:
//   spacexai — POST https://api.x.ai/v1/chat/completions (stream SSE)
//   gemini   — POST generativelanguage.googleapis.com ...:streamGenerateContent?alt=sse
// KickGuard: invoke() requires consent === true; never logs API keys.

var PROVIDER_SPACEXAI = "spacexai"
var PROVIDER_GEMINI = "gemini"

var DEFAULT_XAI_BASE = "https://api.x.ai/v1"
var DEFAULT_GEMINI_BASE = "https://generativelanguage.googleapis.com/v1beta"
var DEFAULT_XAI_MODEL = "grok-4.6"
var DEFAULT_GEMINI_MODEL = "gemini-3.7-flash"
var DEFAULT_SYSTEM =
    "You are an assistant on the OCS/Display QML6 surface (Berlin node). " +
    "Answer the user prompt directly. Do not echo secrets or API keys."
var MAX_PROMPT_CHARS = 32000
var XAI_MODEL_RE = /^grok-[a-z0-9][a-z0-9._-]{0,62}$/i
var GEMINI_MODEL_RE = /^(gemini-[a-z0-9][a-z0-9._-]{0,80}|gemini-flash-latest|gemini-pro-latest)$/i

var _xhr = null
var _halted = false

function defaultProvider() {
    return PROVIDER_SPACEXAI
}

function defaultModel(provider) {
    return normalizeProvider(provider) === PROVIDER_GEMINI ? DEFAULT_GEMINI_MODEL : DEFAULT_XAI_MODEL
}

function defaultBaseUrl(provider) {
    return normalizeProvider(provider) === PROVIDER_GEMINI ? DEFAULT_GEMINI_BASE : DEFAULT_XAI_BASE
}

function providerLabel(provider) {
    return normalizeProvider(provider) === PROVIDER_GEMINI ? "Gemini" : "SpaceXAI"
}

function isBusy() {
    return _xhr !== null
}

function halt() {
    _halted = true
    if (_xhr) {
        try {
            _xhr.abort()
        } catch (e) {
        }
        _xhr = null
    }
}

function normalizeProvider(raw, model) {
    var p = String(raw || "").trim().toLowerCase()
    if (p === "gemini" || p === "google" || p === "googleai" || p === "google-ai")
        return PROVIDER_GEMINI
    if (p === "spacexai" || p === "xai" || p === "grok" || p === "x.ai")
        return PROVIDER_SPACEXAI
    var m = String(model || "").trim().toLowerCase()
    if (m.indexOf("gemini") === 0)
        return PROVIDER_GEMINI
    return PROVIDER_SPACEXAI
}

function sanitizeModel(name, provider) {
    var raw = String(name || "").trim()
    var p = normalizeProvider(provider, raw)
    if (p === PROVIDER_GEMINI)
        return GEMINI_MODEL_RE.test(raw) ? raw : DEFAULT_GEMINI_MODEL
    return XAI_MODEL_RE.test(raw) ? raw : DEFAULT_XAI_MODEL
}

function redactSecrets(text) {
    return String(text || "").replace(
        /\b(xai-[A-Za-z0-9_-]{16,}|sk-[A-Za-z0-9_-]{16,}|AIza[0-9A-Za-z_-]{20,})\b/g,
        "[redacted]"
    )
}

function resolveKeyFileFromArgs(args) {
    var list = args || []
    var i
    for (i = 0; i < list.length; ++i) {
        var a = String(list[i])
        if (a === "--llm-key-file" && i + 1 < list.length)
            return String(list[i + 1])
        if (a.indexOf("--llm-key-file=") === 0)
            return a.substring("--llm-key-file=".length)
    }
    return ""
}

function parseEnvFile(raw) {
    var out = { spacexai: "", gemini: "" }
    var text = String(raw || "").replace(/\r\n/g, "\n")
    var lines = text.split("\n")
    var i
    var sawAssignment = false
    for (i = 0; i < lines.length; ++i) {
        var line = lines[i].replace(/^\s+|\s+$/g, "")
        if (!line.length || line.charAt(0) === "#")
            continue
        var eq = line.indexOf("=")
        if (eq <= 0) {
            if (!sawAssignment && !out.spacexai)
                out.spacexai = line
            continue
        }
        sawAssignment = true
        var k = line.substring(0, eq).replace(/^\s+|\s+$/g, "")
        var v = line.substring(eq + 1).replace(/^\s+|\s+$/g, "")
        if ((v.charAt(0) === "\"" && v.charAt(v.length - 1) === "\"") ||
            (v.charAt(0) === "'" && v.charAt(v.length - 1) === "'"))
            v = v.substring(1, v.length - 1)
        if (k === "XAI_API_KEY")
            out.spacexai = v
        else if (k === "GEMINI_API_KEY")
            out.gemini = v
        else if (k === "GOOGLE_API_KEY" && !out.gemini)
            out.gemini = v
    }
    return out
}

function buildChatRequest(spec) {
    spec = spec || {}
    var provider = normalizeProvider(spec.provider, spec.model)
    var prompt = redactSecrets(spec.prompt || "")
    var system = redactSecrets(spec.system || DEFAULT_SYSTEM)
    if (!system)
        system = DEFAULT_SYSTEM
    var model = sanitizeModel(spec.model, provider)

    if (provider === PROVIDER_GEMINI) {
        return {
            provider: PROVIDER_GEMINI,
            auth: "goog-api-key",
            url: DEFAULT_GEMINI_BASE + "/models/" + encodeURIComponent(model) + ":streamGenerateContent?alt=sse",
            model: model,
            body: {
                systemInstruction: { parts: [{ text: system }] },
                contents: [{ role: "user", parts: [{ text: prompt }] }]
            }
        }
    }

    return {
        provider: PROVIDER_SPACEXAI,
        auth: "bearer",
        url: DEFAULT_XAI_BASE + "/chat/completions",
        model: model,
        body: {
            model: model,
            stream: true,
            messages: [
                { role: "system", content: system },
                { role: "user", content: prompt }
            ]
        }
    }
}

function guardInvoke(opts) {
    opts = opts || {}
    if (opts.consent !== true)
        return { ok: false, code: "consent", error: "KickGuard: explicit consent required before live LLM transport" }

    var spec = opts.spec || {}
    var provider = normalizeProvider(spec.provider, spec.model)
    var key = String(opts.apiKey || "").trim()
    if (!key && opts.keys)
        key = String(opts.keys[provider] || "").trim()
    if (!key) {
        var hint = provider === PROVIDER_GEMINI
            ? "GEMINI_API_KEY not available (export it, then rerun scripts/run.sh)"
            : "XAI_API_KEY not available (export it, then rerun scripts/run.sh)"
        return { ok: false, code: "key", error: hint }
    }

    var prompt = String(spec.prompt || "").trim()
    if (!prompt)
        return { ok: false, code: "prompt", error: "No prompt: set ⫻data/prompt or ⫻display/content" }
    if (prompt.length > MAX_PROMPT_CHARS)
        return { ok: false, code: "size", error: "Prompt exceeds " + MAX_PROMPT_CHARS + " chars" }

    return { ok: true, request: buildChatRequest(spec), apiKeyPresent: true, provider: provider }
}

function consumeSse(buffer) {
    var text = ""
    var done = false
    var rest = String(buffer || "")
    rest = rest.replace(/\r\n/g, "\n")

    while (true) {
        var split = rest.indexOf("\n\n")
        if (split === -1)
            break
        var frame = rest.substring(0, split)
        rest = rest.substring(split + 2)
        var lines = frame.split("\n")
        var j
        for (j = 0; j < lines.length; ++j) {
            var line = lines[j]
            if (line.indexOf("data:") !== 0)
                continue
            var payload = line.substring(5).trim()
            if (payload === "[DONE]") {
                done = true
                continue
            }
            if (!payload)
                continue
            try {
                var obj = JSON.parse(payload)
                var piece = _deltaContent(obj)
                if (piece)
                    text += piece
                if (_streamFinished(obj))
                    done = true
            } catch (e) {
            }
        }
    }

    return { text: text, done: done, rest: rest }
}

function invoke(opts) {
    var gated = guardInvoke(opts)
    if (!gated.ok) {
        if (opts && opts.onError)
            opts.onError(gated.error, gated.code)
        return gated
    }

    halt()
    _halted = false

    var xhr = new XMLHttpRequest()
    _xhr = xhr
    var seen = 0
    var carry = ""
    var assembled = ""
    var finished = false
    var request = gated.request
    var key = String(opts.apiKey || "").trim()
    if (!key && opts.keys)
        key = String(opts.keys[request.provider] || "").trim()

    function finishOk() {
        if (finished)
            return
        finished = true
        if (opts.onDone)
            opts.onDone(assembled)
    }

    function finishErr(message, code) {
        if (finished)
            return
        finished = true
        if (opts.onError)
            opts.onError(message, code)
    }

    xhr.onreadystatechange = function () {
        if (xhr.readyState !== XMLHttpRequest.LOADING && xhr.readyState !== XMLHttpRequest.DONE)
            return

        var raw = String(xhr.responseText || "")
        if (raw.length > seen) {
            carry += raw.substring(seen)
            seen = raw.length
            var chunk = consumeSse(carry)
            carry = chunk.rest
            if (chunk.text) {
                assembled += chunk.text
                if (opts.onDelta)
                    opts.onDelta(chunk.text, assembled)
            }
            if (chunk.done)
                finishOk()
        }

        if (xhr.readyState === XMLHttpRequest.DONE) {
            var active = (_xhr === xhr)
            if (active)
                _xhr = null
            if (!active)
                return

            if (xhr.status === 0) {
                if (_halted)
                    return
                finishErr("Live LLM transport aborted or unreachable", "network")
                return
            }
            if (xhr.status < 200 || xhr.status >= 300) {
                finishErr(_httpError(xhr, request.provider), "http")
                return
            }
            if (!assembled.length && xhr.responseText)
                assembled = _fallbackPlain(xhr.responseText)
            finishOk()
        }
    }

    try {
        xhr.open("POST", request.url)
        if (request.auth === "goog-api-key")
            xhr.setRequestHeader("x-goog-api-key", key)
        else
            xhr.setRequestHeader("Authorization", "Bearer " + key)
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.setRequestHeader("Accept", "text/event-stream")
        xhr.send(JSON.stringify(request.body))
    } catch (e) {
        _xhr = null
        var msg = "Live LLM transport failed to open"
        if (opts.onError)
            opts.onError(msg, "network")
        return { ok: false, code: "network", error: msg }
    }

    return { ok: true, streaming: true, model: request.model, provider: request.provider }
}

function _deltaContent(obj) {
    if (!obj)
        return ""
    if (obj.choices && obj.choices.length) {
        var choice = obj.choices[0]
        if (choice.delta && choice.delta.content)
            return String(choice.delta.content)
        if (choice.message && choice.message.content)
            return String(choice.message.content)
    }
    if (obj.candidates && obj.candidates.length) {
        var content = obj.candidates[0].content
        if (!content || !content.parts)
            return ""
        var out = ""
        var i
        for (i = 0; i < content.parts.length; ++i) {
            if (content.parts[i] && content.parts[i].text)
                out += String(content.parts[i].text)
        }
        return out
    }
    return ""
}

function _streamFinished(obj) {
    if (!obj || !obj.candidates || !obj.candidates.length)
        return false
    var reason = String(obj.candidates[0].finishReason || "").toUpperCase()
    return reason === "STOP" || reason === "MAX_TOKENS" || reason === "SAFETY"
}

function _fallbackPlain(raw) {
    var text = String(raw || "")
    try {
        var obj = JSON.parse(text)
        var piece = _deltaContent(obj)
        if (piece)
            return piece
        if (obj.length) {
            var acc = ""
            var i
            for (i = 0; i < obj.length; ++i)
                acc += _deltaContent(obj[i])
            return acc
        }
    } catch (e) {
    }
    return ""
}

function _httpError(xhr, provider) {
    var label = providerLabel(provider)
    var body = String(xhr.responseText || "")
    var snippet = redactSecrets(body.substring(0, 240))
    var status = xhr.status
    try {
        var parsed = JSON.parse(body)
        if (parsed.error && parsed.error.message)
            return label + " HTTP " + status + ": " + parsed.error.message
    } catch (e) {
    }
    if (snippet)
        return label + " HTTP " + status + ": " + snippet
    return label + " HTTP " + status
}
