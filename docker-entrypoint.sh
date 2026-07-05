#!/usr/bin/env bash
set -euo pipefail

command_name="${1:-serve}"
shift || true

case "$command_name" in
  serve)
    /app/patch_vllm_qwen3_omni_nvfp4.sh
    exec /app/serve_qwen_omni_nvfp4.sh "$@"
    ;;
  prepare-model)
    exec /app/prepare_model.sh "$@"
    ;;
  smoke-test)
    exec /app/run_smoke_test.sh "$@"
    ;;
  verify-model)
    exec /app/verify_model_files.py "$@"
    ;;
  bash|sh|python|python3|vllm)
    exec "$command_name" "$@"
    ;;
  *)
    exec "$command_name" "$@"
    ;;
esac
