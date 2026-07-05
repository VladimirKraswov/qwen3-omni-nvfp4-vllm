ARG VLLM_IMAGE=vllm/vllm-openai:v0.20.1
FROM ${VLLM_IMAGE}

WORKDIR /app

COPY . /app

RUN python3 -m pip install --no-cache-dir --upgrade huggingface_hub && \
    chmod +x /app/*.sh /app/*.py && \
    mkdir -p /models

ENV MODEL_ROOT=/models/Qwen3-Omni-30B-A3B-Instruct-NVFP4 \
    MODEL_DIR=/models/Qwen3-Omni-30B-A3B-Instruct-NVFP4/thinker \
    TOKENIZER_DIR=/models/Qwen3-Omni-30B-A3B-Instruct-NVFP4 \
    HF_CONFIG_PATH=/models/Qwen3-Omni-30B-A3B-Instruct-NVFP4/vllm-root-config \
    SERVED_MODEL_NAME=qwen3-omni-nvfp4-thinker \
    PORT=18089 \
    HOST=0.0.0.0 \
    MAX_MODEL_LEN=8192 \
    MAX_NUM_SEQS=1 \
    MAX_NUM_BATCHED_TOKENS=4096 \
    GPU_MEMORY_UTILIZATION=0.90 \
    MOE_BACKEND=marlin \
    VLLM_NVFP4_GEMM_BACKEND=marlin

EXPOSE 18089

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["serve"]
