#!/usr/bin/env bash
# Launch the OCS/Display QML6 surface (no C++ host required).
# If XAI_API_KEY is set, write a 600-mode key file in XDG_RUNTIME_DIR and pass
# its path (not the key) to QML via --llm-key-file for live SpaceXAI invokes.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export QT_QUICK_CONTROLS_STYLE="${QT_QUICK_CONTROLS_STYLE:-Basic}"
export QT_FORCE_STDERR_LOGGING="${QT_FORCE_STDERR_LOGGING:-1}"

ARGS=()
if [[ -n "${XAI_API_KEY:-}" ]]; then
    runtime="${XDG_RUNTIME_DIR:-/tmp}/ocs-qml6"
    mkdir -p "$runtime"
    keyfile="$runtime/xai.env"
    umask 077
    printf '%s' "$XAI_API_KEY" > "$keyfile"
    chmod 600 "$keyfile"
    # Qt 6 disables file:// XMLHttpRequest unless this is set.
    export QML_XHR_ALLOW_FILE_READ=1
    ARGS+=(-- --llm-key-file "$keyfile")
fi

exec qml6 "${ROOT}/qml/Main.qml" "${ARGS[@]}"
