#!/usr/bin/env python3
# Copyright (c) 2026 Kartik Deepak Sormare (kkisdevil) — UN1CA Universal
# SPDX-License-Identifier: GPL-3.0-or-later
#
# validate-workflows.py — check every workflow YAML in .github/workflows/.
#
# Checks:
#   * every *.yml / *.yaml parses as YAML (PyYAML)
#   * top-level keys present: name, on, jobs
#     (note: PyYAML parses the YAML 1.1 key `on:` as boolean True — both
#     spellings are accepted here)
#   * every job has a non-empty runs-on and at least one step
#   * every step has `run:` or `uses:` (a step with neither does nothing)
#   * every `scripts/...` path referenced by a step actually exists in
#     the repo (catches a workflow calling a script that was renamed)
#     — EXCEPT steps whose effective working-directory is not the repo
#     root (e.g. build.yml's `working-directory: upstream`, where
#     scripts/download_fw.sh is an upstream script inside the checked-out
#     fork, not a file in this repo)
#   * workflow names are unique
#
# Every failure is printed as a GitHub Actions annotation with the exact
# file, so the modify-and-fix loop can target it:
#   ::error file=<path>::<message>
# Exits 1 if anything failed, 0 if all green. Usage: python3 scripts/validate-workflows.py

import glob
import os
import re
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WORKFLOWS_DIR = os.path.join(REPO_ROOT, ".github", "workflows")

try:
    import yaml
except ImportError:
    print("::error file=scripts/validate-workflows.py::PyYAML is not installed — "
          "run: python3 -m pip install pyyaml")
    sys.exit(1)

errors = []


def error(path, message):
    rel = os.path.relpath(path, REPO_ROOT) if os.path.isabs(path) else path
    errors.append((rel, message))
    print(f"::error file={rel}::{message}")


def main():
    files = sorted(glob.glob(os.path.join(WORKFLOWS_DIR, "*.yml")) +
                   glob.glob(os.path.join(WORKFLOWS_DIR, "*.yaml")))
    if not files:
        error(WORKFLOWS_DIR, ".github/workflows/ has no workflow files")
        return 1

    names = {}
    for path in files:
        rel = os.path.relpath(path, REPO_ROOT)
        with open(path, "r", encoding="utf-8") as f:
            try:
                data = yaml.safe_load(f)
            except yaml.YAMLError as exc:
                error(path, f"YAML parse failed: {exc}")
                continue
        if not isinstance(data, dict):
            error(path, "workflow YAML does not parse to a mapping")
            continue

        # PyYAML reads the YAML 1.1 `on:` key as boolean True.
        has_on = "on" in data or True in data
        if not has_on:
            error(path, "workflow is missing the top-level 'on:' trigger")
        if "jobs" not in data or not isinstance(data["jobs"], dict) or not data["jobs"]:
            error(path, "workflow is missing a non-empty top-level 'jobs:' mapping")
            continue
        name = data.get("name") or os.path.basename(path)
        if name in names:
            error(path, f"duplicate workflow name '{name}' — already used by {names[name]}")
        else:
            names[name] = rel

        for job_id, job in data["jobs"].items():
            if not isinstance(job, dict):
                error(path, f"job '{job_id}' is not a mapping")
                continue
            if not job.get("runs-on"):
                error(path, f"job '{job_id}' is missing 'runs-on'")
            steps = job.get("steps")
            if not isinstance(steps, list) or not steps:
                error(path, f"job '{job_id}' has no steps")
                continue
            # Job-level default working directory (applies to all steps
            # that do not override it).
            job_wd = None
            defaults = job.get("defaults") or {}
            if isinstance(defaults, dict):
                run_defaults = defaults.get("run") or {}
                if isinstance(run_defaults, dict):
                    job_wd = run_defaults.get("working-directory")
            for i, step in enumerate(steps):
                if not isinstance(step, dict):
                    error(path, f"job '{job_id}' step {i} is not a mapping")
                    continue
                if "run" not in step and "uses" not in step:
                    error(path, f"job '{job_id}' step {i} has neither 'run:' nor 'uses:' — "
                               "it would do nothing")
                # Cross-check referenced scripts exist — but only when the
                # step runs in the repo root. A step with working-directory:
                # upstream (build.yml) references upstream's scripts, not
                # this repo's, so the check does not apply there.
                wd = step.get("working-directory") or job_wd
                at_repo_root = wd in (None, ".", "./", "${{ github.workspace }}",
                                     "$GITHUB_WORKSPACE")
                run_text = step.get("run") or ""
                if not at_repo_root:
                    continue
                for match in re.finditer(r"(?:^|[\s\"'])(scripts/[A-Za-z0-9_./-]+\.(?:sh|py))",
                                         run_text, re.MULTILINE):
                    script = match.group(1)
                    if not os.path.isfile(os.path.join(REPO_ROOT, script)):
                        error(path, f"job '{job_id}' step {i} references missing script "
                                   f"'{script}' — the workflow would fail at runtime")

    print(f"validate-workflows: {len(files)} workflow file(s), {len(errors)} error(s)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
