#!/usr/bin/env python3
import os
import pathlib
import sys


MODEL_ROOT = pathlib.Path(
    os.environ.get(
        "MODEL_ROOT",
        "/models/Qwen3-Omni-30B-A3B-Instruct-NVFP4",
    )
)

EXPECTED = [
    "added_tokens.json",
    "chat_template.jinja",
    "merges.txt",
    "preprocessor_config.json",
    "special_tokens_map.json",
    "thinker/config.json",
    "thinker/generation_config.json",
    "thinker/hf_quant_config.json",
    "thinker/model-00001-of-00005.safetensors",
    "thinker/model-00002-of-00005.safetensors",
    "thinker/model-00003-of-00005.safetensors",
    "thinker/model-00004-of-00005.safetensors",
    "thinker/model-00005-of-00005.safetensors",
    "thinker/model.safetensors.index.json",
    "thinker/added_tokens.json",
    "thinker/chat_template.jinja",
    "thinker/merges.txt",
    "thinker/preprocessor_config.json",
    "thinker/special_tokens_map.json",
    "thinker/tokenizer.json",
    "thinker/tokenizer_config.json",
    "thinker/video_preprocessor_config.json",
    "thinker/vocab.json",
    "tokenizer.json",
    "tokenizer_config.json",
    "video_preprocessor_config.json",
    "vllm-root-config/config.json",
    "vllm-root-config/generation_config.json",
    "vocab.json",
]


def main() -> int:
    missing = []
    empty = []
    for rel in EXPECTED:
        path = MODEL_ROOT / rel
        if not path.exists():
            missing.append(rel)
        elif path.is_file() and path.stat().st_size == 0:
            empty.append(rel)

    if missing:
        print("Missing files:")
        for rel in missing:
            print(f"  {rel}")
    if empty:
        print("Empty files:")
        for rel in empty:
            print(f"  {rel}")

    if missing or empty:
        return 1

    total_bytes = sum(
        path.stat().st_size for path in MODEL_ROOT.rglob("*") if path.is_file()
    )
    print(f"Model files look complete. Total file bytes: {total_bytes:,}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
