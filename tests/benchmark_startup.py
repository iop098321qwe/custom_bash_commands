#!/usr/bin/env python3
"""Measure CBC in fresh Bash processes without loading host shell profiles.

Example: python3 tests/benchmark_startup.py --runs 40 --modules /path/modules
Pass multiple --script paths to interleave baseline and candidate measurements.
Module entrypoints execute in the fixture shell; select trusted modules only.
"""

import argparse
import json
import math
import os
from pathlib import Path
import statistics
import subprocess
import tempfile
import time


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--script", action="append", type=Path)
    parser.add_argument("--modules", type=Path)
    parser.add_argument("--aliases", type=Path)
    parser.add_argument("--case", action="append", choices=[
        "quiet", "plain-full", "gum-minimal", "gum-full"
    ])
    parser.add_argument(
        "--command", nargs=argparse.REMAINDER,
        help="measure first/repeated use; pass this option last",
    )
    parser.add_argument("--runs", type=int, default=40)
    parser.add_argument("--shell-startup", action="store_true",
                        help="opt in to executing the real ~/.bashrc")
    args = parser.parse_args()
    if args.runs < 5:
        parser.error("--runs must be at least 5")
    scripts = [p.resolve(strict=True) for p in args.script or [
        Path(__file__).resolve().parents[1] / "custom_bash_commands.sh"
    ]]
    env = os.environ.copy()
    for key in list(env):
        if key.startswith(("CBC_", "BASH_FUNC_")) or key in (
            "BASH_ENV", "ENV", "SHELLOPTS", "BASHOPTS"
        ):
            env.pop(key)
    env.update(TERM="xterm-256color", LC_ALL="C.UTF-8")
    if args.shell_startup:
        # Intercept only the installed CBC source, keeping all other host
        # startup work identical. No shell configuration files are changed.
        env["BASH_FUNC_source%%"] = (
            '() { if [[ "$1" == "$HOME/.custom_bash_commands.sh" ]]; then '
            'CBC_BENCH_SOURCE_COUNT=$(( ${CBC_BENCH_SOURCE_COUNT:-0} + 1 )); '
            'builtin source "$CBC_BENCH_SCRIPT" "${@:2}"; else '
            'builtin source "$@"; fi; }'
        )
        samples = {str(p): [] for p in scripts}
        for iteration in range(args.runs + 3):
            order = scripts if iteration % 2 == 0 else scripts[::-1]
            for script in order:
                env["CBC_BENCH_SCRIPT"] = str(script)
                start = time.perf_counter_ns()
                subprocess.run(
                    ["bash", "--noprofile", "-ic",
                     '[[ ${CBC_BENCH_SOURCE_COUNT:-0} -gt 0 ]]'],
                    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                    env=env, timeout=30, check=True,
                )
                if iteration >= 3:
                    samples[str(script)].append(
                        (time.perf_counter_ns() - start) / 1_000_000
                    )
        print(json.dumps({
            "runs": args.runs,
            "scope": "real bashrc startup plus exit; no first prompt",
            "results": {script: {
                "median_ms": round(statistics.median(values), 3),
                "p95_ms": round(sorted(values)[
                    math.ceil(len(values) * 0.95) - 1
                ], 3),
            } for script, values in samples.items()},
        }, indent=2))
        return
    cases = [
        ("quiet", "false", "false", "full"),
        ("plain-full", "false", "true", "full"),
    ]
    if subprocess.run(
        ["bash", "--noprofile", "--norc", "-c", "command -v gum"],
        capture_output=True, env=env
    ).returncode == 0:
        cases.extend([
            ("gum-minimal", "auto", "true", "minimal"),
            ("gum-full", "auto", "true", "full"),
        ])
    if args.case:
        cases = [case for case in cases if case[0] in args.case]
    results = {}
    with tempfile.TemporaryDirectory(prefix="cbc-benchmark-") as directory:
        home = Path(directory)
        config = home / ".config/cbc"
        config.mkdir(parents=True)
        (home / ".cbc_aliases.sh").write_bytes(
            args.aliases.read_bytes() if args.aliases else b""
        )
        env.update(HOME=str(home), CBC_CONFIG_DIR=str(config))
        if args.modules:
            env["CBC_MODULE_ROOT"] = str(args.modules.resolve(strict=True))
        # EPOCHREALTIME measures sourcing alone; wall time includes fresh Bash.
        command = (
            'start=$EPOCHREALTIME; source "$1" >/dev/null; status=$?; '
            'end=$EPOCHREALTIME; '
            'printf "CBC_TIMING %s %s %s\\n" "$start" "$end" "$status"'
        )
        if args.command:
            command += (
                '; for phase in first repeated; do '
                'start=$EPOCHREALTIME; "$2" "${@:3}" >/dev/null; status=$?; '
                'end=$EPOCHREALTIME; '
                'printf "CBC_COMMAND %s %s %s %s\\n" '
                '"$phase" "$start" "$end" "$status"; done'
            )
        for case, gum, banner, mode in cases:
            (config / "cbc.config").write_text(
                f"CBC_USE_GUM={gum}\nCBC_SHOW_BANNER={banner}\n"
                f"CBC_BANNER_MODE={mode}\nCBC_SOURCE_BASH_ALIASES=false\n"
            )
            kinds = ["source", "process"]
            if args.command:
                kinds.extend(["first", "repeated"])
            samples = {str(p): {kind: [] for kind in kinds} for p in scripts}
            for iteration in range(args.runs + 3):
                # Alternate order to reduce systematic thermal/order bias.
                order = scripts if iteration % 2 == 0 else scripts[::-1]
                for script in order:
                    start = time.perf_counter_ns()
                    process = subprocess.run(
                        ["bash", "--noprofile", "--norc", "-ic",
                        command, "_", str(script), *(args.command or [])],
                        capture_output=True, text=True, env=env, timeout=30,
                    )
                    elapsed = (time.perf_counter_ns() - start) / 1_000_000
                    lines = [line for line in process.stdout.splitlines()
                             if line.startswith("CBC_TIMING ")]
                    if process.returncode or len(lines) != 1:
                        raise RuntimeError(process.stderr + process.stdout)
                    _, before, after, status = lines[0].split()
                    if status != "0":
                        raise RuntimeError(f"source failed: {script}: {status}")
                    if iteration >= 3:
                        sample = samples[str(script)]
                        sample["source"].append(
                            (float(after) - float(before)) * 1000
                        )
                        sample["process"].append(elapsed)
                        if args.command:
                            for line in process.stdout.splitlines():
                                if not line.startswith("CBC_COMMAND "):
                                    continue
                                _, phase, before, after, status = line.split()
                                if status != "0":
                                    raise RuntimeError(
                                        f"command failed: {phase}: {status}"
                                    )
                                sample[phase].append(
                                    (float(after) - float(before)) * 1000
                                )
            results[case] = {}
            for script, timings in samples.items():
                results[case][script] = {
                    kind: {
                        "median_ms": round(statistics.median(values), 3),
                        "p95_ms": round(sorted(values)[
                            math.ceil(len(values) * 0.95) - 1
                        ], 3),
                    }
                    for kind, values in timings.items()
                }
    print(json.dumps({"runs": args.runs, "results": results}, indent=2))


if __name__ == "__main__":
    main()
