#!/usr/bin/env bash
# apply-performance-patches.sh - copy the m51-performance porter overrides
# over an upstream UN1CA checkout.
#
# Usage: bash apply-performance-patches.sh <upstream-dir> <device>
#   upstream-dir : path to the checked-out upstream fork (e.g. ./upstream)
#   device       : device codename (e.g. m51). Any device other than m51
#                  is skipped (exit 0) - this pack is m51-only.
#
# The workflow runs this between "Checkout upstream UN1CA fork" and
# "Set up build environment", so the overrides are in place before
# make_rom.sh runs. Each override is a full-file replacement of an
# upstream file (relative paths preserved). The script fails loudly if an
# upstream file moved, instead of silently skipping the override - if
# upstream renames a file, update the pack, do not let the build go ahead
# without the fix.
set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPSTREAM_DIR="${1:?usage: apply-performance-patches.sh <upstream-dir> <device>}"
DEVICE="${2:?usage: apply-performance-patches.sh <upstream-dir> <device>}"

if [ "$DEVICE" != "m51" ]; then
    echo "m51-performance pack: device is '$DEVICE', not m51 - skipping (nothing to apply)."
    exit 0
fi

if [ ! -d "$UPSTREAM_DIR" ]; then
    echo "::error::m51-performance pack: upstream checkout not found: $UPSTREAM_DIR" >&2
    exit 1
fi

# Override files, relative to the pack dir and to the upstream checkout.
# The first three are the original F1/F2/F3/F5/P1 overrides; the fourth is
# the F3 daemon neutralisation (see README §F3-daemon); the fifth is the
# F2 blacklist fix (see README §F2-blacklist): the __floating_feature
# module runs after the device tweaks and would otherwise reset the blur
# flags to stock TRUE — build #8 shipped them TRUE in the system file.
OVERRIDES=(
    "target/m51/dvfs/siop_model.xml"
    "target/m51/patches/tweaks/customize.sh"
    "target/m51/patches/display/vendor.prop"
    "unica/mods/settings/system/bin/carbon_power_engine"
    "unica/patches/__floating_feature/customize.sh"
)

for rel in "${OVERRIDES[@]}"; do
    src="$PACK_DIR/$rel"
    dst="$UPSTREAM_DIR/$rel"
    if [ ! -f "$src" ]; then
        echo "::error::m51-performance pack is missing its own file: $rel" >&2
        exit 1
    fi
    if [ ! -f "$dst" ]; then
        echo "::error::m51-performance override target no longer exists upstream: $rel - upstream moved the file; update the pack instead of silently skipping it." >&2
        exit 1
    fi
    cp -f "$src" "$dst"
    # The copy must land byte-identical and must carry the porter marker.
    if ! cmp -s "$src" "$dst"; then
        echo "::error::m51-performance override did not copy cleanly: $rel" >&2
        exit 1
    fi
    if ! grep -q "PORTER OVERRIDE" "$dst"; then
        echo "::error::m51-performance override $rel has no PORTER OVERRIDE marker - wrong file?" >&2
        exit 1
    fi
    echo "m51-performance: overrode $rel"
done

echo "m51-performance pack applied (${#OVERRIDES[@]} files) for device m51."
