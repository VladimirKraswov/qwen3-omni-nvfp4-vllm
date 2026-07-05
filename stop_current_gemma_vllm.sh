#!/usr/bin/env bash
set -euo pipefail

container="itk-live-llm-runtime-vllm-1"

if [[ "${CONFIRM_STOP_GEMMA:-}" != "YES" ]]; then
  echo "Refusing to stop $container without explicit confirmation."
  echo "Run: CONFIRM_STOP_GEMMA=YES ./stop_current_gemma_vllm.sh"
  exit 2
fi

docker stop "$container"

