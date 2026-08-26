# t482-ocs-qml6 — OCS/Display QtQuick 6 Engine

QML6 surface for **OCS/Display**: live ⫻-sigil AST parse, dark terminal styling, `DisplayCard` header/content, and `SigilBadge` telemetry.

Lineage: OCS v2.1 · KickLang v4.1+ · t482 Widgets engine · t480 Display Protocol · Berlin Node.

## Layout

```
qml/Main.qml                 dual-pane ApplicationWindow
qml/components/DisplayCard.qml
qml/components/SigilBadge.qml
qml/components/HeaderBar.qml
qml/parser/OcsParser.js      default ⫻context|cmd|data|flow + ⫻display/header|content
                             open slots: ⫻<domain>/<key>, ⫻display/<surface>
qml/components/Theme.qml     singleton palette + domain/card style helpers
samples/demo.ocs
tests/parse_smoke.qml
tests/parse_extensions.qml
tests/theme_extensions.qml
```

## Run (no extra packages)

This node has `qml6` and `qt6-declarative` runtime. CMake Qml packages are optional.

```bash
./scripts/run.sh
# or
qml6 qml/Main.qml
```

Parser smoke (offscreen):

```bash
QT_QPA_PLATFORM=offscreen qml6 tests/parse_smoke.qml
QT_QPA_PLATFORM=offscreen qml6 tests/parse_extensions.qml
QT_QPA_PLATFORM=offscreen qml6 tests/theme_extensions.qml
```

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
| `⫻data/<key>:` | data badge |
| `⫻flow/<key>:` | flow badge |
| `⫻display/header:` | green header card |
| `⫻display/content:` | purple content card |
| `⫻display/<surface>:` | extra DisplayCard (tag from surface name) |
| `⫻<domain>/<key>:` | extra SigilBadge (amber if domain is new) |
