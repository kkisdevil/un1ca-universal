#!/usr/bin/env bash
# fetch-samloader-rs.sh - download the pinned samloader-rs release and
# verify its checksum. The firmware-download tool our porter will move to.
#
# Usage: bash scripts/fetch-samloader-rs.sh [<dest-dir>]
#   dest-dir : where to extract the samloader binary (default: ./samloader-rs)
#
# Why this tool: the old Python samloader (ananjaser1211/samloader) is gone
# from PyPI (404 since 2026-11-24) and Arnav's tree still calls it; the
# maintained replacement is samloader-rs (topjohnwu/samloader-rs), which
# needs no IMEI or serial number:
#   samloader download --model SM-M515F --region INS
# Pinned to v2.0.0 — the version Mehedi's UN1CA switch adopted and our
# deep-dive verified (research/09-arnav-un1ca.md §1.7; 08-mehedi-core.md
# §1.4). Newer releases exist (2.2.0 as of 2026-11-24) but are NOT pinned
# here until one is verified against the same flow.
#
# Open check (from the Mehedi dive): whether samloader-rs returns DXJ2
# for INS without an IMEI is still unproven — it still queries FUS, and
# a no-IMEI query returned a stale latest (DXE3) in our blob-refresh work.
# Verify the downloaded firmware version before trusting a build to it.
set -euo pipefail

DEST_DIR="${1:-./samloader-rs}"
URL="https://github.com/topjohnwu/samloader-rs/releases/download/2.0.0/samloader-v2.0.0-linux-x86_64.tar.xz"
EXPECTED_SHA256="7c6514028f20d5ea0eb57d6f872eee41b3a52336eabac6379b15a01a06ed7a79"
EXPECTED_SIZE=2328736

mkdir -p "$DEST_DIR"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Downloading samloader-rs v2.0.0 ..."
curl -fsSL -o "$TMP/samloader.tar.xz" "$URL"

ACTUAL_SIZE="$(wc -c < "$TMP/samloader.tar.xz")"
if [ "$ACTUAL_SIZE" != "$EXPECTED_SIZE" ]; then
    echo "::error::samloader-rs size mismatch: got $ACTUAL_SIZE, expected $EXPECTED_SIZE" >&2
    exit 1
fi
ACTUAL_SHA256="$(sha256sum "$TMP/samloader.tar.xz" | cut -d' ' -f1)"
if [ "$ACTUAL_SHA256" != "$EXPECTED_SHA256" ]; then
    echo "::error::samloader-rs SHA-256 mismatch: got $ACTUAL_SHA256, expected $EXPECTED_SHA256" >&2
    exit 1
fi
echo "Checksum OK (sha256 $EXPECTED_SHA256, $EXPECTED_SIZE bytes)."

tar -xJ -C "$DEST_DIR" -f "$TMP/samloader.tar.xz"
if [ ! -x "$DEST_DIR/samloader" ]; then
    echo "::error::samloader binary not found after extract in $DEST_DIR" >&2
    exit 1
fi
echo "samloader-rs v2.0.0 ready: $DEST_DIR/samloader"
"$DEST_DIR/samloader" --help 2>&1 | head -n 5 || true
