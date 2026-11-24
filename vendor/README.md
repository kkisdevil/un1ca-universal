# vendor/ — everything the build needs, in our repo or pinned

This directory is the "our own build" rule made concrete: every external
thing the UN1CA build pulls is either **vendored here** (a copy in our
repo, with its source and licence named) or **pinned in FETCH-SPEC.md**
(exact URL + commit/tag + checksum, so a build never depends on an
unpinned "latest").

## What is vendored

| Path | Contents | Source / licence |
|---|---|---|
| `arnav-un1ca-sm7150/target-m51/` | Arnav's whole `target/m51/` tree (65 files, ~300 KB text) at pin `f679035535` | Arnav3078/UN1CA-SM7150, GPL-3.0 |
| `arnav-un1ca-sm7150/scripts/` | OTA scripts (`release_rom.sh`, `build_incremental.sh`, `generate_ota_manifest.sh`, `internal/build_incremental_ota_zip.sh`) + `utils/smali_utils.sh` (dynamic smali-path resolution) | Mehedi H Joy / Arnav3078, GPL-3.0 |
| `borrowed/coloros17-sm7150/` | `patch_boot.py` (stdlib-only permissive boot + ramdisk fstab patch), `m51.cil` sepolicy template, `device.prop` + `tweaks.prop` (fingerprint @2.1 mapping, VoLTE bypass) | Arnav3078/ColorOS17-SM7150, GPL-3.0 |
| `borrowed/projectarcadex/` | `auto_gen.sh` (derive device facts from stock firmware) + `samfirm.js` (Samsung firmware downloader, bundled) | SameerAlSahab/ProjectArcadeX, MIT; samfirm.js by jesec, GPL-3.0-or-later |
| `borrowed/spidergirl-hidl-aidl-swaps.md` | Reference doc: HIDL→AIDL HAL-swap patterns + FCM bump (no code — patterns only) | SpiderGirl-OS (AstroROM fork), credit AstroROM/SpiderGirl |

Total: ~868 KB. Small by design — this is the m51 target and the small
tools/scripts, not whole repos.

## What is NOT vendored (and why)

- **Samsung stock firmware** (~30.9 GB per build: S23 16.7 GB + m51
  5.41 GB + S21 FE 8.79 GB) — far over GitHub's 100 MB/file limit and
  proprietary. Downloaded at build time via samloader from Samsung FUS.
- **The built ROM zip** (~10.9 GB) — an artifact, not a source.
- **Toolchains** (proton-clang for the kernel; JDK 17; Android
  build-tools r34) — GBs, fetched at build time.
- **The 9 proprietary RIL binaries** (`libsec-ril.so` etc., ~7.5 MB) —
  Samsung proprietary code. Not in this GPL-3.0 repo; they come from
  the upstream checkout at build time (verified present by
  `scripts/use-vendored-target.sh`).
- **Odin + Samsung firmware + flashing tools** — proprietary, never in
  this repo. See `docs/BUILD-GUIDE.md` for where to get them and how
  the flash works (the user asked for the official firmware, its
  flashing guide, and a working Odin to be saved — that is a separate
  step from this vendoring, because proprietary binaries cannot live
  in this repo; the guide names the exact sources).
- **The rest of Arnav's 4.0 GB tree** — the upstream checkout at build
  time, pinned by commit (see FETCH-SPEC.md). Only the m51 target and
  the OTA scripts are vendored, because those are the parts we modify
  and the parts that define "our" build.

## How the build uses the vendored tree

`.github/workflows/build.yml`, step "Use vendored m51 target", runs
`scripts/use-vendored-target.sh` after checking out upstream and before
applying the performance fix pack. It only applies for device `m51` from
source repo `Arnav3078/UN1CA-SM7150`; it fails loudly if the upstream
checkout's HEAD differs from `arnav-un1ca-sm7150/PIN` (re-vendor with
`scripts/vendor-target-m51.sh`), if a vendored file does not copy
byte-identical, or if any of the 9 RIL binaries is missing. The fix pack
(`patches/m51-performance/`) then applies on top of the vendored copy.

## Maintenance

- When Arnav pushes to `seventeen`, the workflow's pin check fails.
  Re-vendor: `bash scripts/vendor-target-m51.sh --ref seventeen`,
  review the diff, commit vendored files + PIN. Never silence the pin
  check.
- When a borrowed tool gets a new verified version (e.g. samloader-rs
  2.2.0), update the pin in FETCH-SPEC.md + the fetcher script, and
  verify it against the same flow before changing the default.
- Every borrowed piece names its source here and in the repo's
  CREDITS.md. Nothing is copied verbatim without a compatibility pass:
  see each sub-directory's README for what was adapted and what is
  still open.
