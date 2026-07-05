#!/usr/bin/env bash
set -euo pipefail

MODEL_ROOT="${MODEL_ROOT:-/models/Qwen3-Omni-30B-A3B-Instruct-NVFP4}"
MODEL_DIR="${MODEL_DIR:-$MODEL_ROOT/thinker}"
TOKENIZER_DIR="${TOKENIZER_DIR:-$MODEL_ROOT}"
HF_CONFIG_PATH="${HF_CONFIG_PATH:-$MODEL_ROOT/vllm-root-config}"
SERVED_MODEL_NAME="${SERVED_MODEL_NAME:-qwen3-omni-nvfp4-thinker}"
PORT="${PORT:-18089}"
HOST="${HOST:-0.0.0.0}"
MAX_MODEL_LEN="${MAX_MODEL_LEN:-8192}"
GPU_MEMORY_UTILIZATION="${GPU_MEMORY_UTILIZATION:-0.90}"
MOE_BACKEND="${MOE_BACKEND:-marlin}"
NVFP4_GEMM_BACKEND="${VLLM_NVFP4_GEMM_BACKEND:-marlin}"
VLLM_BIN="${VLLM_BIN:-}"
HF_OVERRIDES="${HF_OVERRIDES:-{\"architectures\":[\"Qwen3OmniMoeForConditionalGeneration\"]}}"
CUDA_HOME="${CUDA_HOME:-/usr/local/cuda}"
NVRTC_LIB_DIR="${NVRTC_LIB_DIR:-}"

if [[ -z "$VLLM_BIN" ]]; then
  VLLM_BIN="$(command -v vllm || true)"
fi

if [[ -z "$VLLM_BIN" ]]; then
  echo "vllm binary not found. Set VLLM_BIN or use a vLLM-based image." >&2
  exit 1
fi

if [[ ! -d "$MODEL_ROOT" ]]; then
  echo "Model directory does not exist: $MODEL_ROOT" >&2
  echo "Mount the model volume or run: docker run ... prepare-model" >&2
  exit 1
fi

if [[ ! -d "$HF_CONFIG_PATH" ]]; then
  echo "vLLM root config directory is missing: $HF_CONFIG_PATH" >&2
  echo "Run prepare_model.sh / docker command 'prepare-model' before serving." >&2
  exit 1
fi

if [[ -z "$NVRTC_LIB_DIR" ]]; then
  for candidate in \
    /usr/local/lib/python*/dist-packages/nvidia/cu*/lib \
    /usr/local/lib/python*/site-packages/nvidia/cu*/lib \
    /opt/venv/lib/python*/site-packages/nvidia/cu*/lib; do
    match="$(compgen -G "$candidate/libnvrtc-builtins.so*" | head -n 1 || true)"
    if [[ -n "$match" ]]; then
      NVRTC_LIB_DIR="$(dirname "$match")"
      break
    fi
  done
fi

export CUDA_HOME
export CUDA_PATH="$CUDA_HOME"
export PATH="$CUDA_HOME/bin:${PATH:-}"
if [[ -d "$CUDA_HOME/targets/x86_64-linux/include" ]]; then
  export CPATH="$CUDA_HOME/targets/x86_64-linux/include:${CPATH:-}"
fi
if [[ -d "$CUDA_HOME/targets/x86_64-linux/lib" ]]; then
  export LIBRARY_PATH="$CUDA_HOME/targets/x86_64-linux/lib:${LIBRARY_PATH:-}"
  export LD_LIBRARY_PATH="$CUDA_HOME/targets/x86_64-linux/lib:${LD_LIBRARY_PATH:-}"
fi
if [[ -n "$NVRTC_LIB_DIR" && -d "$NVRTC_LIB_DIR" ]]; then
  export LD_LIBRARY_PATH="$NVRTC_LIB_DIR:${LD_LIBRARY_PATH:-}"
fi
export VLLM_NVFP4_GEMM_BACKEND="$NVFP4_GEMM_BACKEND"

exec "$VLLM_BIN" serve "$MODEL_DIR" \
  --tokenizer "$TOKENIZER_DIR" \
  --hf-config-path "$HF_CONFIG_PATH" \
  --served-model-name "$SERVED_MODEL_NAME" \
  --host "$HOST" \
  --port "$PORT" \
  --trust-remote-code \
  --hf-overrides "$HF_OVERRIDES" \
  --quantization modelopt_fp4 \
  --kv-cache-dtype fp8 \
  --moe-backend "$MOE_BACKEND" \
  --max-model-len "$MAX_MODEL_LEN" \
  --max-num-seqs "${MAX_NUM_SEQS:-1}" \
  --max-num-batched-tokens "${MAX_NUM_BATCHED_TOKENS:-4096}" \
  --gpu-memory-utilization "$GPU_MEMORY_UTILIZATION" \
  "$@"
