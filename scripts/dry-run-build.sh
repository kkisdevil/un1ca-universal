#!/usr/bin/env bash
# Copyright (c) 2026 Kartik Deepak Sormare (kkisdevil) — UN1CA Universal
# SPDX-License-Identifier: GPL-3.0-or-later
#
# dry-run-build.sh — prove a device's build config is valid WITHOUT
# downloading any firmware.
#
# Usage:
#   scripts/dry-run-build.sh <codename> [source_repo] [source_branch]
#
#   codename     e.g. m51
#   source_repo  e.g. Arnav3078/UN1CA-SM7150 (default)
#   source_branch e.g. seventeen (default)
#
# What it does:
#   1. Sparse-clones the upstream fork (blob-less, depth 1) — only
#      buildenv.sh, scripts/, unica/configs/, target/<codename>/ and
#      platform/ are checked out. No firmware, no blobs, no APKs.
#   2. Sources buildenv.sh <codename>, which runs
#      scripts/internal/gen_config_file.sh and writes out/config.sh.
#   3. Verifies out/config.sh exists and contains the variables a real
#      build needs (TARGET_CODENAME, TARGET_FIRMWARE, SOURCE_FIRMWARE,
#      TARGET_OS_SINGLE_SYSTEM_IMAGE, ROM_VERSION).
#
# What it deliberately does NOT do:
#   download_fw.sh, extract_fw.sh, make_rom.sh — no firmware is ever
#   downloaded, extracted or patched here. A green dry-run means "the
#   config is coherent and the upstream tree is reachable", not "the
#   ROM builds". The full build is .github/workflows/build.yml.
#
# Failure mode (modify-and-fix loop): any failure prints
#   ERROR: <what> — <file or step>
# and exits non-zero, so test.yml can surface the exact file and error.

set -euo pipefail

CODENAME="${1:-}"
SOURCE_REPO="${2:-Arnav3078/UN1CA-SM7150}"
SOURCE_BRANCH="${3:-seventeen}"

if [ -z "$CODENAME" ]; then
    echo "ERROR: no codename given — usage: $0 <codename> [source_repo] [source_branch]" >&2
    exit 2
fi

# Required variables a real build needs from out/config.sh.
REQUIRED_VARS=(
    TARGET_CODENAME
    TARGET_FIRMWARE
    SOURCE_FIRMWARE
    TARGET_OS_SINGLE_SYSTEM_IMAGE
    ROM_VERSION
)

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "== dry-run: $CODENAME from $SOURCE_REPO@$SOURCE_BRANCH =="
echo "work dir: $WORK"

echo "-- sparse clone (blob-less, depth 1) --"
git clone --filter=blob:none --depth 1 --branch "$SOURCE_BRANCH" \
    "https://github.com/$SOURCE_REPO.git" "$WORK/tree" \
    || { echo "ERROR: clone failed — repo/branch not reachable: $SOURCE_REPO@$SOURCE_BRANCH" >&2; exit 1; }

cd "$WORK/tree"
# NOTE: cone-mode sparse-checkout only accepts directories, and
# buildenv.sh is a FILE at the repo root — `git sparse-checkout set
# buildenv.sh ...` fails with "fatal: 'buildenv.sh' is not a directory".
# Use --no-cone so file patterns are accepted.
git sparse-checkout set --no-cone \
    '/buildenv.sh' \
    '/scripts/*' \
    '/unica/configs/*' \
    "/target/$CODENAME/*" \
    '/platform/*' \
    || { echo "ERROR: sparse-checkout failed — could not check out buildenv.sh/scripts/target/$CODENAME in $SOURCE_REPO@$SOURCE_BRANCH" >&2; exit 1; }

if [ ! -f buildenv.sh ]; then
    echo "ERROR: buildenv.sh not checked out in $SOURCE_REPO@$SOURCE_BRANCH" >&2
    exit 1
fi

if [ ! -f "target/$CODENAME/config.sh" ]; then
    echo "ERROR: target/$CODENAME/config.sh not found in $SOURCE_REPO@$SOURCE_BRANCH" >&2
    exit 1
fi

echo "-- source buildenv.sh $CODENAME --"
# buildenv.sh prints the generated config; capture it for the log.
# It must exit 0 — gen_config_file.sh fails if TARGET_OS_SINGLE_SYSTEM_IMAGE
# is unset or its config file is missing, and buildenv.sh returns 1 then.
# shellcheck disable=SC1091
if ! source ./buildenv.sh "$CODENAME" > "$WORK/buildenv.log" 2>&1; then
    echo "ERROR: buildenv.sh $CODENAME failed — see log below" >&2
    cat "$WORK/buildenv.log" >&2
    if [ -n "${DRY_RUN_LOG_DIR:-}" ]; then
        mkdir -p "$DRY_RUN_LOG_DIR"
        cp "$WORK/buildenv.log" "$DRY_RUN_LOG_DIR/buildenv-$CODENAME.log"
    fi
    exit 1
fi
cat "$WORK/buildenv.log"

if [ -n "${DRY_RUN_LOG_DIR:-}" ]; then
    mkdir -p "$DRY_RUN_LOG_DIR"
    cp "$WORK/buildenv.log" "$DRY_RUN_LOG_DIR/buildenv-$CODENAME.log"
fi

CONFIG="$WORK/tree/out/config.sh"
if [ ! -f "$CONFIG" ]; then
    echo "ERROR: out/config.sh was not generated for $CODENAME" >&2
    exit 1
fi

echo "-- verify out/config.sh --"
MISSING=0
for var in "${REQUIRED_VARS[@]}"; do
    if grep -q "^${var}=" "$CONFIG"; then
        echo "  ok: $var=$(grep "^${var}=" "$CONFIG" | head -1 | cut -d= -f2-)"
    else
        echo "ERROR: out/config.sh is missing required variable: $var (device $CODENAME, $SOURCE_REPO@$SOURCE_BRANCH)" >&2
        MISSING=1
    fi
done

# The generated codename must be the one we asked for — a mismatch means
# the target config and the device file disagree.
if ! grep -q "^TARGET_CODENAME=\"$CODENAME\"$" "$CONFIG"; then
    echo "ERROR: TARGET_CODENAME in out/config.sh is not \"$CODENAME\" — target config mismatch for $CODENAME" >&2
    MISSING=1
fi

if [ "$MISSING" -ne 0 ]; then
    exit 1
fi

echo "== dry-run OK: $CODENAME ($SOURCE_REPO@$SOURCE_BRANCH) — no firmware downloaded =="
exit 0
