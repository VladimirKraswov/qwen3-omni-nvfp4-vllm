#!/usr/bin/env python3
import argparse
import math
import pathlib
import wave


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", default="assets/test_tone.wav")
    parser.add_argument("--sample-rate", type=int, default=16000)
    parser.add_argument("--duration", type=float, default=3.0)
    args = parser.parse_args()

    output = pathlib.Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)

    sample_rate = args.sample_rate
    total_samples = int(args.duration * sample_rate)
    amplitude = 0.35

    with wave.open(str(output), "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(sample_rate)

        frames = bytearray()
        for i in range(total_samples):
            t = i / sample_rate
            freq = 440.0 if t < args.duration / 2 else 880.0
            envelope = min(1.0, i / 800, (total_samples - i) / 800)
            value = amplitude * envelope * math.sin(2.0 * math.pi * freq * t)
            frames += int(max(-1.0, min(1.0, value)) * 32767).to_bytes(
                2, byteorder="little", signed=True
            )

        wav.writeframes(bytes(frames))

    print(output)


if __name__ == "__main__":
    main()

