#!/usr/bin/env bash
# assert-60hz.sh - P0: fail the build if any 120 Hz leak survives into the
# built m51 ROM.
#
# Usage: bash scripts/assert-60hz.sh <work-dir>
#   work-dir : the assembled ROM work dir ($WORK_DIR, exported by the
#              workflow's "Generate build config" step). It holds the
#              patched files exactly as they are packed into the partition
#              images, so grepping it checks the built ROM without having
#              to unpack EROFS images out of the flashable zip (the
#              target-files zip contains partition images, not plain files).
#
# Checks (research/06c-frame-rate-60.md section 6, P0):
#   floating_feature.xml (system, and vendor if present):
#     SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE must be 60
#     SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_MODE must be 0
#     SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE must not
#       list any rate above 60 (expected value "0")
#   vendor/build.prop:
#     ro.surface_flinger.enable_frame_rate_override must not be true
#
# Exits 0 if all checks pass, 1 (with ::error:: annotations) otherwise.
# Local test: point it at a fake work dir with the same layout
# (system/system/etc/floating_feature.xml, vendor/build.prop) - see the
# pack README; both a passing tree and each failure case were exercised
# before this shipped.
set -euo pipefail

WORK_DIR="${1:?usage: assert-60hz.sh <work-dir>}"
FAILURES=0

fail() { echo "::error::$1" >&2; FAILURES=$((FAILURES + 1)); }
pass() { echo "60hz-assert: PASS - $1"; }
warn() { echo "::warning::$1" >&2; }

if [ ! -d "$WORK_DIR" ]; then
    echo "::error::assert-60hz: work dir does not exist: $WORK_DIR" >&2
    exit 1
fi

# Extract the text value of one floating_feature.xml tag (first match).
ff_value() {
    local file="$1" tag="$2"
    sed -n "s/.*<${tag}>\([^<]*\)<\/${tag}>.*/\1/p" "$file" | head -n 1
}

check_ff() {
    local ff="$1" label="$2" val
    val="$(ff_value "$ff" "SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE")"
    if [ -z "$val" ]; then
        fail "$label: HFR_DEFAULT_REFRESH_RATE entry missing - the HFR rewrite may not have run"
    elif [ "$val" != "60" ]; then
        fail "$label: HFR_DEFAULT_REFRESH_RATE is '$val', expected 60 (120 leak?)"
    else
        pass "$label: HFR_DEFAULT_REFRESH_RATE=60"
    fi
    val="$(ff_value "$ff" "SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_MODE")"
    if [ -z "$val" ]; then
        fail "$label: HFR_MODE entry missing"
    elif [ "$val" != "0" ]; then
        fail "$label: HFR_MODE is '$val', expected 0 (VRR still enabled?)"
    else
        pass "$label: HFR_MODE=0"
    fi
    val="$(ff_value "$ff" "SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE")"
    if [ -z "$val" ]; then
        warn "$label: HFR_SUPPORTED_REFRESH_RATE entry absent (not a leak by itself)"
    elif [ "$val" = "0" ]; then
        pass "$label: HFR_SUPPORTED_REFRESH_RATE=0"
    elif grep -q -E '(^|,)(96|120)(,|$)' <<< "$val"; then
        fail "$label: HFR_SUPPORTED_REFRESH_RATE lists rates above 60: '$val'"
    else
        warn "$label: HFR_SUPPORTED_REFRESH_RATE is '$val' (expected '0', but no rate above 60)"
    fi
}

FF_SYSTEM="$WORK_DIR/system/system/etc/floating_feature.xml"
FF_VENDOR="$WORK_DIR/vendor/etc/floating_feature.xml"

if [ -f "$FF_SYSTEM" ]; then
    check_ff "$FF_SYSTEM" "system floating_feature.xml"
else
    fail "system floating_feature.xml not found at $FF_SYSTEM - cannot verify the 60 Hz pin"
fi
if [ -f "$FF_VENDOR" ]; then
    check_ff "$FF_VENDOR" "vendor floating_feature.xml"
else
    echo "60hz-assert: note - no vendor floating_feature.xml (checked system only)"
fi

BP="$WORK_DIR/vendor/build.prop"
if [ ! -f "$BP" ]; then
    fail "vendor/build.prop not found at $BP - cannot verify SurfaceFlinger props"
else
    if grep -q -E '^ro\.surface_flinger\.enable_frame_rate_override[[:space:]]*=[[:space:]]*true' "$BP"; then
        fail "vendor/build.prop enables ro.surface_flinger.enable_frame_rate_override=true"
    else
        pass "vendor/build.prop: frame_rate_override is not true"
    fi
    # Info only: report the P1 prop values (do not fail on them here).
    for p in ro.surface_flinger.enable_frame_rate_override \
             ro.surface_flinger.use_content_detection_for_refresh_rate \
             ro.surface_flinger.game_default_frame_rate_override; do
        v="$(grep -E "^${p}[[:space:]]*=" "$BP" | tail -n 1 | cut -d= -f2- || true)"
        echo "60hz-assert: info - $p=${v:-<absent>}"
    done
fi

if [ "$FAILURES" -gt 0 ]; then
    echo "::error::assert-60hz: $FAILURES check(s) failed - the built ROM leaks 120 Hz settings; see above." >&2
    exit 1
fi
echo "60hz-assert: all checks passed - no 120 Hz leak in the built ROM."
exit 0
