#!/usr/bin/env bash
# Copyright (c) 2026 Kartik Deepak Sormare (kkisdevil) — UN1CA Universal
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Validate a device definition in devices/<codename>.json.
#
# Usage:
#   scripts/validate-device.sh <devices/<codename>.json> [--check-upstream]
#   --check-upstream  also query the GitHub API (unauthenticated) to
#                     verify source_repo/source_branch exist and that
#                     target/<codename>/ exists in that branch.
#                     Needs network; skipped by default.
#                     When GH_TOKEN or GITHUB_TOKEN is set (GitHub Actions
#                     provides it), the API calls are authenticated, which
#                     raises the limit from 60/hr per IP to 1000/hr.
#                     A persistent 403/429 (rate limit) is NOT a validation
#                     failure: it only warns and skips the upstream check,
#                     because the branch/target were verified when the
#                     device file was written and the build itself will
#                     fail loudly if the branch really does not exist.
#                     Only a 404 fails the check.
#                     (Build ROM #1, 2026-11-24 00:31 IST, failed in 45s:
#                     unauthenticated API returned 403 three times and the
#                     old code treated it as a hard failure.)
#
# Checks (no network unless --check-upstream):
#   - file exists and is valid JSON (python3 -m json.tool, or jq)
#   - filename stem matches the "codename" field
#   - required fields are present and non-empty:
#       codename, model, target_name, target_firmware,
#       target_platform_sdk_version, source_repo, source_branch,
#       source_firmware, source_platform_sdk_version
#   - firmware strings match MODEL/CSC/IMEI, e.g. SM-M515F/BVO/357563172596302
#   - SDK / API levels and partition sizes (when present) are integers > 0
#   - target_extra_firmwares (when present) is a list of firmware strings
#   - SoC family (soc_detail.family, else soc.family, else the manifest
#     lookup by codename) exists in devices/soc-families.json
# Exit 0 on success, 1 with a message on the first failure.
set -euo pipefail

CHECK_UPSTREAM=false
FILE=""
while [ "$#" -gt 0 ]; do
    case "$1" in
        --check-upstream) CHECK_UPSTREAM=true ;;
        --help|-h)
            echo "Usage: $0 <devices/<codename>.json> [--check-upstream]"
            exit 0
            ;;
        --*) echo "Unknown option: $1" >&2; exit 1 ;;
        *) FILE="$1" ;;
    esac
    shift
done

[ -n "$FILE" ] || { echo "No device file given" >&2; exit 1; }
[ -f "$FILE" ] || { echo "Device file not found: $FILE" >&2; exit 1; }

command -v python3 >/dev/null 2>&1 || { echo "python3 is required" >&2; exit 1; }
python3 -m json.tool "$FILE" >/dev/null || { echo "Invalid JSON: $FILE" >&2; exit 1; }

get() { python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d.get(sys.argv[2], ''))" "$FILE" "$1"; }

CODENAME="$(get codename)"
BASENAME="$(basename "$FILE" .json)"
[ -n "$CODENAME" ] || { echo "Missing field: codename" >&2; exit 1; }
[ "$CODENAME" = "$BASENAME" ] || {
    echo "codename '$CODENAME' does not match filename '$BASENAME.json'" >&2; exit 1; }

for field in model target_name target_firmware source_repo source_branch source_firmware; do
    [ -n "$(get "$field")" ] || { echo "Missing/empty field: $field" >&2; exit 1; }
done

for field in target_platform_sdk_version source_platform_sdk_version; do
    v="$(get "$field")"
    case "$v" in
        ''|*[!0-9]*) echo "Field $field must be a positive integer, got: '$v'" >&2; exit 1 ;;
    esac
done

# Firmware strings are MODEL/CSC/IMEI, e.g. SM-M515F/BVO/357563172596302
FW_RE='^[A-Z0-9-]+/[A-Z0-9]+/[0-9]{15}$'
check_fw() {
    case "$1" in
        '' ) echo "Empty firmware string" >&2; exit 1 ;;
    esac
    if ! printf '%s' "$1" | grep -Eq "$FW_RE"; then
        echo "Firmware string does not match MODEL/CSC/IMEI: $1" >&2; exit 1
    fi
}
check_fw "$(get target_firmware)"
check_fw "$(get source_firmware)"
python3 -c "
import json, re, sys
d = json.load(open(sys.argv[1]))
pat = re.compile(r'^[A-Z0-9-]+/[A-Z0-9]+/[0-9]{15}$')
for fw in d.get('target_extra_firmwares', []):
    if not pat.match(fw):
        print(f'Bad extra firmware: {fw}', file=sys.stderr); sys.exit(1)
for k, v in d.items():
    if k.endswith('_partition_size') or k.endswith('_partitions_size'):
        if not isinstance(v, int) or v <= 0:
            print(f'Field {k} must be a positive integer, got: {v}', file=sys.stderr); sys.exit(1)
" "$FILE"

# SoC family must exist in the porter manifest (devices/soc-families.json).
# The family is read from soc_detail.family, else soc.family, else the
# family whose devices list contains this codename. If the manifest is
# missing (e.g. this script run standalone elsewhere), warn and skip
# rather than failing — the manifest check runs in CI where it exists.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MANIFEST="$SCRIPT_DIR/../devices/soc-families.json"
if [ -f "$MANIFEST" ]; then
    FAMILY="$(python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
m = json.load(open(sys.argv[2]))
detail = d.get('soc_detail') or {}
if isinstance(detail, dict) and detail.get('family'):
    print(detail['family']); sys.exit(0)
soc = d.get('soc')
if isinstance(soc, dict) and soc.get('family'):
    print(soc['family']); sys.exit(0)
for fam, info in m.get('families', {}).items():
    if d.get('codename') in info.get('devices', []):
        print(fam); sys.exit(0)
print('')
" "$FILE" "$MANIFEST")"
    if [ -z "$FAMILY" ]; then
        echo "Cannot determine SoC family for $CODENAME" >&2; exit 1
    fi
    if ! python3 -c "import json,sys; sys.exit(0 if sys.argv[2] in json.load(open(sys.argv[1])).get('families', {}) else 1)" "$MANIFEST" "$FAMILY"; then
        echo "SoC family '$FAMILY' for $CODENAME is not in $MANIFEST" >&2
        echo "Known families: $(python3 -c "import json,sys; print(', '.join(sorted(json.load(open(sys.argv[1]))['families'])))" "$MANIFEST")" >&2
        exit 1
    fi
    echo "SoC family: $FAMILY"
else
    echo "WARNING: SoC manifest not found at $MANIFEST — family check skipped" >&2
fi

if $CHECK_UPSTREAM; then
    command -v curl >/dev/null 2>&1 || { echo "curl is required for --check-upstream" >&2; exit 1; }
    REPO="$(get source_repo)"
    BRANCH="$(get source_branch)"
    # FIX (round 2 of the local fix loop): an earlier version used
    # `curl -fsSL ... || echo "branch not found"`, which misreported
    # a transient GitHub API 504 as a missing branch. Transient
    # failures (network error, HTTP 5xx, rate-limit 403/429) are
    # retried 3 times; only a 404 means "not found".
    # Authenticate when a token is available (GitHub Actions provides
    # GH_TOKEN / GITHUB_TOKEN). Unauthenticated calls share the 60/hr
    # per-IP limit and get HTTP 403 on busy runners — that is a rate
    # limit, not a missing branch, so it must never fail the build.
    AUTH_ARGS=()
    if [ -n "${GH_TOKEN:-}" ]; then
        AUTH_ARGS=(-H "Authorization: Bearer $GH_TOKEN")
    elif [ -n "${GITHUB_TOKEN:-}" ]; then
        AUTH_ARGS=(-H "Authorization: Bearer $GITHUB_TOKEN")
    fi
    github_api_code() {
        local url="$1" attempt=1 code="000"
        while [ "$attempt" -le 3 ]; do
            code="$(curl -s -o /dev/null -w "%{http_code}" --max-time 30 "${AUTH_ARGS[@]}" "$url" 2>/dev/null)" || code="000"
            case "$code" in
                200|404) echo "$code"; return 0 ;;
                *) echo "Attempt $attempt: $url -> HTTP $code, retrying..." >&2
                   sleep $((attempt * 5)); attempt=$((attempt + 1)) ;;
            esac
        done
        echo "$code"
    }
    echo "Checking upstream $REPO@$BRANCH ..."
    SKIP_UPSTREAM=""
    CODE="$(github_api_code "https://api.github.com/repos/$REPO/branches/$BRANCH")"
    case "$CODE" in
        200) ;;
        404) echo "Upstream branch not found: $REPO@$BRANCH" >&2; exit 1 ;;
        *) echo "WARNING: upstream branch check inconclusive (HTTP $CODE — GitHub API rate limit / transient error); skipping upstream verification — the build will fail later if the branch really does not exist" >&2; SKIP_UPSTREAM=1 ;;
    esac
    if [ -z "$SKIP_UPSTREAM" ]; then
        CODE="$(github_api_code "https://api.github.com/repos/$REPO/contents/target/$CODENAME?ref=$BRANCH")"
        case "$CODE" in
            200) ;;
            404) echo "Upstream target not found: $REPO target/$CODENAME@$BRANCH" >&2; exit 1 ;;
            *) echo "WARNING: upstream target check inconclusive (HTTP $CODE); skipping upstream verification" >&2; SKIP_UPSTREAM=1 ;;
        esac
    fi
    [ -z "$SKIP_UPSTREAM" ] && echo "Upstream OK: $REPO@$BRANCH target/$CODENAME exists"
fi

echo "OK: $FILE (codename $CODENAME, model $(get model))"
