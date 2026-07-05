#!/usr/bin/env bash
set -euo pipefail

MODEL_ROOT="${1:-${MODEL_ROOT:-/models/Qwen3-Omni-30B-A3B-Instruct-NVFP4}}"
MODEL_REPO="${MODEL_REPO:-ELK-AI/Qwen3-Omni-30B-A3B-Instruct-NVFP4}"
ROOT_CONFIG_REPO="${ROOT_CONFIG_REPO:-Qwen/Qwen3-Omni-30B-A3B-Instruct}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export MODEL_ROOT MODEL_REPO ROOT_CONFIG_REPO

python3 - <<'PY'
import os
import pathlib
import shutil

from huggingface_hub import hf_hub_download, snapshot_download

model_root = pathlib.Path(os.environ["MODEL_ROOT"]).expanduser().resolve()
model_repo = os.environ["MODEL_REPO"]
root_config_repo = os.environ["ROOT_CONFIG_REPO"]

model_root.mkdir(parents=True, exist_ok=True)

print(f"Downloading {model_repo} to {model_root}")
snapshot_download(
    repo_id=model_repo,
    local_dir=str(model_root),
    local_dir_use_symlinks=False,
)

thinker_dir = model_root / "thinker"
thinker_dir.mkdir(exist_ok=True)

root_files_for_thinker = [
    "added_tokens.json",
    "chat_template.jinja",
    "merges.txt",
    "preprocessor_config.json",
    "special_tokens_map.json",
    "tokenizer.json",
    "tokenizer_config.json",
    "video_preprocessor_config.json",
    "vocab.json",
]

for name in root_files_for_thinker:
    src = model_root / name
    dst = thinker_dir / name
    if not src.exists() or dst.exists():
        continue
    try:
        dst.symlink_to(pathlib.Path("..") / name)
    except OSError:
        shutil.copy2(src, dst)

vllm_root_config = model_root / "vllm-root-config"
vllm_root_config.mkdir(exist_ok=True)

for filename in ("config.json", "generation_config.json"):
    downloaded = pathlib.Path(
        hf_hub_download(repo_id=root_config_repo, filename=filename)
    )
    shutil.copy2(downloaded, vllm_root_config / filename)

print("Model tree prepared.")
PY

MODEL_ROOT="$MODEL_ROOT" "$SCRIPT_DIR/verify_model_files.py"
