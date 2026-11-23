#!/usr/bin/env python3
# Copyright (c) 2026 Kartik Deepak Sormare (kkisdevil) — UN1CA Universal
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Resolve which upstream UN1CA fork/branch to build a device from.
#
# This is the universal porter's decision point. The build workflow
# does NOT hard-code a fork per device: it calls this script, and this
# script reads the device's JSON plus devices/soc-families.json.
#
# Resolution order:
#   1. Explicit override wins: --repo / --branch (or "auto" = no override).
#      The workflow passes the user's workflow_dispatch inputs here.
#   2. Otherwise the device JSON's primary upstream: its top-level
#      source_repo / source_branch fields (m51.json: Arnav seventeen).
#      If those are absent, the upstream[] entry whose note says
#      "Primary", else the first upstream[] entry.
#   3. The SoC family comes from the device JSON (soc_detail.family,
#      else soc.family, else the family in soc-families.json whose
#      devices list contains the codename). If the family is not in
#      soc-families.json, this script fails — add the family there
#      first, from the real upstream target/ files.
#
# Usage:
#   scripts/resolve-device.py devices/m51.json [--repo auto] [--branch auto]
#       [--manifest devices/soc-families.json]
# Output: KEY=VALUE lines on stdout (soc_family, source_repo,
# source_branch, unica_version, model, codename). When GITHUB_OUTPUT
# is set (GitHub Actions), the same pairs are also appended there.
# Exit 0 on success, 1 with a message on the first failure.
# No network is used; --check-upstream is validate-device.sh's job.
import argparse
import json
import os
import sys


def load_json(path):
    with open(path) as f:
        return json.load(f)


def device_family(device, manifest):
    detail = device.get("soc_detail")
    if isinstance(detail, dict) and detail.get("family"):
        return detail["family"]
    soc = device.get("soc")
    if isinstance(soc, dict) and soc.get("family"):
        return soc["family"]
    codename = device.get("codename", "")
    for family, info in manifest.get("families", {}).items():
        if codename in info.get("devices", []):
            return family
    return ""


def primary_upstream(device):
    repo = device.get("source_repo") or ""
    branch = device.get("source_branch") or ""
    version = device.get("unica_version") or ""
    if repo and branch:
        return repo, branch, version
    entries = device.get("upstream") or []
    for entry in entries:
        if "primary" in (entry.get("note") or "").lower():
            return entry["repo"], entry["branch"], entry.get("unica_version", "")
    if entries:
        first = entries[0]
        return first["repo"], first["branch"], first.get("unica_version", "")
    return "", "", ""


def main():
    parser = argparse.ArgumentParser(description="Resolve a device to its upstream UN1CA fork/branch.")
    parser.add_argument("device_file")
    parser.add_argument("--repo", default="auto")
    parser.add_argument("--branch", default="auto")
    parser.add_argument("--manifest", default=None)
    args = parser.parse_args()

    try:
        device = load_json(args.device_file)
    except (OSError, json.JSONDecodeError) as e:
        print(f"Cannot read device file {args.device_file}: {e}", file=sys.stderr)
        return 1

    codename = device.get("codename") or ""
    if not codename:
        print("Device file has no codename", file=sys.stderr)
        return 1

    manifest_path = args.manifest
    if manifest_path is None:
        here = os.path.dirname(os.path.abspath(__file__))
        manifest_path = os.path.join(here, "..", "devices", "soc-families.json")
    try:
        manifest = load_json(manifest_path)
    except (OSError, json.JSONDecodeError) as e:
        print(f"Cannot read SoC manifest {manifest_path}: {e}", file=sys.stderr)
        return 1

    family = device_family(device, manifest)
    if not family:
        print(f"Cannot determine SoC family for {codename}", file=sys.stderr)
        return 1
    families = manifest.get("families", {})
    if family not in families:
        print(
            f"SoC family '{family}' for {codename} is not in {manifest_path}. "
            f"Known families: {', '.join(sorted(families))}. "
            "Add the family there first, from the real upstream target/ files.",
            file=sys.stderr,
        )
        return 1

    repo, branch, version = primary_upstream(device)
    overridden = False
    if args.repo and args.repo != "auto":
        repo = args.repo
        overridden = True
    if args.branch and args.branch != "auto":
        branch = args.branch
        overridden = True
    if not repo or not branch:
        print(f"No upstream fork/branch resolved for {codename}", file=sys.stderr)
        return 1
    if overridden:
        # The device's top-level unica_version belongs to its primary
        # upstream, not to the override. Look the version up from the
        # matching upstream[] entry, else from the family's manifest
        # entries; if nothing matches, the version is unknown.
        version = ""
        for entry in device.get("upstream") or []:
            if entry.get("repo") == repo and entry.get("branch") == branch:
                version = entry.get("unica_version", "")
                break
        if not version:
            for key in ("primary_upstream", "alternative_upstream"):
                entry = families[family].get(key, {})
                if entry.get("repo") == repo and entry.get("branch") == branch:
                    version = entry.get("unica_version", "")
                    break
        if not version:
            print(
                f"Warning: unica_version unknown for override {repo}@{branch}; "
                "it does not match any upstream entry for this device or family.",
                file=sys.stderr,
            )
    elif not version:
        version = families[family].get("primary_upstream", {}).get("unica_version", "")

    out = {
        "codename": codename,
        "model": device.get("model", ""),
        "soc_family": family,
        "soc_family_status": families[family].get("status", ""),
        "source_repo": repo,
        "source_branch": branch,
        "unica_version": version,
    }
    text = "".join(f"{k}={v}\n" for k, v in out.items())
    sys.stdout.write(text)
    github_output = os.environ.get("GITHUB_OUTPUT")
    if github_output:
        with open(github_output, "a") as f:
            f.write(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
