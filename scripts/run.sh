#!/usr/bin/env bash
# Launch the OCS/Display QML6 surface (no C++ host required).
# If XAI_API_KEY and/or GEMINI_API_KEY (or GOOGLE_API_KEY) are set, write a
# 600-mode env file in XDG_RUNTIME_DIR and pass its path (not the keys) to QML
# via --llm-key-file for live SpaceXAI / Gemini invokes.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export QT_QUICK_CONTROLS_STYLE="${QT_QUICK_CONTROLS_STYLE:-Basic}"
export QT_FORCE_STDERR_LOGGING="${QT_FORCE_STDERR_LOGGING:-1}"

ARGS=()
gemini_key="${GEMINI_API_KEY:-${GOOGLE_API_KEY:-}}"
if [[ -n "${XAI_API_KEY:-}" || -n "$gemini_key" ]]; then
    runtime="${XDG_RUNTIME_DIR:-/tmp}/ocs-qml6"
    mkdir -p "$runtime"
    keyfile="$runtime/llm.env"
    umask 077
    : > "$keyfile"
    if [[ -n "${XAI_API_KEY:-}" ]]; then
        printf 'XAI_API_KEY=%s\n' "$XAI_API_KEY" >> "$keyfile"
    fi
    if [[ -n "$gemini_key" ]]; then
        printf 'GEMINI_API_KEY=%s\n' "$gemini_key" >> "$keyfile"
    fi
    chmod 600 "$keyfile"
    # Qt 6 disables file:// XMLHttpRequest unless this is set.
    export QML_XHR_ALLOW_FILE_READ=1
    ARGS+=(-- --llm-key-file "$keyfile")
fi

exec qml6 "${ROOT}/qml/Main.qml" "${ARGS[@]}"
