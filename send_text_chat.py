#!/usr/bin/env python3
import argparse
import json
import sys
import urllib.error
import urllib.request


def post_json(url: str, payload: dict, timeout: int) -> dict:
    request = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
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
    parser.add_argument("--prompt", default="Answer in one short sentence: are you ready?")
    parser.add_argument("--timeout", type=int, default=120)
    args = parser.parse_args()

    payload = {
        "model": args.model,
        "messages": [{"role": "user", "content": args.prompt}],
        "temperature": 0,
        "max_tokens": 64,
    }
    try:
        response = post_json(
            f"{args.base_url.rstrip('/')}/chat/completions", payload, args.timeout
        )
    except Exception as exc:
        print(f"request_failed: {exc}", file=sys.stderr)
        return 1

    print(json.dumps(response, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

