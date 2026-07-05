#!/usr/bin/env python3
import argparse
import base64
import json
import mimetypes
import pathlib
import sys
import urllib.error
import urllib.request


DEFAULT_PROMPT = (
    "Describe the audio content briefly. If there is no speech, say so and "
    "describe the sound you hear."
)


def post_json(url: str, payload: dict, timeout: int) -> dict:
    data = json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(
        url,
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"HTTP {exc.code}: {body}") from exc


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-url", default="http://127.0.0.1:18089/v1")
    parser.add_argument("--model", default="qwen3-omni-nvfp4-thinker")
    parser.add_argument("--audio", default="assets/test_tone.wav")
    parser.add_argument("--prompt", default=DEFAULT_PROMPT)
    parser.add_argument("--timeout", type=int, default=180)
    parser.add_argument("--max-tokens", type=int, default=256)
    args = parser.parse_args()

    audio_path = pathlib.Path(args.audio)
    audio_bytes = audio_path.read_bytes()
    mime_type = mimetypes.guess_type(audio_path.name)[0] or "audio/wav"
    audio_url = f"data:{mime_type};base64,{base64.b64encode(audio_bytes).decode('ascii')}"

    payload = {
        "model": args.model,
        "messages": [
            {
                "role": "user",
                "content": [
                    {"type": "audio_url", "audio_url": {"url": audio_url}},
                    {"type": "text", "text": args.prompt},
                ],
            }
        ],
        "modalities": ["text"],
        "temperature": 0,
        "max_tokens": args.max_tokens,
    }

    try:
        response = post_json(
            f"{args.base_url.rstrip('/')}/chat/completions", payload, args.timeout
        )
    except Exception as exc:
        print(f"request_failed: {exc}", file=sys.stderr)
        return 1

    print(json.dumps(response, ensure_ascii=False, indent=2))
    try:
        content = response["choices"][0]["message"].get("content")
    except Exception:
        return 0
    if content:
        print("\n--- content ---")
        print(content)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

