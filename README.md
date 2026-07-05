# Qwen3 Omni NVFP4 vLLM Docker Wrapper

Docker and helper scripts for serving `ELK-AI/Qwen3-Omni-30B-A3B-Instruct-NVFP4`
with vLLM.

The Docker image contains only the runtime wrapper and scripts. Model weights are
not included and must be downloaded separately.

## What This Runs

- Model tree: `Qwen3-Omni-30B-A3B-Instruct-NVFP4`
- Served component: `thinker`
- Tokenizer/processor path: model root
- vLLM model path: `thinker`
- Required vLLM config path: `vllm-root-config`
- Default served name: `qwen3-omni-nvfp4-thinker`
- Default port: `18089`
- Quantization: `modelopt_fp4`
- Working RTX 5090 backend combination:
  - `MOE_BACKEND=marlin`
  - `VLLM_NVFP4_GEMM_BACKEND=marlin`

The `marlin` dense NVFP4 GEMM override is important on RTX 5090. In testing, the
default FlashInfer-Cutlass dense NVFP4 path loaded successfully but produced NaN
logprobs and repeated `!` output.

## Docker Image

```bash
docker pull xproger/qwen3-omni-nvfp4-vllm:latest
```

## Prepare Model

Choose a host directory for the model:

```bash
export MODEL_DIR=/home/vladimir/ai-models/llm/Qwen3-Omni-30B-A3B-Instruct-NVFP4
mkdir -p "$MODEL_DIR"
```

Download and prepare the model tree:

```bash
docker run --rm \
  -v "$MODEL_DIR:/models/Qwen3-Omni-30B-A3B-Instruct-NVFP4" \
  xproger/qwen3-omni-nvfp4-vllm:latest prepare-model
```

This downloads `ELK-AI/Qwen3-Omni-30B-A3B-Instruct-NVFP4`, adds root tokenizer
files into `thinker/` as symlinks, and downloads root `config.json` /
`generation_config.json` from `Qwen/Qwen3-Omni-30B-A3B-Instruct` into
`vllm-root-config/`.

If the Hugging Face repository requires authentication in your environment, pass
`HF_TOKEN` to the container.

## Serve

```bash
docker run --rm --gpus all --ipc=host --shm-size 8g \
  -p 18089:18089 \
  -v "$MODEL_DIR:/models/Qwen3-Omni-30B-A3B-Instruct-NVFP4" \
  xproger/qwen3-omni-nvfp4-vllm:latest
```

The OpenAI-compatible endpoint will be available at:

```text
http://localhost:18089/v1
```

## Docker Compose

Edit the volume path in `docker-compose.yml` if needed, then:

```bash
docker compose up -d
docker compose logs -f qwen3-omni-vllm
```

## Smoke Test

After the server is up:

```bash
BASE_URL=http://127.0.0.1:18089/v1 ./run_smoke_test.sh
```

The smoke test creates a mono 16 kHz WAV tone and sends it to
`/v1/chat/completions` as an `audio_url` data URI.

Expected audio result: the model should say there is no speech and describe a
sustained test tone.

## Useful Local Scripts

```bash
./serve_qwen_omni_nvfp4.sh
./start_qwen_background.sh
./status.sh
./stop_qwen.sh
./run_smoke_test.sh
```

For local non-Docker use, set:

```bash
export MODEL_ROOT=/path/to/Qwen3-Omni-30B-A3B-Instruct-NVFP4
export VLLM_BIN=/path/to/vllm
```

Then run `./serve_qwen_omni_nvfp4.sh`.
