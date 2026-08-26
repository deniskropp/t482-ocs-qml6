.pragma library

// Live SpaceXAI (xAI) invocation for the QML6 surface.
// Transport: POST https://api.x.ai/v1/chat/completions with stream:true.
// KickGuard: invoke() requires consent === true; never logs the API key.

var DEFAULT_BASE_URL = "https://api.x.ai/v1"
var DEFAULT_MODEL = "grok-4.6"
var DEFAULT_SYSTEM =
    "You are Grok on the OCS/Display QML6 surface (Berlin node). " +
    "Answer the user prompt directly. Do not echo secrets or API keys."
var MAX_PROMPT_CHARS = 32000
var MODEL_RE = /^grok-[a-z0-9][a-z0-9._-]{0,62}$/i

var _xhr = null
var _halted = false

function defaultModel() {
    return DEFAULT_MODEL
}

function defaultBaseUrl() {
    return DEFAULT_BASE_URL
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

function sanitizeModel(name) {
    var raw = String(name || "").trim()
    if (MODEL_RE.test(raw))
        return raw
    return DEFAULT_MODEL
}

function redactSecrets(text) {
    return String(text || "").replace(
        /\b(xai-[A-Za-z0-9_-]{16,}|sk-[A-Za-z0-9_-]{16,})\b/g,
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

function buildChatRequest(spec) {
    spec = spec || {}
    var prompt = redactSecrets(spec.prompt || "")
    var system = redactSecrets(spec.system || DEFAULT_SYSTEM)
    if (!system)
        system = DEFAULT_SYSTEM
    return {
        url: DEFAULT_BASE_URL + "/chat/completions",
        model: sanitizeModel(spec.model),
        body: {
            model: sanitizeModel(spec.model),
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

    var key = String(opts.apiKey || "").trim()
    if (!key)
        return { ok: false, code: "key", error: "XAI_API_KEY not available (export it, then rerun scripts/run.sh)" }

    var spec = opts.spec || {}
    var prompt = String(spec.prompt || "").trim()
    if (!prompt)
        return { ok: false, code: "prompt", error: "No prompt: set ⫻data/prompt or ⫻display/content" }
    if (prompt.length > MAX_PROMPT_CHARS)
        return { ok: false, code: "size", error: "Prompt exceeds " + MAX_PROMPT_CHARS + " chars" }

    return { ok: true, request: buildChatRequest(spec), apiKeyPresent: true }
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
                finishErr(_httpError(xhr), "http")
                return
            }
            finishOk()
        }
    }

    try {
        xhr.open("POST", request.url)
        xhr.setRequestHeader("Authorization", "Bearer " + String(opts.apiKey).trim())
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

    return { ok: true, streaming: true, model: request.model }
}

function _deltaContent(obj) {
    if (!obj || !obj.choices || !obj.choices.length)
        return ""
    var choice = obj.choices[0]
    if (choice.delta && choice.delta.content)
        return String(choice.delta.content)
    if (choice.message && choice.message.content)
        return String(choice.message.content)
    return ""
}

function _httpError(xhr) {
    var body = String(xhr.responseText || "")
    var snippet = body.substring(0, 240).replace(/\b(xai-[A-Za-z0-9_-]{8,}|sk-[A-Za-z0-9_-]{8,})\b/g, "[redacted]")
    var status = xhr.status
    try {
        var parsed = JSON.parse(body)
        if (parsed.error && parsed.error.message)
            return "SpaceXAI HTTP " + status + ": " + parsed.error.message
    } catch (e) {
    }
    if (snippet)
        return "SpaceXAI HTTP " + status + ": " + snippet
    return "SpaceXAI HTTP " + status
}
