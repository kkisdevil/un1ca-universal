#!/usr/bin/env python3
# Copyright (c) 2026 Kartik Deepak Sormare (kkisdevil) — UN1CA Universal
# SPDX-License-Identifier: GPL-3.0-or-later
#
# validate-patches.py — fail loudly on a bad patch or patch module.
#
# Checks every module under patches/:
#   * module.prop exists and has non-empty id / name / author
#     (author is the credit — never empty, never stripped)
#   * module ids are unique
#   * every *.patch parses: `git apply --stat` succeeds, and the file
#     has a Subject: line and a `diff --git` header
#     (NOTE: `git apply --check` is NOT used here — it needs the decoded
#     target files to exist, which they do not in this repo. A --check
#     failure of "No such file or directory" is not a bad patch; see
#     patches/README.md section 5, failure #8.)
#   * no patch contains CRLF line endings (they break git apply) or a
#     leftover CHANGEME placeholder
#   * every smali/ patch path starts with a valid partition
#     (system, system_ext, product, vendor, odm)
#   * every customize.sh passes `bash -n`
#
# Every failure is printed as a GitHub Actions annotation with the exact
# file, so the modify-and-fix loop can target it:
#   ::error file=<path>::<message>
# Exits 1 if anything failed, 0 if all green. Usage: python3 scripts/validate-patches.py

import os
import re
import subprocess
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PATCHES_DIR = os.path.join(REPO_ROOT, "patches")
VALID_PARTITIONS = {"system", "system_ext", "product", "vendor", "odm"}

errors = []


def error(path, message):
    rel = os.path.relpath(path, REPO_ROOT) if os.path.isabs(path) else path
    errors.append((rel, message))
    print(f"::error file={rel}::{message}")


def read_text(path):
    with open(path, "rb") as f:
        return f.read()


def main():
    if not os.path.isdir(PATCHES_DIR):
        print(f"::error file=patches::patches/ directory missing")
        return 1

    modules = sorted(
        d for d in os.listdir(PATCHES_DIR)
        if os.path.isdir(os.path.join(PATCHES_DIR, d))
    )
    if not modules:
        error(PATCHES_DIR, "patches/ has no module directories — expected at least one (e.g. network-speed)")
        return 1

    seen_ids = {}
    patch_count = 0

    for module in modules:
        moddir = os.path.join(PATCHES_DIR, module)
        prop_path = os.path.join(moddir, "module.prop")

        # --- module.prop ---
        # A missing module.prop is an error, but it must NOT hide the
        # rest of the module's checks: the patch files in the same module
        # may be broken too, and the modify-and-fix loop needs every
        # error in one run. (Caught by the negative test 2026-11-23:
        # an early `continue` here suppressed the patch errors.)
        props = {}
        if not os.path.isfile(prop_path):
            error(moddir, f"module '{module}' is missing module.prop "
                          "(upstream APPLY_MODULE fails with: File not found: .../module.prop)")
        else:
            for line in read_text(prop_path).decode("utf-8", errors="replace").splitlines():
                line = line.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                key, value = line.split("=", 1)
                props[key.strip()] = value.strip()
            for field in ("id", "name", "author"):
                if not props.get(field):
                    error(prop_path, f"module.prop is missing a non-empty '{field}' "
                                    f"(id/name/author are required — author is the credit)")
        mod_id = props.get("id", "")
        if mod_id:
            if mod_id in seen_ids:
                error(prop_path, f"duplicate module id '{mod_id}' — already used by "
                                f"patches/{seen_ids[mod_id]} (ids must be unique)")
            else:
                seen_ids[mod_id] = module

        # --- customize.sh syntax ---
        customize = os.path.join(moddir, "customize.sh")
        if os.path.isfile(customize):
            result = subprocess.run(["bash", "-n", customize],
                                    capture_output=True, text=True)
            if result.returncode != 0:
                error(customize, f"bash -n failed: {result.stderr.strip()}")

        # --- *.patch files ---
        for root, _dirs, files in os.walk(moddir):
            for fname in sorted(files):
                if not fname.endswith(".patch"):
                    continue
                patch_count += 1
                ppath = os.path.join(root, fname)
                data = read_text(ppath)
                try:
                    text = data.decode("utf-8")
                except UnicodeDecodeError:
                    error(ppath, "patch is not valid UTF-8 — git format-patch output is UTF-8")
                    continue
                if b"\r\n" in data or b"\r" in data:
                    error(ppath, "patch contains CR/CRLF line endings — git apply will fail; "
                                "convert to LF (dos2unix / sed -i 's/\\r$//')")
                if "CHANGEME" in text:
                    error(ppath, "patch still contains a CHANGEME placeholder — finish the patch first")
                if not re.search(r"^Subject:", text, re.MULTILINE):
                    error(ppath, "patch has no 'Subject:' header — not a git format-patch file")
                if "diff --git " not in text:
                    error(ppath, "patch has no 'diff --git' hunks — not a valid unified diff")
                # Parse check only — --check would need decoded target files,
                # which do not exist in this repo (see header comment).
                result = subprocess.run(["git", "apply", "--stat", ppath],
                                        capture_output=True, text=True)
                if result.returncode != 0:
                    error(ppath, f"git apply --stat failed — patch does not parse: "
                                f"{(result.stderr or result.stdout).strip()}")
                # smali/ partition check
                rel = os.path.relpath(ppath, moddir)
                parts = rel.split(os.sep)
                if "smali" in parts:
                    idx = parts.index("smali")
                    if idx + 1 >= len(parts):
                        error(ppath, "patch is directly under smali/ — expected "
                                    "smali/<partition>/<path>/<file>.apk|jar>/<patch>")
                    elif parts[idx + 1] not in VALID_PARTITIONS:
                        error(ppath, f"smali/ path starts with invalid partition "
                                    f"'{parts[idx + 1]}' — must be one of "
                                    f"{sorted(VALID_PARTITIONS)}")

    if patch_count == 0:
        error(PATCHES_DIR, "no *.patch files found under patches/ — expected at least one example patch")
        return 1

    print(f"validate-patches: {len(modules)} module(s), {patch_count} patch file(s), "
          f"{len(errors)} error(s)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
