#!/usr/bin/env bash
# vendor-target-m51.sh - re-vendor Arnav's m51 target into this repo.
#
# Usage: bash scripts/vendor-target-m51.sh [--repo Arnav3078/UN1CA-SM7150]
#                                          [--ref seventeen] [--pin-only]
#   --repo     upstream repo to fetch from (default Arnav3078/UN1CA-SM7150)
#   --ref      branch or commit to vendor (default seventeen; resolved to
#              its HEAD commit via the GitHub API, and that commit is what
#              gets written to the PIN file)
#   --pin-only only resolve the ref and print the commit; fetch nothing.
#
# Fetches target/m51 file by file from raw.githubusercontent.com, verifies
# each file's size against the GitHub tree API listing, and writes the
# result into vendor/arnav-un1ca-sm7150/target-m51/. Files that no longer
# exist upstream are DELETED from the vendored tree (so the snapshot stays
# an exact copy of the upstream tree at the pinned commit, not a merge of
# two versions).
#
# The 9 proprietary Samsung binaries in patches/ril/vendor/ (rild + 8 .so
# files, incl. libsec-ril.so) are NEVER written: no proprietary binaries
# in this GPL-3.0 repo. They stay in the upstream checkout at build time
# (scripts/use-vendored-target.sh verifies they are there).
#
# Run this locally whenever Arnav pushes to seventeen and the workflow's
# pin check starts failing — then commit the result (vendored files + PIN).
# It needs network access and the GitHub API (unauthenticated, 60/hr).
set -euo pipefail

REPO="Arnav3078/UN1CA-SM7150"
REF="seventeen"
PIN_ONLY=false
while [ "$#" -gt 0 ]; do
    case "$1" in
        --repo) REPO="$2"; shift 2 ;;
        --ref) REF="$2"; shift 2 ;;
        --pin-only) PIN_ONLY=true; shift ;;
        --help|-h)
            echo "Usage: $0 [--repo Arnav3078/UN1CA-SM7150] [--ref seventeen] [--pin-only]"
            exit 0
            ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

PORTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_DIR="$PORTER_DIR/vendor/arnav-un1ca-sm7150/target-m51"
PIN_FILE="$PORTER_DIR/vendor/arnav-un1ca-sm7150/PIN"

# Resolve the ref to a commit via the API (works for a branch name or a
# full SHA; a short SHA is passed through as-is and verified below).
if [[ "$REF" =~ ^[0-9a-f]{40}$ ]]; then
    COMMIT="$REF"
else
    COMMIT="$(curl -fsSL "https://api.github.com/repos/$REPO/commits/$REF" | python3 -c "import sys,json; print(json.load(sys.stdin)['sha'])")"
fi
echo "Vendoring $REPO @ $COMMIT (ref: $REF)"
if $PIN_ONLY; then
    echo "commit: $COMMIT"
    exit 0
fi

# Tree listing for target/m51 at the pinned commit (recursive, one call).
TREE_JSON="$(mktemp)"
trap 'rm -f "$TREE_JSON"' EXIT
curl -fsSL "https://api.github.com/repos/$REPO/git/trees/$COMMIT:target/m51?recursive=1" -o "$TREE_JSON"
python3 - "$TREE_JSON" "$REPO" "$COMMIT" "$VENDOR_DIR" << 'PY'
import json, os, subprocess, sys

tree_path, repo, commit, dest = sys.argv[1:5]
tree = json.load(open(tree_path))['tree']
base = f"https://raw.githubusercontent.com/{repo}/{commit}/target/m51"

# Proprietary Samsung binaries: never vendored.
SKIP_PREFIX = "patches/ril/vendor/"
PROPRIETARY_BINARIES = {
    "patches/ril/vendor/bin/hw/rild",
    "patches/ril/vendor/lib64/libSemDataProps.so",
    "patches/ril/vendor/lib64/libSemTelephonyProps.so",
    "patches/ril/vendor/lib64/libqmiservices-ext.so",
    "patches/ril/vendor/lib64/libqmiservices.so",
    "patches/ril/vendor/lib64/libril_sem.so",
    "patches/ril/vendor/lib64/libsec-ril.so",
    "patches/ril/vendor/lib64/libsecril-client.so",
    "patches/ril/vendor/lib64/libsemnativecarrierfeature.so",
}
want = {}
for e in tree:
    if e['type'] != 'blob':
        continue
    p = e['path']
    if p in PROPRIETARY_BINARIES:
        continue
    want[p] = e.get('size', 0)

# Delete vendored files that no longer exist upstream (exact snapshot).
have = set()
for root, _dirs, files in os.walk(dest):
    for f in files:
        have.add(os.path.relpath(os.path.join(root, f), dest))
for stale in sorted(have - set(want)):
    os.remove(os.path.join(dest, stale))
    print(f"  deleted stale: {stale}")

fetched, bad = 0, []
for path, size in sorted(want.items()):
    out = os.path.join(dest, path)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    r = subprocess.run(["curl", "-fsSL", "-o", out, f"{base}/{path}"],
                       capture_output=True)
    if r.returncode != 0 or os.path.getsize(out) != size:
        bad.append(path)
        continue
    fetched += 1
print(f"fetched: {fetched} files, {len(PROPRIETARY_BINARIES)} proprietary binaries skipped, {len(bad)} failures")
if bad:
    print("FAILED:", *bad, sep="\n  ")
    sys.exit(1)
PY

# PIN file: the snapshot identity. use-vendored-target.sh enforces it.
{
    echo "repo: $REPO"
    echo "branch: $REF"
    echo "commit: $COMMIT"
    echo "vendored: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "note: target/m51 snapshot; 9 proprietary RIL binaries excluded by design (see vendor/arnav-un1ca-sm7150/README.md)"
} > "$PIN_FILE"
echo "PIN updated: $PIN_FILE"
echo "Review the diff (git status / git diff), then commit the vendored files + PIN."
