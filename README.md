# t482-ocs-qml6 — OCS/Display QtQuick 6 Engine

QML6 surface for **OCS/Display**: live ⫻-sigil AST parse, dark terminal styling, `DisplayCard` header/content, `SigilBadge` telemetry, and KickGuard-gated live LLM invocation (SpaceXAI and Gemini).

Lineage: OCS v2.1 · KickLang v4.1+ · t482 Widgets engine · t480 Display Protocol · Berlin Node.

## Layout

```
qml/Main.qml                 dual-pane ApplicationWindow + live LLM bar
qml/components/DisplayCard.qml
qml/components/SigilBadge.qml
qml/components/HeaderBar.qml
qml/components/LlmInvokeBar.qml
qml/parser/OcsParser.js      default ⫻context|cmd|data|flow + ⫻display/header|content
                             extractLlmInvoke() for ⫻cmd/llm|invoke
                             open slots: ⫻<domain>/<key>, ⫻display/<surface>
qml/llm/LlmClient.js         SpaceXAI + Gemini streaming SSE (consent required)
qml/components/Theme.qml     singleton palette + domain/card style helpers
samples/demo.ocs
samples/llm-invoke.ocs
samples/llm-invoke-gemini.ocs
tests/parse_smoke.qml
tests/parse_extensions.qml
tests/theme_extensions.qml
tests/llm_invoke.qml
```

## Run (no extra packages)

This node has `qml6` and `qt6-declarative` runtime. CMake Qml packages are optional.

```bash
./scripts/run.sh
# or
qml6 qml/Main.qml
```

Parser / LLM contract smoke (offscreen):

```bash
QT_QPA_PLATFORM=offscreen qml6 tests/parse_smoke.qml
QT_QPA_PLATFORM=offscreen qml6 tests/parse_extensions.qml
QT_QPA_PLATFORM=offscreen qml6 tests/theme_extensions.qml
QT_QPA_PLATFORM=offscreen qml6 tests/llm_invoke.qml
```

## Live LLM (SpaceXAI + Gemini)

KickGuard will not call the network on parse or keystroke. Click **CONSENT & INVOKE**.

Provider is `⫻flow/llm:` or `⫻data/provider:` (`spacexai` | `gemini`). A `gemini-*` model infers Gemini.

```bash
export XAI_API_KEY=...      # https://console.x.ai
export GEMINI_API_KEY=...   # https://aistudio.google.com/apikey  (or GOOGLE_API_KEY)
./scripts/run.sh            # writes a 600-mode env file under $XDG_RUNTIME_DIR
                            # (sets QML_XHR_ALLOW_FILE_READ=1 so QML can load it)
```

| | SpaceXAI | Gemini |
|---|---|---|
| Select | `⫻flow/llm: spacexai` | `⫻flow/llm: gemini` |
| Endpoint | `https://api.x.ai/v1/chat/completions` | `…/v1beta/models/<id>:streamGenerateContent?alt=sse` |
| Default model | `grok-4.6` (`grok-*`) | `gemini-3.7-flash` (`gemini-*`) |
| Key | `XAI_API_KEY` | `GEMINI_API_KEY` or `GOOGLE_API_KEY` |

- Prompt: `⫻data/prompt:` else `⫻display/header` + `⫻display/content` else `⫻data/obj`
- Verb: `⫻cmd/llm: stream` (or `invoke`) — `halt` is parsed; use the HALT button to abort
- C++ host (`ocs_qml6_engine`) reads both env vars directly

The API keys are never placed on the process command line or in the OCS payload.

## Optional C++ host

Needs `qt6-declarative-dev` (Qt6::Quick CMake config):

```bash
./scripts/build.sh
./build/ocs_qml6_engine
```

## Sigils

| Pattern | Surface |
|---|---|
| `⫻protocol/ocs:` | root block |
| `⫻context/<key>:` | cyan telemetry badge |
| `⫻cmd/<key>:` | command badge |
| `⫻cmd/llm: stream` | live LLM invoke (KickGuard click-to-consent) |
| `⫻flow/llm:` / `⫻data/provider:` | `spacexai` or `gemini` |
| `⫻data/prompt:` | LLM user prompt |
| `⫻data/model:` | LLM model (`grok-*` or `gemini-*`) |
| `⫻data/<key>:` | data badge |
| `⫻flow/<key>:` | flow badge |
| `⫻display/header:` | green header card |
| `⫻display/content:` | purple content card |
| `⫻display/<surface>:` | extra DisplayCard (tag from surface name) |
| `⫻<domain>/<key>:` | extra SigilBadge (amber if domain is new) |
