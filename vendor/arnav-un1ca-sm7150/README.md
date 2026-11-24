# vendor/arnav-un1ca-sm7150 — Arnav's UN1CA-SM7150, vendored (m51)

Our own copy of the parts of Arnav's UN1CA fork that the m51 build needs,
so the build does not depend on Arnav's live tree staying put. GPL-3.0,
same licence as upstream. Credit: Arnav3078, mehedihjoy0, salvogiangri
(see the repo's CREDITS.md).

## Pin

`PIN` (this directory): `Arnav3078/UN1CA-SM7150`, branch `seventeen`,
commit `f6790355358fe9a83df4db080f3c8f7360c63d7f` (UN1CA 5.4.0, HEAD as
of 2026-11-21 — the same revision builds #5 and #7 were built from).
Every file here is byte-identical to that commit, except the exclusions
below. Re-vendor with `bash scripts/vendor-target-m51.sh --ref seventeen`
when Arnav pushes and the workflow's pin check starts failing.

## Contents

| Path | What it is | Upstream path |
|---|---|---|
| `target-m51/` | The whole `target/m51/` tree: `config.sh`, `debloat.sh`, `sff.sh`, `installer/` (assertions, install-end, recovery.fstab), `overlay/`, `dvfs/siop_model.xml`, and all 17 `patches/<name>/` modules with their `customize.sh` / `module.prop` / helper scripts | `target/m51/` |
| `scripts/release_rom.sh` | OTA release script: splits the ROM + target-files zips into 1.5 GB chunks, generates the OTA manifest, uploads as a GitHub release | `scripts/release_rom.sh` |
| `scripts/build_incremental.sh` | Incremental OTA builder (previous release's target-files → ~155 MB incremental zip) | `scripts/build_incremental.sh` |
| `scripts/generate_ota_manifest.sh` | Helper called by `release_rom.sh` to write `manifest.json` | `scripts/generate_ota_manifest.sh` |
| `scripts/internal/build_incremental_ota_zip.sh` | Helper called by `build_incremental.sh` (the actual incremental-zip builder) | `scripts/internal/build_incremental_ota_zip.sh` |
| `scripts/utils/smali_utils.sh` | Smali helpers incl. dynamic smali-path resolution (resolves `smali/` / `smali_classesN/` when the expected directory number does not match) | `scripts/utils/smali_utils.sh` |

65 files in `target-m51/` + 5 scripts, ~400 KB total.

## Excluded on purpose — the 9 proprietary RIL binaries

`target/m51/patches/ril/vendor/` in upstream contains 9 Samsung
proprietary binaries (6,323,040 B of `libsec-ril.so` alone, ~7.5 MB
total). They are **not vendored**: no proprietary binaries in this
GPL-3.0 repo. The two text `.rc` files in the same directory
(`init.vendor.rilchip.rc`, `init.vendor.rilcommon.rc`) ARE vendored —
they are plain-text config, not binaries.

| File (not vendored) | Size |
|---|---|
| `patches/ril/vendor/bin/hw/rild` | 16,080 B |
| `patches/ril/vendor/lib64/libSemDataProps.so` | 11,096 B |
| `patches/ril/vendor/lib64/libSemTelephonyProps.so` | 73,728 B |
| `patches/ril/vendor/lib64/libqmiservices-ext.so` | 12,344 B |
| `patches/ril/vendor/lib64/libqmiservices.so` | 154,352 B |
| `patches/ril/vendor/lib64/libril_sem.so` | 843,000 B |
| `patches/ril/vendor/lib64/libsec-ril.so` | 6,323,040 B |
| `patches/ril/vendor/lib64/libsecril-client.so` | 40,936 B |
| `patches/ril/vendor/lib64/libsemnativecarrierfeature.so` | 175,664 B |

At build time the workflow still checks out the upstream fork, and
`scripts/use-vendored-target.sh` copies the vendored tree over
`upstream/target/m51/` — the copy leaves the upstream checkout's RIL
binaries in place (they are not in the vendored tree, so nothing
overwrites them) and then verifies all 9 are present, failing loudly
if any is missing. The long-term direction (per the "own build" rule)
is to re-extract these from stock firmware instead of taking them from
Arnav's tree; until then the upstream checkout remains their source.

## How the build uses this

Workflow step "Use vendored m51 target" (`.github/workflows/build.yml`,
between "Checkout upstream UN1CA fork" and "Apply porter performance
patches") runs `scripts/use-vendored-target.sh`. It only applies when
device is `m51` AND the resolved source repo is `Arnav3078/UN1CA-SM7150`
(any other device or repo skips it with a clear message — Mehedi's
`sixteen` has a different tweaks file and patch list, and base UN1CA
has no m51 target at all). It fails loudly if the upstream checkout's
HEAD differs from the PIN (re-vendor first), if any vendored file does
not copy byte-identical, or if any of the 9 RIL binaries is missing.
After it, "Apply porter performance patches" applies the fix pack on
top of this vendored copy — the pack's overrides are our edits, this
directory is the pristine snapshot.

## The OTA scripts — one adaptation still needed before use

`release_rom.sh` / `build_incremental.sh` are verbatim copies of
Mehedi's scripts (Arnav's are byte-identical — see
research/09-arnav-un1ca.md §1.2). They resolve their release repo as
`<owner>/static_resources` and **fork `UN1CA/static_resources` if it
does not exist**. Before the porter ever runs them with
`release_rom=true`, point them at OUR release repo instead (create
`kkisdevil/static_resources`, or retarget the `REPOSITORY` resolution
to this repo) — otherwise a release run would fork Salvo's
`static_resources` repo into the builder's account. The workflow does
not call them in a normal build; they are vendored now so the OTA
system is in our repo when we need it. Other OTA facts worth knowing
(manifest schema, ~155 MB incrementals, `id` = sha256, aosp_testkey
certs, the manifest lagging the ROM): research/09-arnav-un1ca.md §2.

## What is deliberately NOT vendored here

- The rest of Arnav's tree (build system, mods, configs): it is the
  upstream checkout at build time, pinned by the same commit in
  `vendor/FETCH-SPEC.md`. Vendoring the whole 4.0 GB repo would exceed
  GitHub's limits and is not needed — the m51 target + OTA scripts are
  the parts we modify and the parts that define "our" build.
- The external submodules (apktool, samloader, erofs-utils, ...):
  pinned by commit in `vendor/FETCH-SPEC.md`, fetched at build time
  by the upstream checkout (`submodules: recursive`).
- Firmware, kernel release, toolchains: fetch-at-build-time, pinned in
  `vendor/FETCH-SPEC.md` (too big / proprietary for the repo).
