# AGENTS — t482-ocs-qml6 (OCS/Display QtQuick 6 surface)

QML6 companion to the native Widgets engine in `/home/dok/Projects/t482`. Operate through the `t482-ocs-qt6` skill.

## Grounding

1. **Workspace:** `/home/dok/Projects/t482-ocs-qml6`.
2. **Skill:** `~/.grok/skills/t482-ocs-qt6`.
3. **Surface:** QtQuick 6 dual-pane OCS/Display (raw payload | DisplayCard + SigilBadge).
4. **Parser:** `qml/parser/OcsParser.js` — same ⫻-sigil regex contract as t482 `MainWindow::parseInput`.
5. **Three-Agent-Core:** KickForge (grammar) / KickFlow (QML layout) / KickGuard (consent & node resources).
6. **Consent Gate:** Explicit confirmation before git push, PR creation, MCP transmission, or live LLM transport (`⫻cmd/llm` → KickGuard **CONSENT & INVOKE**).

## Run

```bash
./scripts/run.sh
QT_QPA_PLATFORM=offscreen qml6 tests/parse_smoke.qml
QT_QPA_PLATFORM=offscreen qml6 tests/parse_extensions.qml
QT_QPA_PLATFORM=offscreen qml6 tests/theme_extensions.qml
QT_QPA_PLATFORM=offscreen qml6 tests/llm_invoke.qml
```

C++ host (`ocs_qml6_engine`) requires `qt6-declarative-dev`. Without it, `qml6` is the runtime.
