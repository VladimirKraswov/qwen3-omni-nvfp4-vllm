#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ "${CONFIRM_STOP_GEMMA:-}" != "YES" ]]; then
  echo "Refusing to switch without explicit confirmation."
  echo "Run: CONFIRM_STOP_GEMMA=YES ./switch_from_gemma_to_qwen.sh"
  exit 2
fi

./stop_current_gemma_vllm.sh
./start_qwen_background.sh
./status.sh

