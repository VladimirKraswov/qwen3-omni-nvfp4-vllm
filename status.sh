#!/usr/bin/env bash
set -euo pipefail

echo "Gemma/vLLM container:"
docker ps --filter name=itk-live-llm-runtime-vllm-1 --format '  {{.Names}} {{.Status}} {{.Image}}' || true

echo
echo "Qwen PID:"
if [[ -f qwen-vllm.pid ]] && kill -0 "$(cat qwen-vllm.pid)" 2>/dev/null; then
  echo "  running: $(cat qwen-vllm.pid)"
else
  echo "  not running"
fi

echo
PORT="${PORT:-18089}"
echo "Port $PORT:"
ss -ltnp 2>/dev/null | grep ":$PORT " || echo "  not listening"

echo
nvidia-smi --query-gpu=name,memory.used,memory.total,utilization.gpu --format=csv,noheader
