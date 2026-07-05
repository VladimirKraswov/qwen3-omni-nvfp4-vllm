#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
mkdir -p logs

if [[ -f qwen-vllm.pid ]] && kill -0 "$(cat qwen-vllm.pid)" 2>/dev/null; then
  echo "Qwen vLLM already appears to be running with PID $(cat qwen-vllm.pid)."
  exit 0
fi

nohup ./serve_qwen_omni_nvfp4.sh > logs/qwen-vllm.log 2>&1 &
pid="$!"
echo "$pid" > qwen-vllm.pid
echo "Started Qwen vLLM with PID $pid."
echo "Log: $(pwd)/logs/qwen-vllm.log"
