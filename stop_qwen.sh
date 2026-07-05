#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ ! -f qwen-vllm.pid ]]; then
  echo "No qwen-vllm.pid file."
  exit 0
fi

pid="$(cat qwen-vllm.pid)"
if kill -0 "$pid" 2>/dev/null; then
  kill "$pid"
  echo "Stopped Qwen vLLM PID $pid."
else
  echo "PID $pid is not running."
fi
rm -f qwen-vllm.pid

