#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:18089/v1}"
MODEL="${MODEL:-qwen3-omni-nvfp4-thinker}"
PYTHON="${PYTHON:-python3}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR"

mkdir -p assets
"$PYTHON" make_test_audio.py --output assets/test_tone.wav
"$PYTHON" send_text_chat.py --base-url "$BASE_URL" --model "$MODEL"
"$PYTHON" send_audio_chat.py --base-url "$BASE_URL" --model "$MODEL" --audio assets/test_tone.wav
