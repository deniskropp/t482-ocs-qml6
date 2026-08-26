#!/usr/bin/env bash
# Optional C++ host build. Falls back to documenting the qml6 runtime path.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

cmake -B build -S .
cmake --build build -j"$(nproc)"

if [[ -x "$ROOT/build/ocs_qml6_engine" ]]; then
    echo "Build successful: $ROOT/build/ocs_qml6_engine"
else
    echo "C++ host not built (Qt6 Quick CMake package missing)."
    echo "Runtime: $ROOT/scripts/run.sh"
    echo "Smoke:   QT_QPA_PLATFORM=offscreen qml6 $ROOT/tests/parse_smoke.qml"
    echo "Slots:   QT_QPA_PLATFORM=offscreen qml6 $ROOT/tests/parse_extensions.qml"
    echo "LLM:     QT_QPA_PLATFORM=offscreen qml6 $ROOT/tests/llm_invoke.qml"
fi
