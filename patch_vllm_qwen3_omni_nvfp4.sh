#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
import importlib.util
import pathlib
import shutil
import time

spec = importlib.util.find_spec("vllm.model_executor.models.qwen3_omni_moe_thinker")
if spec is None or spec.origin is None:
    print("vLLM Qwen3 Omni thinker module not found; skipping patch.")
    raise SystemExit(0)

path = pathlib.Path(spec.origin)
text = path.read_text()

if '"model.": "language_model.model."' in text:
    print("vLLM Qwen3 Omni NVFP4 prefix patch already present.")
    raise SystemExit(0)

needle = '            "thinker.": "",\n'
replacement = (
    '            "thinker.": "",\n'
    '            "lm_head.": "language_model.lm_head.",\n'
    '            "model.": "language_model.model.",\n'
)

if needle not in text:
    print(f"Could not find expected WeightsMapper block in {path}; skipping patch.")
    raise SystemExit(0)

backup = path.with_suffix(path.suffix + f".bak_qwen_nvfp4_prefix_{int(time.time())}")
shutil.copy2(path, backup)
path.write_text(text.replace(needle, replacement, 1))
print(f"Patched vLLM Qwen3 Omni weight prefixes in {path}")
PY
