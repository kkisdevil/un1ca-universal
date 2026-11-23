#!/usr/bin/env bash
# Copyright (c) 2026 Kartik Deepak Sormare (kkisdevil) — UN1CA Universal
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Set up the UN1CA build environment.
#
# This mirrors, verbatim where possible, the "Set up build environment"
# step of upstream CI:
#   - salvogiangri/UN1CA, .github/workflows/ci.yml (branch sixteen)
#   - Arnav3078/UN1CA-SM7150, .github/workflows/ci.yml (branch seventeen)
#     and .github/workflows/build-gofile.yml
#
# Upstream apt list (Arnav seventeen, the default source for m51):
#   attr ccache clang ffmpeg gh libbrotli-dev libbz2-dev libgtest-dev
#   libprotobuf-dev libunwind-dev libpcre2-dev libzstd-dev lld
#   protobuf-compiler webp jq curl python3
# Base UN1CA (sixteen) instead installs:
#   attr ccache clang ffmpeg libbrotli-dev libbz2-dev libgtest-dev
#   libprotobuf-dev libunwind-dev libpcre2-dev libzstd-dev
#   linux-modules-extra-$(uname -r) lld protobuf-compiler webp
# and runs `sudo modprobe erofs f2fs` (Arnav: `|| true`).
# JDK 17 (Temurin) is NOT installed here — the workflow installs it with
# actions/setup-java@v6, exactly as upstream does, and checks
# `java -version` right after that step.
#
# Usage:
#   scripts/setup-tools.sh [--check-only] [--with-linux-modules-extra]
#   --check-only  verify the required commands exist, install nothing.
#                 Exit 0 only if every required tool is present.
#   PLATFORM_KEY_PK8 / PLATFORM_KEY_PEM (base64, optional in dry-run):
#   if both are set in the environment, they are decoded to
#   security/unica_platform.pk8 and security/unica_platform.x509.pem
#   in the upstream checkout, exactly as upstream CI does.
#   If they are absent, this script warns and continues — a full build
#   will fail later at signing, a dry-run will not.
set -euo pipefail

CHECK_ONLY=false
WITH_LINUX_MODULES_EXTRA=false
while [ "$#" -gt 0 ]; do
    case "$1" in
        --check-only) CHECK_ONLY=true ;;
        --with-linux-modules-extra) WITH_LINUX_MODULES_EXTRA=true ;;
        --help|-h)
            echo "Usage: $0 [--check-only] [--with-linux-modules-extra]"
            exit 0
            ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

# Tools upstream CI needs on PATH (apt packages + runners' defaults).
# NOTE: `java` is deliberately NOT in this list. JDK 17 (Temurin) is
# installed by actions/setup-java@v6 in the workflow AFTER this script
# runs, so a final re-check here must not require it — an earlier
# version of this script did, and would have failed every CI run at
# this step even with all apt packages installed. The workflow checks
# `java -version` right after setup-java instead.
REQUIRED_CMDS=(attr ccache clang ffmpeg gh git jq curl python3 lld protoc)
MISSING=()
for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        MISSING+=("$cmd")
    fi
done

if $CHECK_ONLY; then
    if [ "${#MISSING[@]}" -gt 0 ]; then
        echo "Missing tools: ${MISSING[*]}" >&2
        echo "Install them with: $0   (or run the build workflow, which does it)"
        exit 1
    fi
    echo "All required tools present: ${REQUIRED_CMDS[*]}"
    exit 0
fi

if [ "$(id -u)" -ne 0 ] && ! command -v sudo >/dev/null 2>&1; then
    echo "Need root or sudo to install apt packages; run with sudo or use --check-only" >&2
    exit 1
fi

APT_PKGS=(attr ccache clang ffmpeg gh libbrotli-dev libbz2-dev libgtest-dev
    libprotobuf-dev libunwind-dev libpcre2-dev libzstd-dev lld
    protobuf-compiler webp jq curl python3)
if $WITH_LINUX_MODULES_EXTRA; then
    APT_PKGS+=("linux-modules-extra-$(uname -r)")
fi

echo "Installing apt packages: ${APT_PKGS[*]}"
sudo apt update
DEBIAN_FRONTEND=noninteractive sudo apt install -yq "${APT_PKGS[@]}"

# Upstream: modprobe erofs f2fs (Arnav: '|| true' — the modules may
# already be built in on GitHub-hosted runners).
sudo modprobe erofs || true
sudo modprobe f2fs || true

git config --global user.name "github-actions[bot]" || true
git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com" || true

# Platform signing keys — upstream CI decodes these two secrets.
# Absent in dry-run: warn, do not fail here.
if [ -n "${PLATFORM_KEY_PK8:-}" ] && [ -n "${PLATFORM_KEY_PEM:-}" ]; then
    echo "Decoding platform signing keys into security/"
    mkdir -p security
    echo -n "$PLATFORM_KEY_PK8" | base64 --decode > security/unica_platform.pk8
    echo -n "$PLATFORM_KEY_PEM" | base64 --decode > security/unica_platform.x509.pem
    chmod 600 security/unica_platform.pk8 security/unica_platform.x509.pem
else
    echo "WARNING: PLATFORM_KEY_PK8 / PLATFORM_KEY_PEM not set —" \
        "full build will fail at signing; dry-run continues." >&2
fi

echo "Setup complete. Re-checking tools:"
"$0" --check-only
