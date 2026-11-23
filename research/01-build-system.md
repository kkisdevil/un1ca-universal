# UN1CA build system — end-to-end research

Research date: 2026-11-23. Sources read live via public GitHub (raw files +
GitHub API), branches as noted. No private server was used.

Upstream repos:

- Base: <https://github.com/salvogiangri/UN1CA>, branch `sixteen`
  (HEAD `0c2ea1d` at time of reading)
- SM7150 fork 1: <https://github.com/mehedihjoy0/UN1CA-SM7150>, branch `sixteen`
  (HEAD `8822fda` at time of reading)
- SM7150 fork 2: <https://github.com/Arnav3078/UN1CA-SM7150>, branch `seventeen`
  (HEAD `f679035` at time of reading)
- Contrast only: <https://github.com/alrigroup/un1ca-carbon>, default branch
  `carbon-ix-v1.2.1` (HEAD `4870d8d` at time of reading)

Our project repo: <https://github.com/kkisdevil/un1ca-universal> (public,
GPL-3.0). Our workflow: `.github/workflows/build.yml`. Our tool setup:
`scripts/setup-tools.sh`. Both are verified against the upstream files
cited below; see §12.

> Scope note. UN1CA is a *porting* system, not a from-source Android
> build. There is no AOSP tree, no `lunch`, no `m`. The build takes
> Samsung's own stock firmware, unpacks it, patches it, rebuilds the
> system images, and re-packs them into a flashable zip. Everything
> below follows from that one fact.

---

## 1. The pipeline in one paragraph

```
source buildenv.sh <codename>     # pick target, generate out/config.sh
./scripts/build_dependencies.sh   # build host tools into out/tools/ (once)
./scripts/download_fw.sh          # samloader: fetch stock firmware from Samsung FUS
./scripts/extract_fw.sh           # unpack Odin tars, super.img, partitions
./scripts/make_rom.sh --build-rom-zip
    ├─ create_work_dir.sh         # copy source system/product into work dir
    ├─ apply platform patches → device patches → ROM patches → ROM mods
    ├─ rebuild APKs/JARs with apktool (parallel, max 8 jobs)
    ├─ create_target_files_zip.sh # rebuild fs images, build_info.txt, zip
    └─ build_flashable_zip.sh     # OTA-style flashable zip, signed if keys exist
```

Default `make_rom.sh` (no flags) builds only the target-files zip
(`<codename>_<version>-target_files.zip`). `-z / --build-rom-zip`
also produces the flashable zip
(`UN1CA_<version>_<YYYYMMDD>_<device>[-INCREMENTAL_<ts>][-sign].zip`).
`-f / --force` forces a rebuild; otherwise the build is skipped when
the work-dir hash in `out/target/<codename>/work_dir/.completed`
matches the current tree (`make_rom.sh`: `GET_WORK_DIR_HASH` over
`unica/`, `platform/<platform>/`, `target/<codename>/`).

---

## 2. Repo layout (base, branch `sixteen`)

| Path | What it is |
|---|---|
| `buildenv.sh` | Entry point. Sourced, not executed. |
| `scripts/` | The build commands (see §5). |
| `scripts/internal/` | `gen_config_file.sh`, `create_work_dir.sh`, `create_target_files_zip.sh`, `apply_modules.sh`, `build_full_ota_zip.sh`, `build_incremental_ota_zip.sh`, `update_prebuilt_blobs.sh` |
| `scripts/utils/` | `build_utils.sh`, `common_utils.sh`, `firmware_utils.sh`, `install_utils.sh`, `log_utils.sh`, `module_utils.sh`, `smali_utils.sh` |
| `unica/` | The ROM itself: `configs/` (`version.sh`, `qssi.sh`, `essi.sh`), `patches/`, `mods/`, `debloat.sh` |
| `target/<codename>/` | One dir per supported device: `config.sh`, `patches/`, `debloat.sh`, `overlay/`, `camera/`, `dvfs/`, `installer/`, `sff.sh` |
| `platform/<platform>/` | Shared platform code/patches (used when several targets share a platform) |
| `prebuilts/` | Prebuilt blobs, incl. `prebuilts/samsung/<device>/` (updated by `blobs.yml`) |
| `external/` | Git submodules: the host tools (see §6) |
| `security/` | Platform signing keys — **not in git**. CI decodes them from secrets (see §9). |
| `.github/workflows/` | `ci.yml`, `blobs.yml` |
| `out/` | Build output (created by the build, never committed): `out/odin/`, `out/fw/`, `out/tools/`, `out/target/<codename>/{apktool,work_dir,tmp}/`, final zips in `out/` |

Base `target/` (16 dirs at time of reading): `a52q a52sxq a53x a71 a72q
a73xq b0q g0q m52xq o1s p3s r0q r8q r9s t2s`. Note: base has **no**
`m51` — that target exists only in the SM7150 forks (§10).

---

## 3. `buildenv.sh` — how a build starts

File: `salvogiangri/UN1CA:buildenv.sh` (branch `sixteen`).

```bash
source ./buildenv.sh [--debug] <target>
# no argument → interactive `select` menu over target/ dirs
```

What it does:

1. Locates the tree root by walking up to `unica/configs/version.sh`
   (`_GET_SRC_DIR`, copied from AOSP `envsetup.sh`).
2. Exports directories:
   `SRC_DIR` (tree root), `OUT_DIR=$SRC_DIR/out`,
   `ODIN_DIR=$OUT_DIR/odin` (downloaded Odin packages),
   `FW_DIR=$OUT_DIR/fw` (extracted firmware),
   `TOOLS_DIR=$OUT_DIR/tools` (host tools, prepended to `PATH` as
   `$TOOLS_DIR/bin`).
3. Discovers targets from `target/` directory names.
4. Validates the target, then sets per-target dirs:
   `APKTOOL_DIR=$OUT_DIR/target/<codename>/apktool`,
   `WORK_DIR=$OUT_DIR/target/<codename>/work_dir`,
   `TMP_DIR=$OUT_DIR/target/<codename>/tmp`.
5. Runs `scripts/internal/gen_config_file.sh <target>` to generate
   `out/config.sh`, unsets any previously exported config vars, then
   sources it (`set -o allexport`). It prints the generated config.
6. Defines `unica` as an alias for `run_cmd`, which runs
   `scripts/<cmd>.sh` and tees a cleaned log to
   `out/target/<codename>/<cmd>-<YYYYMMDD_HHMMSS>.log`
   (ANSI colours stripped, `#` lines removed). **These per-command
   logs are what a failed build is diagnosed from** — see §11.

Usage inside the build: every script below assumes `buildenv.sh` has
been sourced first (they read `$SRC_DIR`, `$OUT_DIR`, `$FW_DIR`,
`$WORK_DIR`, `$SOURCE_FIRMWARE`, `$TARGET_FIRMWARE`, … from the
environment). Running any of them without it fails immediately.

---

## 4. Configuration — what a device port actually is

### 4.1 `scripts/internal/gen_config_file.sh` (33 KB)

Generates `out/config.sh` from three layers, in order:

1. `unica/configs/version.sh` — ROM version (base sixteen:
   `VERSION_MAJOR=3, MINOR=2, PATCH=1` → `ROM_VERSION="3.2.1-<short
   hash>"`, with `+` appended if commits exist since the last tag and
   `-dirty` if the tree is dirty).
2. `unica/configs/qssi.sh` (or `essi.sh`) — the **source** firmware:
   the Samsung flagship firmware whose One UI system is being ported.
   Mehedi (sixteen): Galaxy S22 Snapdragon,
   `SOURCE_FIRMWARE="SM-S901E/TUR/350999641234561"`, SDK 36 (One UI 8).
   Arnav (seventeen): Galaxy S23,
   `SOURCE_FIRMWARE="SM-S911B/INS/352404911234563"`, SDK 37 (One UI 9).
3. `target/<codename>/config.sh` — the **target** device.

Key variables (documented in the header of `gen_config_file.sh`):

| Variable | Meaning |
|---|---|
| `[SOURCE/TARGET]_FIRMWARE` | `"Model/CSC/IMEI"` — e.g. `SM-M515F/BVO/357563172596302`. The IMEI/serial is what Samsung's FUS server requires to serve the firmware. |
| `[SOURCE/TARGET]_EXTRA_FIRMWARES` | Extra firmwares to download/extract alongside (bash array, stored `:`-joined). m51: `("SM-G990B/EUX/353718681234563")` — S21 FE 5G firmware, used as an extra blob source. |
| `TARGET_NAME` | Display name, must match Samsung's floating-feature brand name. |
| `TARGET_CODENAME` | Must match `ro.product.vendor.device`. |
| `TARGET_PLATFORM` | Optional; shared platform dir under `platform/`. |
| `[SOURCE/TARGET]_PLATFORM_SDK_VERSION` | Must match `ro.build.version.sdk`. |
| `[SOURCE/TARGET]_PRODUCT_SHIPPING_API_LEVEL` | Must match `ro.product.first_api_level`. |
| `[SOURCE/TARGET]_BOARD_API_LEVEL` | Must match `ro.board.api_level`. |
| `TARGET_ASSERT_MODEL` | Model numbers the zip asserts on install (`ro.boot.em.model`); m51: `("SM-M515F")`. |
| `TARGET_DISABLE_AVB_SIGNING` | `true` for m51 — kernel images are not AVB-signed. Default `false`. |
| `TARGET_KEEP_ORIGINAL_SIGN` | Keep the original AVB/Samsung signature footer on kernel images. |

### 4.2 `target/m51/config.sh` (SM7150 forks)

Galaxy M51, SM7150 (Snapdragon 732G):

```ini
TARGET_NAME="Galaxy M51"
TARGET_CODENAME="m51"
TARGET_ASSERT_MODEL=("SM-M515F")
TARGET_FIRMWARE="SM-M515F/BVO/357563172596302"
TARGET_EXTRA_FIRMWARES=("SM-G990B/EUX/353718681234563")
TARGET_PRODUCT_SHIPPING_API_LEVEL=29
TARGET_BOARD_API_LEVEL=30
# mehedi (sixteen): TARGET_PLATFORM_SDK_VERSION=31, TARGET_OS_FILE_SYSTEM_TYPE="erofs"
# arnav (seventeen): TARGET_PLATFORM_SDK_VERSION=33 (no explicit fs type)
TARGET_BOOT_PARTITION_SIZE=67108864
TARGET_DTBO_PARTITION_SIZE=10485760
TARGET_SUPER_PARTITION_SIZE=8053063680
TARGET_CACHE_PARTITION_SIZE=419430400
TARGET_USE_DYNAMIC_PARTITIONS=true
TARGET_SUPER_GROUP_NAME="qti_dynamic_partitions"
TARGET_QTI_DYNAMIC_PARTITIONS_SIZE=8048869376
TARGET_OS_SINGLE_SYSTEM_IMAGE="qssi"
TARGET_OS_BUILD_SYSTEM_EXT_PARTITION=false
TARGET_DISABLE_AVB_SIGNING=true
# + ~50 SEC Product Feature flags (Bluetooth, audio, camera, LCD,
#   DVFS policy dvfs_policy_sm7150_xx / siop_m51_sm7150, fingerprint
#   sensor google_touch_side, RIL, WLAN …) — see the file itself.
```

Differences mehedi → arnav (sixteen → seventeen): SDK 31 → 33,
`TARGET_OS_FILE_SYSTEM_TYPE` dropped, Bluetooth A2DP-sink
`false → true`, HDR effect `true → false`, RIL features `"" →
"onebinary embms_qc"`, ESE chip vendor fields added. The target
directory also contains `camera/`, `debloat.sh`, `dvfs/`,
`installer/`, `overlay/`, `patches/`, `sff.sh`.

> IMEI note. The `357563172596302` value is the one shipped in the
> public fork. Treat it as the fork's download credential, not as a
> device to copy: never publish a personal IMEI. If FUS rejects it,
> the fix is a valid model-matching IMEI/serial for that model, kept
> out of git (see §11, failure 3).

### 4.3 Where to modify the ROM

| To change… | Edit… |
|---|---|
| ROM-wide features/mods | `unica/mods/` (applied by `apply_modules.sh`) |
| ROM-wide patches | `unica/patches/` |
| Debloat (apps/services removed) | `unica/debloat.sh` and `target/<codename>/debloat.sh` |
| One device only | `target/<codename>/` — `config.sh`, `patches/`, `overlay/`, `camera/`, `dvfs/`, `installer/` |
| Shared by several devices | `platform/<platform>/patches/` |
| Version number | `unica/configs/version.sh` (`VERSION_MAJOR/MINOR/PATCH`) |
| Source (donor) firmware | `unica/configs/qssi.sh` (`SOURCE_FIRMWARE`, SDK levels) |

Patches/mods are applied by `scripts/internal/apply_modules.sh`
(a directory of modules) in this order: platform patches → device
patches → ROM patches → ROM mods (`make_rom.sh`).

---

## 5. Scripts inventory

`scripts/` (top level, each runnable as `unica <cmd>` after sourcing
`buildenv.sh`):

| Script | Job |
|---|---|
| `build_dependencies.sh` | 19 bytes: just `../external/make.sh` (see §6). |
| `download_fw.sh` | Download source + target (+ extra) firmwares (§7). |
| `extract_fw.sh` | Unpack Odin tars / super.img / partitions (§8). |
| `make_rom.sh` | Whole ROM build; flags `-f/--force`, `-x/--no-target-files`, `-z/--build-rom-zip` (§1, §9). |
| `build_fs_image.sh` | Rebuild one fs image (erofs/ext4/f2fs) from a work-dir tree, with AVB hashtree sizing (mirrors AOSP `build_image.py`). |
| `build_flashable_zip.sh` | Target-files zip → flashable zip (`-i/--incremental <source>`, `-o/--output <file>`). |
| `apktool.sh` | Rebuild one APK/JAR (`b` subcommand, `-j` jobs). Called in parallel by `make_rom.sh` (max 8 jobs). |
| `cleanup.sh` | Clean build outputs. |
| `generate_ota_manifest.sh` | OTA manifest for the UN1CA Updates app. |
| `unsign_bin.sh` | Strip signatures from binaries. |
| `print_modules_info.sh` | List available patches/mods. |

`scripts/internal/`: `gen_config_file.sh` (§4.1),
`create_work_dir.sh` (§8), `create_target_files_zip.sh` (§9),
`apply_modules.sh`, `build_full_ota_zip.sh` (§9),
`build_incremental_ota_zip.sh`, `update_prebuilt_blobs.sh`
(used by `blobs.yml`).

`scripts/utils/`: `firmware_utils.sh` (FUS download, version
compare, tar extraction), `common_utils.sh` (24 KB),
`install_utils.sh`, `build_utils.sh`, `log_utils.sh`,
`module_utils.sh`, `smali_utils.sh`.

---

## 6. How the host tools are built

`scripts/build_dependencies.sh` → `external/make.sh`. Submodules
(`.gitmodules`, so `actions/checkout` **must** use
`submodules: 'recursive'`):

| Submodule | Upstream |
|---|---|
| `external/android-tools` | `github.com/UN1CA/external_android-tools` |
| `external/apktool` | `github.com/iBotPeaches/Apktool` (+ UN1CA patch `external/patches/apktool/0001-feat-support-aapt-optimization.patch`) |
| `external/erofs-utils` | `github.com/sekaiacg/erofs-utils` |
| `external/img2sdat` | `github.com/UN1CA/external_img2sdat` |
| `external/samloader` | `github.com/ananjaser1211/samloader` |
| `external/signapk` | `github.com/UN1CA/external_signapk` |

`external/make.sh` builds each tool into `out/tools/bin/` (and a
Python venv at `out/tools/venv/` for samloader), **skipping any tool
already present** (`CHECK_TOOLS`, `--check-tools` mode):

- **android-tools**: CMake + clang (+ccache if present), `make -j$(nproc)`;
  installs `adb, avbtool, mkbootimg, unpack_bootimg, repack_bootimg,
  mkdtboimg, lpmake, lpunpack, simg2img, img2simg, mke2fs, mkuserimg_mke2fs,
  make_f2fs, fastboot, …` (~30 binaries).
- **apktool**: `git reset --hard`, apply the aapt-optimisation patch,
  `./gradlew build shadowJar` → `apktool.jar` + `apktool` launcher.
- **erofs-utils**: CMake (`-DENABLE_FULL_LTO=ON -DMAX_BLOCK_SIZE=4096`)
  → `mkfs.erofs, dump.erofs, extract.erofs, fsck.erofs, fuse.erofs`.
- **img2sdat**: copy the Python scripts (`img2sdat`, `blockimgdiff.py`,
  `common.py`, `images.py`, `rangelib.py`, `sparse_img.py`).
- **samloader**: `python3 -m venv out/tools/venv`, `pip3 install .`
  (provides the `samloader` command used by `download_fw.sh`).
- **signapk**: `./gradlew build` → `signapk.jar` + launcher.

Gradle builds (apktool, signapk) need JDK 17 — that is why CI runs
`actions/setup-java@v6` (base) / `@v4` (arnav) with Temurin 17
**before** building dependencies. CMake builds use clang/clang++
from the apt list (§9).

---

## 7. Firmware download — `download_fw.sh`

- Input: `SOURCE_FIRMWARE`, `TARGET_FIRMWARE`,
  `[SOURCE/TARGET]_EXTRA_FIRMWARES` from `out/config.sh`, each
  `"Model/CSC/IMEI-or-serial"`.
- Latest-version check first: `GET_LATEST_FIRMWARE` (in
  `scripts/utils/firmware_utils.sh`) queries Samsung's FOTA server:
  `curl -s --retry 3 -m 3 -A "samsung <model> SyncML DM Client"
  https://fota-cloud-dn.ospserver.net/firmware/<CSC>/<MODEL>/version.xml`
  and extracts `<latest>…</latest>` (`PDA/CSC/MODEM`). Version
  comparison (`COMPARE_SEC_BUILD_VERSION`) parses Samsung's build
  scheme (`A528BXXU1DWA4`: model / region / type / rollback bit /
  OS letter / year / month / incremental).
- Download: `samloader -m <MODEL> -r <CSC> -i <IMEI> -s <SERIAL>
  download -O out/odin/<MODEL>_<CSC>` (run with cwd `$OUT_DIR`,
  because samloader writes its logs there). The zip is unzipped in
  place and deleted.
- Verification: every `*.md5` Odin package is verified against the
  MD5 Samsung appends to the end of the file (32 hex chars + 2 spaces
  + filename + newline). A hash mismatch or unparsable hash aborts
  the build.
- Skip logic: if the firmware is already downloaded/extracted and
  its version is ≥ the latest from FUS, the step is skipped (unless
  `--force`). Marker files: `out/odin/<MODEL>_<CSC>/.downloaded`,
  `out/fw/<MODEL>_<CSC>/.extracted`.
- Upstream CI wraps this step in `nick-fields/retry@v4`
  (`timeout_minutes: 60, max_attempts: 3, retry_on: error`) — the
  download is the flakiest step (see §11).

---

## 8. Firmware extraction — `extract_fw.sh`

For each firmware (source, target, extras):

1. Find `BL_<PDA>*.md5` and `AP_<PDA>*.md5` in
   `out/odin/<MODEL>_<CSC>/`. Missing either → abort.
2. `EXTRACT_KERNEL_BINARIES` — kernel images from the BL/AP tars.
3. `EXTRACT_OS_PARTITIONS` — from `AP`:
   - If `super.img` (or `super.img.lz4`) exists: extract, unsparse,
     `lpunpack` each partition (Virtual A/B: only the `_a` slot is
     filled, renamed to `<partition>.img`), delete `super.img`.
   - Else: extract the individual `system.img vendor.img product.img
     system_ext.img odm.img vendor_dlkm.img odm_dlkm.img system_dlkm.img`
     and unsparse each.
   - Filesystem detection by magic bytes (`GET_IMAGE_FILE_SYSTEM`):
     ext4 `ef53` @1080, f2fs `f2f52010` @1024, erofs `e0f5e1e2` @1024.
   - Each image is **mounted read-only as root** (`sudo` — required;
     on GitHub runners `sudo` is passwordless) — `fuse.erofs` for
     erofs, `mount -o ro` otherwise — copied with `cp -a`, then
     `fs_config-<partition>` (uid/gid/mode via `stat`, parallel
     `xargs -P $(nproc)`) and `file_context-<partition>` (SELinux
     contexts via `getfattr -n security.selinux`) are generated and
     sorted. Capabilities are only set for known files (`run-as`,
     `simpleperf_app_runner` → `0xc0`); the script notes a general
     capability mechanism is still TODO.
   - `.img` files are deleted after unpacking.
4. `EXTRACT_AVB_BINARIES`.
5. Write `.extracted`; **on GitHub Actions (`$GITHUB_ACTIONS` set)
   the downloaded Odin dir is deleted afterwards** to save disk.

`create_work_dir.sh` then copies `system` + `product` from the
**source** firmware into `WORK_DIR` (rsync, `system_ext` excluded
from the rsync and handled separately depending on
`TARGET_OS_BUILD_SYSTEM_EXT_PARTITION`), rewrites
`ro.product.device` / `ro.product.product.name` from the target
firmware's build props, and merges the target's device-specific
files. The work dir is what patches, mods and apktool then operate
on.

---

## 9. Target-files zip → flashable zip

### 9.1 `scripts/internal/create_target_files_zip.sh`

For each directory in `WORK_DIR`:

- Rebuild the fs image with `scripts/build_fs_image.sh
  <fs-type> -o <partition>.img -m -S [ -s <size> ]
  <work-dir> <file_context> <fs_config>` (fs type from
  `TARGET_OS_FILE_SYSTEM_TYPE`, e.g. `erofs`; fixed size only for
  non-dynamic partitions, from `TARGET_<NAME>_SIZE`).
- Dynamic partitions: also build `unsparse_super_empty.img`
  (`BUILD_SUPER_EMPTY`).
- Kernel images (`boot.img dt.img dtbo.img init_boot.img
  vendor_boot.img` from `WORK_DIR/kernel/`) are copied and AVB-signed
  (`SIGN_IMAGE_WITH_AVB`) **unless** `TARGET_DISABLE_AVB_SIGNING=true`
  (m51 sets it — no signing).
- Generate `build_info.txt` (`GENERATE_BUILD_INFO`: version,
  timestamp, device), then `7z a -tzip -mx=3 -mmt=$(nproc) -mtc=off
  -mtm=off <output> -r *`.

### 9.2 `scripts/internal/build_full_ota_zip.sh` (+ `build_flashable_zip.sh`)

- `build_flashable_zip.sh` names the output:
  `out/UN1CA_<version>_<YYYYMMDD>_<device>[-INCREMENTAL_<ts>][-sign].zip`
  (`-sign` unless `DEBUG` or unofficial); `--incremental` uses
  `build_incremental_ota_zip.sh` instead.
- `build_full_ota_zip.sh`: creates
  `META-INF/com/google/android/update-binary` from
  `prebuilts/bootable/deprecated-ota/updater`, unzips the target-files
  zip, generates the `updater-script` (`GENERATE_UPDATER_SCRIPT`:
  device assert from `TARGET_ASSERT_MODEL`, partition flashing,
  AVB/verity handling), `build_info.txt`, OTA metadata
  (`GENERATE_OTA_METADATA`), then packs with 7z in two passes
  (`.patch.dat` + `META-INF/com/android/*` at `-mx=0`, everything
  else at `-mx=3`).
- Signing of the final zip uses the platform keys in `security/`:
  `security/unica_platform.pk8` + `security/unica_platform.x509.pem`.
  **These files are not in git.** Upstream CI decodes them from
  repository secrets on every run. Without them the zip is built
  unsigned (and the filename omits `-sign` when `DEBUG` is set).
  Never commit real keys.

---

## 10. Upstream CI — what runs in GitHub Actions

### 10.1 Base `salvogiangri/UN1CA:.github/workflows/ci.yml` (branch `sixteen`)

Triggers: `workflow_dispatch`, `pull_request`, `push` to `sixteen`.
Concurrency group per workflow+ref, `cancel-in-progress: true`.
Runner: `ubuntu-24.04`. Three jobs:

1. **shellcheck** — `shellcheck -e SC1090,SC1091 -s bash` over every
   `*.sh` under `platform scripts target unica` (excluding `*ssi.sh`,
   `config.sh`, `sff.sh`).
2. **generate-matrix** — matrix = sorted `target/` directory names
   (via `jq`).
3. **build** (matrix over every target, `fail-fast: false`):
   checkout (`submodules: 'recursive'`) → free disk (3 steps, §12)
   → apt install + `modprobe erofs f2fs` + git bot identity +
   platform keys from secrets → JDK 17 (`actions/setup-java@v6`,
   Temurin, Gradle cache) → `source ./buildenv.sh <target>`, export
   config to `$GITHUB_ENV`, add `$TOOLS_DIR/bin` to `$GITHUB_PATH` →
   `./scripts/build_dependencies.sh` → download (retry ×3, 60 min) →
   `./scripts/extract_fw.sh` → `./scripts/make_rom.sh` (target-files
   zip only — **no flashable zip in base CI**).

### 10.2 Base `.github/workflows/blobs.yml`

Daily (`0 12 * * *`) + manual. Same env setup, then for each of 10
device/firmware pairs runs
`./scripts/internal/update_prebuilt_blobs.sh <device> <firmware>`
and opens a PR with `peter-evans/create-pull-request@v8` updating
`prebuilts/samsung/<device>/`.

### 10.3 SM7150 forks — `ci.yml` (both forks, heavily modified vs base)

Mehedi (sixteen) and Arnav (seventeen) share the same rewritten
`ci.yml` (Arnav adds caching + GoFile; see below). Differences from
base:

- Trigger is `workflow_dispatch` only, with inputs: `device`
  (Arnav default `"m51"`, Mehedi default `""`), `incremental_ota`,
  `release_rom`, `changelog`, `upload` (PixelDrain).
- No matrix job: one device per run, matrix over
  `build_type: [encrypted, decrypted]` (upstream `BUILD_TYPE` env).
- Checkout with `fetch-depth: 1`.
- apt adds `gh` (Mehedi) / `gh jq curl python3` (Arnav); Arnav drops
  `linux-modules-extra-*` and uses `modprobe erofs || true` /
  `modprobe f2fs || true`.
- **`./scripts/make_rom.sh --build-rom-zip`** — the forks build the
  flashable zip, base CI does not.
- Optional `./scripts/build_incremental.sh` and
  `./scripts/release_rom.sh` (both exist in both forks, HTTP 200).
- PixelDrain upload via `go-pixeldrain` v0.7.6 (needs a
  PixelDrain API key secret).
- Arnav only: `actions/cache@v4` for build tools
  (`tools/bin`, `tools/venv`, key from `scripts/build_dependencies.sh`
  hash) and for stock firmwares (`out/odin`, `out/cache`, key from
  `unica/configs/qssi.sh` + `target/m51/config.sh` hashes).

### 10.4 Arnav only — `.github/workflows/build-gofile.yml`

Same build as Arnav `ci.yml` but with a `prepare` job that turns the
`build_type` input (`decrypted` / `encrypted` / `both`) into a matrix,
`actions/setup-java@v4` (vs `@v6` in base), platform keys written
**only if the secret is non-empty** (base fails the step when the
secrets are absent), `nick-fields/retry@v3`, and two outputs:
GoFile upload (`./scripts/upload_gofile.py`, needs a GoFile token)
plus `actions/upload-artifact@v4` fallback
(`name: UN1CA-<device>-<build_type>`, `retention-days: 7`,
`if-no-files-found: warn`, `if: always()`). This file is the closest
upstream model for our own workflow.

### 10.5 Carbon (contrast)

`alrigroup/un1ca-carbon` has **no** `.github/workflows/` at all.
It is a finished distribution, not a build system: `core_unica/`
(UN1CA core, GPL-3.0), `carbon_engine/` (C++20 engine),
`carbon_ours/`, `vendors_npl/`, `vendors_rezoss/`, and
`make_carbon.sh` / `make_carbon_engine.sh` (local build scripts,
not Actions workflows). Its releases are prebuilt 8 GB zips. Do not
copy its structure for a build workflow; it shows what a finished
port looks like, not how to build one.

### 10.6 Action / tool versions actually used upstream

| Tool | Base `ci.yml` | Arnav `ci.yml` / `build-gofile.yml` | Our `build.yml` |
|---|---|---|---|
| `actions/checkout` | `@v7` | `@v4` | `@v7` (base) |
| `actions/setup-java` | `@v6`, Temurin 17 | `@v4`, Temurin 17 | `@v6` (base) |
| `actions/cache` | — | `@v4` | `@v4` |
| `actions/upload-artifact` | — | `@v4` | `@v4` |
| `nick-fields/retry` | `@v4` | `@v3` | `@v4` (base) |
| `jlumbroso/free-disk-space` | `@main` | `@main` | `@main` |
| `rokibhasansagar/slimhub_actions` | `@main` | `@main` | `@main` |
| `peter-evans/create-pull-request` | `@v8` (blobs.yml) | — | — |
| Runner | `ubuntu-24.04` | `ubuntu-24.04` | `ubuntu-24.04` |

---

## 11. Most likely build failure points — and the fix for each

Standing user rule: **if it fails, modify and fix, and repeat the
modify-and-fix loop until it builds. Do not stop at the first failure
and do not just report the error.** Our workflow implements this by
uploading build logs as artifacts on every run (even on failure),
surfacing the outcome in the run summary, and being re-runnable via
`workflow_dispatch` — see §12.

Evidence note: upstream tracks support in Discussions/Telegram, not
in GitHub Issues — `salvogiangri/UN1CA` and
`mehedihjoy0/UN1CA-SM7150` both had **0 open Issues** when checked
2026-11-23. The list below is therefore derived from the failure
guards already present in the code (retry wrappers, `|| true`,
conditional secret handling, skip logic, cache keys) and from the
mechanics in §§6–9 — each entry names the code that shows the
failure is expected, and the fix.

### 1. Runner runs out of disk (most likely, and the first thing to check)

- **Why:** a standard public-repo runner has ~14 GB usable disk
  after the image. One build downloads 2+ firmwares (multi-GB zips),
  extracts Odin tars, unpacks super.img/partitions (tens of GB),
  copies them into a work dir, rebuilds fs images, and writes two
  multi-GB zips. Upstream CI spends three whole steps freeing disk
  for exactly this reason.
- **Symptoms:** `No space left on device` in download/extract/make_rom
  logs; 7z/mkfs.erofs failures; the job dies mid-step.
- **Fix:** keep all three free-disk steps (rm dotnet/Android/GHC/
  CodeQL, docker prune, `jlumbroso/free-disk-space`,
  `rokibhasansagar/slimhub_actions` retain `compiler_cmake`).
  Keep the firmware cache (Arnav) so a retry does not re-download.
  Do **not** add extra retained artefacts to the runner. If a build
  still runs out of disk, the honest fix is a larger runner
  (paid, 75 GB+ disk) or splitting the build — not deleting the
  cleanup steps. Our workflow snapshots `df -h` + `du -sh out/*`
  into the logs artifact so the next run can see exactly where the
  disk went.

### 2. Firmware download fails or returns nothing

- **Why:** `download_fw.sh` depends on Samsung's FUS/FOTA servers
  (`samloader` + `fota-cloud-dn.ospserver.net`). The server can
  throttle, time out, or return no `<latest>` version; a wrong
  model/CSC/IMEI gives no firmware at all. Upstream wraps this step
  in `nick-fields/retry` (60 min, 3 attempts) — the only step with a
  retry wrapper, which is the tell.
- **Symptoms:** `Latest available firmware could not be fetched`,
  `Download failed`, retry attempts in the log, `No BL/AP tar found`
  at extract time.
- **Fix:** re-run (retry usually succeeds); check the firmware string
  in `target/<codename>/config.sh` and `unica/configs/qssi.sh`
  (`Model/CSC/IMEI` — IMEI must match the model); check whether FUS
  has a newer build than the cached one (the skip logic compares
  against FUS — a stale `.downloaded` marker with `--force` clears
  it). Do not "fix" this by hard-coding a firmware URL: FUS links
  are signed and short-lived.

### 3. `extract_fw.sh` aborts: missing BL/AP tar, bad MD5, or mount failure

- **Why:** the Odin zip layout changes between firmware revisions
  (tar names are matched by glob `BL_<PDA>*.md5` / `AP_<PDA>*.md5`);
  a truncated download fails the trailing-MD5 check; mounting
  partitions needs passwordless `sudo` plus the `erofs`/`f2fs`
  kernel modules.
- **Symptoms:** `No BL tar found` / `No AP tar found`, `File is damaged`,
  `Root permissions are required to unpack OS partitions`,
  `fuse.erofs` / `mount` errors.
- **Fix:** re-download with `--force` (bad MD5 = truncated download);
  check the PDA in the tar names matches `DOWNLOADED_FIRMWARE`;
  keep `sudo modprobe erofs || true` / `f2fs || true` (Arnav's form —
  base's bare `modprobe` fails the step if the module is built-in);
  never run the extract step without `sudo` available.

### 4. Host-tool build fails (apktool / signapk Gradle, android-tools CMake)

- **Why:** Gradle needs JDK 17 (apktool `shadowJar`, signapk `build`);
  CMake needs clang + the dev libraries; the apktool patch must apply
  cleanly to the checked-out Apktool submodule version; a shallow or
  partial submodule checkout breaks all of it.
- **Symptoms:** `./gradlew` errors, `cmake` configure errors,
  `git apply …/0001-feat-support-aapt-optimization.patch` failing,
  `make.sh: BUILD FAILED!`.
- **Fix:** checkout **must** use `submodules: 'recursive'` (never
  `fetch-depth` without submodules); keep `actions/setup-java`
  Temurin 17 **before** `build_dependencies.sh`; keep the exact apt
  list (§9); if the apktool patch fails, the pinned Apktool submodule
  has moved — pin it back or update the patch, do not delete the patch
  step. `external/make.sh` skips tools already present, so a retry
  after fixing the environment resumes where it left off.

### 5. `shellcheck` fails the run before any build starts

- **Why:** base CI runs shellcheck on every `*.sh` under `platform
  scripts target unica` (`-e SC1090,SC1091`). Any new or edited
  script with a shellcheck error blocks the whole matrix.
- **Symptoms:** CI red on the `shellcheck` job; no build job runs.
- **Fix:** run `shellcheck -e SC1090,SC1091 -s bash` on changed
  scripts locally / in a validate job before pushing; fix the
  flagged line (quoting, unused vars) rather than adding exclusions.
  Our repo has a separate `validate.yml` for this; `build.yml`
  validates the device JSON first for the same reason.

### 6. Missing platform signing keys

- **Why:** `security/unica_platform.pk8` / `.x509.pem` are not in git;
  base CI decodes them unconditionally from secrets, so a run
  without the secrets fails at that step. Arnav's `build-gofile.yml`
  writes them only `if [ -n … ]` — the safer form.
- **Symptoms:** base64 decode errors / empty key files; signing
  failures late in the build.
- **Fix:** add the two base64 secrets to the repository (never commit
  the raw keys); our `setup-tools.sh` warns and continues when they
  are absent, so dry-run still works and a full build fails loudly
  at signing, not mysteriously at setup. For a first full build,
  generate a throwaway test keypair rather than reusing a production
  one — and record that it is a test key.

### 7. Wrong target / stale config

- **Why:** `buildenv.sh` rejects unknown codenames; a `config.sh`
  whose SDK/API levels don't match the firmware's `build.prop`
  values produces a ROM that flashes but misbehaves (or fails the
  updater assert). `make_rom.sh`'s hash skip can also hide a change:
  if only files outside `unica/`, `platform/`, `target/` changed,
  it reports "No changes have been detected" and skips the build.
- **Symptoms:** `"m51" is not a valid device`, assert failures in
  recovery, stale zip reused.
- **Fix:** validate the device first (`devices/<codename>.json` +
  upstream `target/<codename>/config.sh` must exist — our `validate`
  job does this); use `make_rom.sh --force` when in doubt; keep the
  SDK/API-level values in the device config in sync with the actual
  firmware props.

### 8. Job killed at the 6-hour cap

- **Why:** GitHub caps a hosted-runner job at 6 hours (see §12).
  A cold build (tools + 2 firmwares + extract + apktool + images +
  zips) is multi-hour; a slow download can push it over.
- **Symptoms:** job terminated mid-step with no error from the
  script itself; the log just stops.
- **Fix:** rely on the caches (tools + firmwares) so retries are
  warm; keep the download retry tight (60 min per attempt, 3 max);
  do not add work to the build job. If cold builds regularly exceed
  6 hours, split the pipeline (tools+download+extract in one
  workflow run, ROM build in the next, passing artefacts) rather
  than raising the timeout — the cap cannot be raised on hosted
  runners.

### 9. Apktool rebuild failures on a specific APK/JAR

- **Why:** `make_rom.sh` rebuilds every APK/JAR under
  `APKTOOL_DIR` in parallel (max 8). One bad APK (new resource
  format, missing framework, aapt optimisation patch mismatch)
  fails the whole step.
- **Symptoms:** `apktool.sh b …` failing for one named APK/JAR.
- **Fix:** reproduce that single APK locally via
  `./scripts/apktool.sh b -j <n> <partition> <file>`; fix the
  decompile/rebuild issue in the patch/mod that touched it, or
  exclude the file from rebuilding if it was never meant to be
  rebuilt. Do not raise the parallel-job cap — it exists because
  the runner has 4 vCPUs.

---

## 12. What we built in `kkisdevil/un1ca-universal` (verified 2026-11-23)

### 12.1 `.github/workflows/build.yml`

Modelled on Arnav `build-gofile.yml` + base `ci.yml` (see §10.6 for
the exact action versions). Verified after writing: YAML parses,
2 jobs (`validate`, `build`), 7 inputs, 21 build steps,
`timeout-minutes: 360`, no redaction placeholders in the file.

- **Trigger:** `workflow_dispatch` only. Inputs: `device`
  (default `m51`), `source_repo` (choice: `Arnav3078/UN1CA-SM7150`
  default / `mehedihjoy0/UN1CA-SM7150`), `source_branch` (default
  `seventeen`), `build_type` (`decrypted` / `encrypted`),
  `mode` (`dry-run` default / `full`), `release_rom`,
  `changelog`.
- **Jobs:** `validate` (runs `scripts/validate-device.sh` on
  `devices/<codename>.json`, `--check-upstream`) → `build`.
- **Build order:** free disk (3 upstream steps) → checkout
  un1ca-universal → checkout upstream fork into `./upstream`
  (`submodules: 'recursive'`, `fetch-depth: 1`) → `setup-tools.sh`
  → JDK 17 (`setup-java@v6`) → `source ./buildenv.sh $DEVICE`,
  config to `$GITHUB_ENV` → dry-run report (dry-run mode) → cache
  tools → build dependencies → cache firmwares → download (retry
  ×3, 60 min) → extract → `make_rom.sh --build-rom-zip` →
  optional `release_rom.sh` → ROM artifact (7 days) → collect logs
  + `df -h` snapshot → logs artifact (14 days) → build summary
  in `$GITHUB_STEP_SUMMARY` (outcome, source, run id, artifact
  names; on failure, the fix-and-retry instruction).
- **Re-runnable:** `workflow_dispatch` on every run; concurrency
  group per workflow+ref+device with `cancel-in-progress: true`;
  no step depends on a previous run except the best-effort caches.
- **Modify-and-fix loop:** every run uploads `build-logs-<device>-<run_id>`
  (`if: always()`), including `config.sh`, every `*.log` under
  `upstream/out/`, `disk-usage.txt`, and `build-summary.txt`. The
  run summary names the outcome. Fix → commit → re-dispatch.
  Repeat until the ROM builds.

### 12.2 `scripts/setup-tools.sh`

Mirrors upstream's "Set up build environment" step. Verified:
`bash -n` syntax OK; `--check-only` mode; apt list is Arnav's
seventeen list verbatim (`attr ccache clang ffmpeg gh libbrotli-dev
libbz2-dev libgtest-dev libprotobuf-dev libunwind-dev libpcre2-dev
libzstd-dev lld protobuf-compiler webp jq curl python3`), with an
optional `--with-linux-modules-extra` flag for the base list;
`modprobe erofs || true` / `f2fs || true`; git bot identity;
platform keys decoded from the environment **only if both are set**
(warns and continues otherwise, so dry-run works without secrets);
JDK 17 is deliberately *not* installed here — the workflow's
`setup-java` step does it, and checks `java -version` right after
(an earlier version of the script required `java` in its own
check and would have failed every run).

### 12.3 Runner limits, honestly

Public repo, standard Linux runner (`ubuntu-24.04`):
**4 vCPU, 16 GB RAM, 14 GB SSD usable after the image; 6-hour job
cap; 35-day workflow-run cap; 20 concurrent jobs on Free; cache
10 GB per repo (entries unused 7 days are evicted); artifacts kept
90 days by default.** Private repo: same disk, but 2 vCPU / 8 GB RAM.
Sources: GitHub's hosted-runner/limits docs via runners.io, dev.to,
stephane-robert.info, webdevkb.dev (checked 2026-11-23; all agree on
these figures).

What this means for a full build: it is **not guaranteed to fit**.
Two stock firmwares plus extraction plus rebuilt images plus two
zips is tens of GB — the only reason upstream CI fits at all is the
three free-disk steps and the firmware/tool caches. A cold full
build on a fresh runner is the riskiest run; that is why our
workflow defaults to `dry-run` and why the first real test should
be a warm-cache full build, watched against the 6-hour cap. Larger
runners (paid, 75 GB–2 TB disk) are the honest fallback if the
standard runner cannot fit a given device; they are not free on
public repos.

---

## 13. Build prerequisites & commands (local / manual)

Prerequisites (same as CI): Ubuntu 24.04 (or a VM/container of it),
passwordless `sudo`, ~60 GB free disk, git, and the apt list in §12.2
plus JDK 17. No private server is involved at any point.

```bash
git clone --recurse-submodules https://github.com/mehedihjoy0/UN1CA-SM7150
# or: git clone --recurse-submodules https://github.com/Arnav3078/UN1CA-SM7150
cd UN1CA-SM7150
git checkout sixteen   # mehedi; seventeen for arnav
source ./buildenv.sh m51
./scripts/build_dependencies.sh   # builds host tools into out/tools/ (once)
./scripts/download_fw.sh          # multi-GB; retry on failure
./scripts/extract_fw.sh
./scripts/make_rom.sh --build-rom-zip
# output: out/UN1CA_<version>_<YYYYMMDD>_m51[-sign].zip
```

Useful variants: `unica --help` (lists all `scripts/*.sh` commands);
`./scripts/make_rom.sh --force` (ignore the work-dir hash);
`./scripts/download_fw.sh --force` (re-download);
`source ./buildenv.sh --debug m51` (verbose).

---

## 14. Open questions / not yet verified

1. **Full-build fit on a standard runner.** No full build has been
   run yet in this project. The first `mode: full` run for m51 is
   the real test of §11.1/§11.8. If it exceeds disk or the 6-hour
   cap, the fix is the firmware/tool caches (already in the
   workflow) and, failing that, a larger runner — not removing the
   cleanup steps.
2. **Platform signing keys.** No keys exist for this project yet.
   A full build without them produces an unsigned zip (or fails at
   signing, depending on the step). Decide: throwaway test keypair
   first, and record that it is a test key.
3. **`BUILD_TYPE` (encrypted/decrypted).** The forks' CI sets it,
   but base `gen_config_file.sh` does not reference it; its handling
   lives in the forks' own scripts. Do not assume it does anything
   in a base checkout.
4. **IMEI in `target/m51/config.sh`.** The shipped value works for
   the fork's downloads; if FUS rejects it, a model-matching
   IMEI/serial is needed (kept out of git).
5. **Carbon.** No CI, no build workflow — not a build reference.
   Only useful as an example of a finished S23 port.
