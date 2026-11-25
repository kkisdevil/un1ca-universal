# BUILD-GUIDE — build the UN1CA ROM for the Galaxy M51 from this repo

How to build the ROM entirely from this repo — what is vendored, what is
fetched at build time (and why), the exact build command, the fix pack,
and how to verify the output. The build runs on GitHub Actions; nothing
here needs the user's servers, laptop, or phone until the flash step.

> Status: the vendored target + fix pack in this guide are the state of
> the repo as of 2026-11-24 (Arnav seventeen @ `f679035535`, UN1CA 5.4.0;
> builds #5 and #7 green from this source). The F3 daemon neutralisation
> (§4) is prepared in the fix pack but has not been built yet — it ships
> with the next build.

## 1. Prerequisites

- A GitHub account with access to this repo (`kkisdevil/un1ca-universal`)
  and to the upstream fork (`Arnav3078/UN1CA-SM7150`). The workflow is
  `workflow_dispatch` only — no push/PR/schedule triggers.
- For a **signed release build**: repository secrets `PLATFORM_KEY_PK8`
  and `PLATFORM_KEY_PEM` (base64), decoded by the workflow into
  `security/unica_platform.pk8` / `.x509.pem` exactly as upstream CI
  does. **Without them the build still works**: `setup-tools.sh`
  generates a throwaway test keypair per run so the ROM can sign —
  test builds only, never present a test-key build as a release build.
- For a dry-run: nothing else. Dry-run downloads no firmware and builds
  no ROM — it checks out the upstream tree, sets up tools, generates the
  build config, and lists the scripts a full build would run.
- The phone is NOT needed to build. It is needed only to flash and test
  (§6).

## 2. What is vendored vs fetched at build time

| | Where | Why |
|---|---|---|
| **Vendored** (`vendor/`) | Arnav's `target/m51/` tree (65 files, ~300 KB text) + OTA scripts + `smali_utils.sh`; borrowed tools (`patch_boot.py`, `m51.cil`, `device.prop`/`tweaks.prop`, `auto_gen.sh`, `samfirm.js`); SpiderGirl swap patterns (doc only) | Small, redistributable (GPL-3.0/MIT), and the parts we modify. See `vendor/README.md`. |
| **Fetched, pinned** (`vendor/FETCH-SPEC.md`) | Upstream fork checkout (pin `f679035535`), 6 external submodules (pinned commits), LostPrime kernel release (asset pattern `m51-ksu*.zip`), M51-FIRMWARES clone (pin `a060572e86`), stock firmwares (~30.9 GB), samloader-rs v2.0.0 (SHA-256 pinned), JDK 17, build-tools r34, apt packages, GitHub Actions | Too big, proprietary, or whole repos. Every fetch is pinned (URL + commit/tag + checksum where one exists) so a build never depends on an unpinned "latest". |
| **Deliberately NOT in the repo** | The 9 proprietary RIL binaries (`libsec-ril.so` etc.); Samsung firmware; Odin; the built ROM zip (~10.9 GB) | Proprietary binaries never go in this GPL-3.0 repo; the ROM zip and firmware exceed GitHub's 100 MB/file limit (free LFS: 1 GB storage / 1 GB bandwidth). The RIL binaries come from the upstream checkout at build time (verified present by `use-vendored-target.sh`). Firmware + Odin are covered in §5. |

## 3. The build command

There is no local build command that reproduces the GitHub run exactly
(the runner's disk cleanup, caches, and 4 vCPU/16 GB shape are part of
the build). The build is dispatched, and the equivalent upstream
commands — for understanding, not for running locally — are:

```
# Inside the upstream UN1CA tree (./upstream in the workflow):
source ./buildenv.sh m51
./scripts/build_dependencies.sh
./scripts/download_fw.sh
./scripts/extract_fw.sh
./scripts/make_rom.sh --build-rom-zip
# Output: out/UN1CA_<version>_<YYYYMMDD>_m51[-sign].zip
```

### Dispatch (GitHub web UI → Actions → Build ROM → Run workflow)

| Input | Value for the standard m51 build |
|---|---|
| device | `m51` |
| source_repo | `auto` (resolves to `Arnav3078/UN1CA-SM7150`) |
| source_branch | `auto` (resolves to `seventeen`) |
| build_type | `decrypted` |
| mode | `full` (or `dry-run` to validate only) |
| release_rom | `false` (see note below) |
| changelog | (only with `release_rom`) |

### What the workflow does, in order

1. `validate` job: `scripts/validate-device.sh` on `devices/m51.json`
   (`--check-upstream`, authenticated with `github.token`).
2. `resolve` job: `scripts/resolve-device.py` maps m51 → sm7150 →
   Arnav `seventeen`, UN1CA 5.4.0.
3. `build` job (ubuntu-24.04, 360-min cap): free disk (3 steps — required,
   the firmware + ROM need tens of GB) → checkout this repo → checkout
   upstream into `./upstream` (`submodules: recursive`, `fetch-depth: 1`)
   → **Use vendored m51 target** (`scripts/use-vendored-target.sh`:
   copies `vendor/arnav-un1ca-sm7150/target-m51/` over
   `upstream/target/m51/`, verifies the pin + the 9 RIL binaries) →
   **Apply porter performance patches** (§4) → `setup-tools.sh` (apt
   list + signing keys / throwaway test keys) → JDK 17 (Temurin) →
   generate build config (`buildenv.sh`) → dry-run report (dry-run
   mode) → cache tools → `build_dependencies.sh` → **Install smali
   tools** (baksmali/smali from the apktool jar, apksigner from
   build-tools r34) → cache firmwares → **Download stock firmwares**
   (3 firmwares, 30.9 GB, 180-min timeout, retry ×3 on any failure) →
   extract → **Pre-flight kernel release** (resolves the LostPrime
   `m51-ksu` URL up front so a bad release fails in seconds) →
   **Build ROM** (`make_rom.sh --build-rom-zip`) → **Assert 60 Hz pin**
   (full mode only) → optional release → ROM artifact (7 days) + build
   logs artifact (always, 14 days) → build summary.

### If a build fails (standing rule: fix-and-repeat)

1. Open the `build-logs-<device>-<run_id>` artifact (uploaded even on
   failure) — read the failing step's log, not the summary line.
2. Fix the cause, commit, re-dispatch via `workflow_dispatch`.
3. Repeat until the ROM builds. Never stop at the first failure, never
   just report the error. Past failures and their fixes: skill §4 /
   research/01 §11 (the five real failures: API 403, script permission,
   missing baksmali, empty kernel URL, firmware-download timeout).

### `release_rom` — do not enable without retargeting first

The vendored OTA scripts (`release_rom.sh` / `build_incremental.sh`)
resolve their release repo as `<owner>/static_resources` and **fork
`UN1CA/static_resources` if it does not exist**. Before ever dispatching
with `release_rom=true`, point them at OUR release repo (create
`kkisdevil/static_resources`, or retarget the `REPOSITORY` resolution)
— otherwise a release run forks Salvo's repo into the builder's account.
See `vendor/arnav-un1ca-sm7150/README.md`.

## 4. The fix pack (what our build changes vs upstream)

`patches/m51-performance/` — m51 only, applied by the workflow before
`make_rom.sh`. User scope (binding, 2026-11-24): **keep all UN1CA
flagship features, remove blur effects only.** No feature removals.

| Fix | File overridden | Change |
|---|---|---|
| **F1** — relax thermal caps | `target/m51/dvfs/siop_model.xml` | CPU cap engages at 45 °C (was 35 °C); GPU cap 650 MHz (was 565 MHz); game floor 430 MHz (was 267/355 MHz). Overheat protection untouched. |
| **F2** — live blur off | `target/m51/patches/tweaks/customize.sh` | `nativeblur` true→false, `supports_background_blur` 1→0 in **both** blocks (the tuning block re-asserts blur after the first block — last-call-wins); floating-feature blur flags forced `FALSE`. |
| **F3** — restore stock zram, swappiness 60 | same file | `zramsize=0` rewrite deleted (stock fstab survives); `sys.sysctl.swappiness` 100→60 in all four places. |
| **F3-daemon** — neutralise the daemon that undoes F3 at boot | `unica/mods/settings/system/bin/carbon_power_engine` | `apply_zram()`: `vm.swappiness` 100→**60**. **Prepared 2026-11-24, not yet built.** Arnav's 5.3.0+ Performance Profile engine runs at every boot and forces swappiness back to 100 — the prop alone cannot fix this, so the daemon is patched (not removed: the profiles are a flagship feature). Verify on a booted device: `cat /proc/sys/vm/swappiness` must read `60` after a reboot. |
| **F5** — keep stock perf configs | same file | The `DELETE_FROM_WORK_DIR vendor/etc/hyper` / `etc/perf` lines deleted — those hold the Qualcomm perfd / performance-HAL config. |
| **P1** — explicit 60 Hz SurfaceFlinger props | `target/m51/patches/display/vendor.prop` | Upstream's 7 lines verbatim + `enable_frame_rate_override=false`, `use_content_detection_for_refresh_rate=false`, `game_default_frame_rate_override=60`. |
| **P0** — build-time 60 Hz assertion | `scripts/assert-60hz.sh` (workflow step after Build ROM) | Fails the build if any 120 Hz value leaks into the built `floating_feature.xml` or `vendor/build.prop`. |

Deliberately NOT in the pack: F4 (removing Knox/SecureFolder/Now
Brief/PDE — against the user scope), F6–F8 / P2 / P3 (A/B tests or
experiments only). Full detail: `patches/m51-performance/README.md`,
research/06, research/06c, skill §5.

## 5. Official firmware, flashing guide, and Odin — sources, not files

The user asked for the latest official Samsung firmware, its flashing
guide, and a working Odin to be saved with the project. **They are not
in this repo, and they cannot be**: Samsung firmware (~7 GB per
release) and Odin are proprietary binaries, and GitHub rejects any
single file over 100 MB. What is saved here is the exact guide — where
to get them, how to verify them, and how to flash. Keep the downloaded
firmware and Odin on the flashing PC, never commit them.

**The authoritative flashing guide is `docs/FLASHING-GUIDE.md`** (same
directory as this file). It covers: the exact DXJ1 firmware record for
INS (PDA `M515FXXU6DXJ1`, CSC `M515FODM6DXJ1`, Android 12 / One UI 4.1,
security patch 2024-05-01, server file
`SM-M515F_2_20241004032751_smm7rurrx5_fac.zip`, ~7.1 GB, and where the
Drive copy lives); Odin versions with verified SHA-256 hashes
(**v3.14.1 recommended** — the v3.14.4 archive is disputed, four
different ZIPs circulate under that name); the five `.tar.md5` files and
their Odin slots; the TWRP-preservation methods (remove `recovery.img`
from the AP tar, or flash stock then immediately re-flash TWRP); the
step-by-step flash; and troubleshooting. **Do not follow any other
Odin advice in this repo over that guide** — in particular, do not use
v3.14.4 just because it has the highest version number.

> Gap noted (not fixed here): `FLASHING-GUIDE.md` references
> `docs/FIRMWARE.md` for the firmware hashes and the DXJ1-vs-DXJ2
> resolution, but that file does not exist in the repo yet. The
> firmware hashes must be recorded there before anyone flashes from
> the Drive copy.

This section adds only what the flashing guide does not cover: how to
download the firmware yourself with the pinned tool (§5.1), and how to
flash the UN1CA zip itself (§5.3).

### 5.1 Download the latest official firmware for SM-M515F (no IMEI needed)

Preferred tool — **samloader-rs v2.0.0** (pinned, SHA-256 verified):

```
bash scripts/fetch-samloader-rs.sh ./samloader-rs
./samloader-rs/samloader download --model SM-M515F --region INS
```

`INS` is the user's region (India). Change `--region` for another CSC.
The download is a Samsung-encrypted zip; it decrypts to the Odin
`.tar.md5` files (`AP_`, `BL_`, `CP_`, `CSC_`, `HOME_CSC_`).

**Verify what you got before flashing anything.** A no-IMEI query can
return a stale track (our blob-refresh work found FUS reporting DXE3 as
latest for INS while DXJ2 exists). Check the downloaded firmware's build
string: for INS the current record is DXJ1 (see `FLASHING-GUIDE.md` —
DXJ2 is the same build for a different CSC group, Latin America only).
If the download reports an older build than the record, the query
returned the stale track; do not treat it as "latest". Note also that a
newer build string does not always mean newer blobs (DXJ1 still carries
security patch 2024-05-01 and changelist 23974102, identical to the
DXE3-era builds).

Alternatives (same FUS source, same staleness caveat): the old Python
samloader from source (`ananjaser1211/samloader`, submodule pin in
`vendor/FETCH-SPEC.md` §2 — gone from PyPI, do not `pip install` it),
or `vendor/borrowed/projectarcadex/samfirm.js` (verify its hash against
jesec's releases first — see its README). On Linux, `samloader-rs` also
has a `flash` command that speaks the Odin protocol (see its README) —
not covered step-by-step here and not tested by us.

### 5.2 Flash the UN1CA zip (the normal path — via TWRP, not Odin)

1. **Back up first.** EFS + `sec_efs` raw backups, verified
   byte-for-byte, before any flash (Hyper371's discipline — adopt it
   verbatim). Also a TWRP backup of boot/system/vendor. Do not skip
   this: a bad flash without an EFS backup can cost the IMEI.
2. Check the bootloader: `assertions.edify` requires bootloader
   `M515FXXS6DXE3` or newer (Arnav's tree has no `ro.boot.rp` check — verified in the build #8 artifact). If the phone
   is on an older bootloader, flash the official firmware first
   (`FLASHING-GUIDE.md`).
3. Copy the UN1CA zip to the phone, boot into **TWRP**, flash the zip.
4. **What the zip does:** flashes the DXJ2 bootloader/modem firmware
   set (modem, vbmeta, abl, xbl, tz, ... — never recovery), patches
   `vbmeta.img` (AVB flag `0x03`, verification disabled), and **wipes
   fingerprint enrolments + dalvik-cache on every flash** — re-enrol
   fingerprints after flashing. It carries the NFC init-rc fix (not the
   old capex patch that bootlooped recovery).
5. **What the zip never does:** it never writes the recovery partition.
   Arnav's installer deletes `recovery.img` from the zip ("Never
   package or overwrite user's custom recovery"), and the same rule
   binds every zip/script/flash step in this project. Verify it for
   any new zip with the §6 check 2 (no `recovery.img` packaged).
6. Reboot, finish setup, wait for background dexopt to finish (idle
   ~30 min) before measuring anything.

### 5.3 Return to stock

Follow `docs/FLASHING-GUIDE.md` (Odin slots, CSC vs HOME_CSC, TWRP
section, troubleshooting). Flashing the full stock AP replaces TWRP
with the stock recovery — that is the one case where recovery is
intentionally replaced. Re-install TWRP afterwards only with the user's
go-ahead, and take a fresh TWRP backup (including EFS) once the phone
is back on stock.

## 6. Verify the output (before offering any build)

Skill §10.1, the 7-step artifact verification — every built ROM, before
it is offered to anyone:

1. **Download the artifact** (GitHub sign-in as kkisdevil; ROM
   retention 7 days, logs 14 days — download soon). Record run id,
   artifact name, exact byte size, SHA-256.
2. **Zip structure.** `META-INF/com/google/android/update-binary`
   present; `updater-script` asserts `SM-M515F` (bootloader ≥ `M515FXXS6DXE3`; no `ro.boot.rp` check in Arnav's tree — verified in the build #8 artifact); `build_info.txt` carries the right version /
   timestamp / device; partition images present for every dynamic
   partition; **no stray `recovery.img` packaged**; `vbmeta.img`
   patched (byte 123 → `0x03`, AVB disabled).
3. **Verify the performance patches actually landed in the output.**
   The target-files zip holds partition *images* (EROFS), not plain
   files — check the work dir the assert step checked (or extract the
   images with `extract.erofs` / `dump.erofs`): `siop_model.xml` CPU
   cap at 45 °C, GPU cap 650 MHz, game floor 430 MHz;
   `tweaks/customize.sh` has `nativeblur=false`,
   `supports_background_blur=0` in **both** blocks, no `zramsize=0`
   rewrite, swappiness 60 in all four places, no `etc/hyper` /
   `etc/perf` deletion; floating-feature blur flags `FALSE`;
   `vendor.prop` carries the 3 P1 SF props; **`carbon_power_engine`
   has `vm.swappiness=60`** (the F3-daemon fix — new in this guide,
   not yet in the skill's §10.1 checklist). The workflow's "Assert 60
   Hz pin" step must show PASS for every check.
4. **Boot image sanity.** `unpack_bootimg` the `boot.img`: kernel +
   DTB present, correct sizes for the 64 MB boot partition, no AVB
   signature where `TARGET_DISABLE_AVB_SIGNING=true`.
5. **Signing.** Confirm the zip is signed (or explicitly unsigned);
   record which key — throwaway test key vs real platform key. Never
   present a test-key build as a release build.
6. **Sizes.** ROM zip ~10–11 GiB is expected (Build #5:
   11,748,933,875 bytes; Build #7: 10.9 GB). Far smaller means
   something did not get packed — investigate before offering it.
7. **Build-log cross-check.** Open the `build-logs-<device>-<run_id>`
   artifact: confirm the "Use vendored m51 target" step logged the pin
   + all vendored files + the 9 RIL binaries present; the "Apply porter
   performance patches" step logged all **four** overrides; the "Assert
   60 Hz pin" step logged all PASS lines. A claim of "green" must name
   the checks that support it.

On-device proof (frame times, thermal/frequency logs, memory, 60 Hz
pin, and everything that only a flashed m51 can answer): skill §10.3.
The flash itself is the one step that needs the physical m51 — prepare
everything for it first (backup, Odin restore path, exact flash
commands, what to observe) and do every direct check above first.

## Device logging (when something goes wrong on the phone)

**m51-logger** (`tools/m51-logger/` in the `m51-hyperos` repo) collects
kernel, boot, recovery, system, camera, CPU/GPU, RAM and misc logs
from a real M51 into ONE timestamped bundle (`SUMMARY.md` +
`MANIFEST.txt` + raw files, packed as `.tar.gz`) — from a PC over ADB
(`collect-logs.sh`, one persistent connection) or on-device in Termux
(`collect-logs-termux.sh`, local reads only). Read-only: nothing is
written to system/vendor/boot/recovery. Full guide:
`m51-hyperos/docs/LOGGING-GUIDE.md` (includes the always-on ADB
options and the security note). Run it as soon as possible after a
problem — logcat is a ring buffer — and attach the whole `.tar.gz`
to the bug report.
