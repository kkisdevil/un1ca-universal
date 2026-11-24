#!/usr/bin/env bash
# use-vendored-target.sh - copy our vendored m51 target over the upstream
# checkout, so the build uses OUR copy of the target, not Arnav's live tree.
#
# Usage: bash use-vendored-target.sh <upstream-dir> <device> <source-repo>
#   upstream-dir : path to the checked-out upstream fork (e.g. ./upstream)
#   device       : device codename (e.g. m51). Any device other than m51
#                  is skipped (exit 0) - only m51 is vendored.
#   source-repo  : the resolved upstream repo (e.g. Arnav3078/UN1CA-SM7150).
#                  Any repo other than Arnav's is skipped: the vendored
#                  target is Arnav's seventeen tree, and applying it to
#                  Mehedi's sixteen (or base UN1CA, which has no m51 at
#                  all) would silently build the wrong target.
#
# The workflow runs this between "Checkout upstream UN1CA fork" and
# "Apply porter performance patches", so the fix pack then applies on top
# of OUR target copy. The copy is plain file copy (no delete): files
# present in the vendored tree overwrite upstream's; upstream-only files
# stay. That matters for the 9 proprietary Samsung binaries in
# target/m51/patches/ril/vendor/ (rild + 8 .so files, incl. libsec-ril.so):
# they are deliberately NOT vendored (no proprietary binaries in this
# GPL-3.0 repo), so they are left exactly as the upstream checkout has
# them — the script verifies they are still there afterwards and fails
# loudly if any is missing.
#
# Pin check: the vendored tree is a snapshot of Arnav seventeen at the
# commit in vendor/arnav-un1ca-sm7150/PIN. If the upstream checkout is at
# a different commit, the build FAILS here instead of silently mixing a
# new upstream tree with a stale vendored target. Re-vendor with
# scripts/vendor-target-m51.sh (one command) and commit the result.
set -euo pipefail

PORTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPSTREAM_DIR="${1:?usage: use-vendored-target.sh <upstream-dir> <device> <source-repo>}"
DEVICE="${2:?usage: use-vendored-target.sh <upstream-dir> <device> <source-repo>}"
SOURCE_REPO="${3:?usage: use-vendored-target.sh <upstream-dir> <device> <source-repo>}"

VENDOR_DIR="$PORTER_DIR/vendor/arnav-un1ca-sm7150/target-m51"
PIN_FILE="$PORTER_DIR/vendor/arnav-un1ca-sm7150/PIN"
EXPECTED_REPO="Arnav3078/UN1CA-SM7150"

if [ "$DEVICE" != "m51" ]; then
    echo "use-vendored-target: device is '$DEVICE', not m51 - skipping (only m51 is vendored)."
    exit 0
fi

if [ "$SOURCE_REPO" != "$EXPECTED_REPO" ]; then
    echo "use-vendored-target: source repo is '$SOURCE_REPO', not $EXPECTED_REPO - skipping (the vendored target is Arnav's seventeen tree; the build uses upstream's own target)."
    exit 0
fi

if [ ! -d "$UPSTREAM_DIR" ]; then
    echo "::error::use-vendored-target: upstream checkout not found: $UPSTREAM_DIR" >&2
    exit 1
fi
if [ ! -d "$VENDOR_DIR" ]; then
    echo "::error::use-vendored-target: vendored target missing: $VENDOR_DIR" >&2
    exit 1
fi
if [ ! -f "$PIN_FILE" ]; then
    echo "::error::use-vendored-target: pin file missing: $PIN_FILE" >&2
    exit 1
fi

# --- Pin check: vendored snapshot must match the checked-out upstream ---
PIN_COMMIT="$(sed -n 's/^commit: //p' "$PIN_FILE" | head -n1)"
if [ -z "$PIN_COMMIT" ]; then
    echo "::error::use-vendored-target: PIN file has no 'commit:' line: $PIN_FILE" >&2
    exit 1
fi
UPSTREAM_HEAD="$(git -C "$UPSTREAM_DIR" rev-parse HEAD 2>/dev/null || true)"
if [ -z "$UPSTREAM_HEAD" ]; then
    echo "::error::use-vendored-target: cannot read upstream HEAD (not a git checkout?): $UPSTREAM_DIR" >&2
    exit 1
fi
if [ "$UPSTREAM_HEAD" != "$PIN_COMMIT" ]; then
    echo "::error::use-vendored-target: upstream HEAD $UPSTREAM_HEAD != vendored pin $PIN_COMMIT. The vendored target is a snapshot of Arnav seventeen at the pinned commit; building a newer upstream tree over it would silently mix versions. Re-vendor first: bash scripts/vendor-target-m51.sh --ref seventeen (then commit the result) or pin the workflow to the pinned commit." >&2
    exit 1
fi
echo "use-vendored-target: pin OK ($PIN_COMMIT)."

# --- Copy vendored target over upstream/target/m51 ---
if [ ! -d "$UPSTREAM_DIR/target/m51" ]; then
    echo "::error::use-vendored-target: upstream target/m51 not found in checkout: $UPSTREAM_DIR/target/m51" >&2
    exit 1
fi
cp -r "$VENDOR_DIR/." "$UPSTREAM_DIR/target/m51/"

# Verify every vendored file landed byte-identical.
MISMATCH=0
while IFS= read -r -d '' src; do
    rel="${src#$VENDOR_DIR/}"
    if ! cmp -s "$src" "$UPSTREAM_DIR/target/m51/$rel"; then
        echo "::error::use-vendored-target: $rel did not copy cleanly" >&2
        MISMATCH=1
    fi
done < <(find "$VENDOR_DIR" -type f -print0)
if [ "$MISMATCH" -ne 0 ]; then
    exit 1
fi

# The 9 proprietary RIL binaries are NOT vendored (see header). They must
# still be present from the upstream checkout — the build needs them.
PROPRIETARY=(
    "target/m51/patches/ril/vendor/bin/hw/rild"
    "target/m51/patches/ril/vendor/lib64/libSemDataProps.so"
    "target/m51/patches/ril/vendor/lib64/libSemTelephonyProps.so"
    "target/m51/patches/ril/vendor/lib64/libqmiservices-ext.so"
    "target/m51/patches/ril/vendor/lib64/libqmiservices.so"
    "target/m51/patches/ril/vendor/lib64/libril_sem.so"
    "target/m51/patches/ril/vendor/lib64/libsec-ril.so"
    "target/m51/patches/ril/vendor/lib64/libsecril-client.so"
    "target/m51/patches/ril/vendor/lib64/libsemnativecarrierfeature.so"
)
for rel in "${PROPRIETARY[@]}"; do
    if [ ! -f "$UPSTREAM_DIR/$rel" ]; then
        echo "::error::use-vendored-target: proprietary binary missing from upstream checkout (not vendored by design): $rel" >&2
        exit 1
    fi
done

COUNT="$(find "$VENDOR_DIR" -type f | wc -l)"
echo "use-vendored-target: $COUNT vendored files in place over upstream/target/m51 (pin $PIN_COMMIT); 9 proprietary RIL binaries kept from the upstream checkout."
