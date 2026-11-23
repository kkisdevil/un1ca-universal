# UN1CA targets — base vs SM7150 forks (02)

Researched 2026-11-23, read-only, GitHub-only. No user servers were used.
Method: GitHub Contents API + `raw.githubusercontent.com` for the three repos
below. A shallow `git clone` was started and then stopped on an
execution-risk check on the clone output — no cloned code was run, read,
or copied into this project. Everything below is from the API / raw file
reads listed in the sources.

## Repos and branches checked

| Repo | Branch | UN1CA version (`unica/configs/version.sh`) | `target/` count |
|---|---|---|---|
| `salvogiangri/UN1CA` (base) | `sixteen` | 3.2.1 | 15 |
| `mehedihjoy0/UN1CA-SM7150` | `sixteen` | 3.2.1 | 16 |
| `Arnav3078/UN1CA-SM7150` | `seventeen` | 5.4.0 | 16 |

Arnav's repo description is "UN1CA 5.x One UI 9 And One UI 9.5 For M51".
`sixteen` vs `seventeen` is therefore a different UN1CA generation, not a
rename: same 16 codenames in both forks, but per-device values differ
(m51: `TARGET_PLATFORM_SDK_VERSION` 31 on sixteen / 33 on seventeen,
different RIL / ESE / debloat / `sff.sh` — see §4). Do not assume a
`sixteen` patch applies cleanly to `seventeen`.

## 1. Codename table — base vs forks

`TARGET_NAME`, `TARGET_CODENAME`, `TARGET_FIRMWARE` and
`TARGET_PLATFORM_SDK_VERSION` are quoted from each
`target/<codename>/config.sh`. `TARGET_PLATFORM` is quoted only when the
file actually sets it; several files omit it (see the note after the
table). The SoC column for those files is inferred from the DVFS/SSRM
filenames in the same file (e.g. `dvfs_policy_sm7150_xx`,
`siop_m51_sm7150`), and is marked *(inferred)*.

| Codename | Model (`TARGET_NAME`) | Firmware (`TARGET_FIRMWARE`) | Platform (`TARGET_PLATFORM`) | SDK | Base | Mehedi 16 | Arnav 17 |
|---|---|---|---|---|---|---|---|
| `a52q` | Galaxy A52 | `SM-A525F/EUX/352938771234569` | `sm7125` | 34 | ✓ | ✓ | ✓ |
| `a52sxq` | Galaxy A52s 5G | `SM-A528B/BTU/352599501234566` | `sm7325` | 34 | ✓ | ✓ | ✓ |
| `a53x` | Galaxy A53 5G | `SM-A536B/EUX/350498051234567` | — *(s5e8825 / Exynos 1280, inferred)* | 36 | ✓ | ✓ | ✓ |
| `a71` | Galaxy A71 | `SM-A715F/ROM/352641111234568` | — *(sm7150, inferred)* | 33 | ✓ | ✓ | ✓ |
| `a72q` | Galaxy A72 | `SM-A725F/BTU/353546291234560` | `sm7125` | 34 | ✓ | ✓ | ✓ |
| `a73xq` | Galaxy A73 5G | `SM-A736B/XME/352828291234563` | `sm7325` | 36 | ✓ | ✓ | ✓ |
| `b0q` | Galaxy S22 Ultra (Snapdragon) | `SM-S908E/TUR/350272251234564` | `sm8450` | 36 | ✓ | ✓ | ✓ |
| `g0q` | Galaxy S22+ (Snapdragon) | `SM-S906E/TUR/350037921234561` | `sm8450` | 36 | ✓ | ✓ | ✓ |
| `m51` | Galaxy M51 | `SM-M515F/BVO/357563172596302` | — *(sm7150 / Snapdragon 730G, inferred — see §4)* | 31 / 33* | — | ✓ | ✓ |
| `m52xq` | Galaxy M52 5G | `SM-M526BR/BTU/355568761234563` | `sm7325` | 33 | ✓ | ✓ | ✓ |
| `o1s` | Galaxy S21 5G (Exynos) | `SM-G991B/AUT/350261971234566` | `exynos2100` | 35 | ✓ | ✓ | ✓ |
| `p3s` | Galaxy S21 Ultra 5G (Exynos) | `SM-G998B/AUT/350635581234563` | `exynos2100` | 35 | ✓ | ✓ | ✓ |
| `r0q` | Galaxy S22 (Snapdragon) | `SM-S901E/TUR/350999641234561` | `sm8450` | 36 | ✓ | ✓ | ✓ |
| `r8q` | Galaxy S20 FE (Snapdragon) | `SM-G780G/BTU/357107761234568` | — *(sm8250, inferred — DVFS `sdm8250`, SSRM `sm8250`)* | 33 | ✓ | ✓ | ✓ |
| `r9s` | Galaxy S21 FE 5G (Exynos) | `SM-G990E/THL/355798871234563` | `exynos2100` | 36 | ✓ | ✓ | ✓ |
| `t2s` | Galaxy S21+ 5G (Exynos) | `SM-G996B/AUT/355399273736683` | `exynos2100` | 35 | ✓ | ✓ | ✓ |

\* m51 SDK: 31 on mehedi `sixteen`, 33 on arnav `seventeen`.

Two corrections to the loose "SM7150" label:

1. The only codename the forks add over base is **`m51`**. Everything else
   in `target/` is identical by name in all three repos.
2. "SM7150" does not describe all the forks' targets. The forks contain
   `sm7125` (a52q, a72q), `sm7325` (a52sxq, a73xq, m52xq), `sm8450`
   (b0q, g0q, r0q), `exynos2100` (o1s, p3s, r9s, t2s), `s5e8825`
   (a53x), `sm8250` (r8q) — and `sm7150` only for `a71` (already in base)
   and the new `m51`. The fork name refers to the added sm7150 family,
   not to a single-SoC tree.

`platform/` in all three repos contains only
`exynos2100`, `sm7125`, `sm7325`, `sm8450`. There is **no `platform/sm7150/`**
(and no `sm8250` / `s5e8825`) in any of them. That matters for §3:
sm7150 devices are built from `unica/` + `target/<codename>/` only.

## 2. What lives in `target/<codename>/`

Observed by listing each folder through the Contents API and, for
`m51` / `a71` / `m52xq`, by listing the full recursive tree.

Typical layout (not every target has every entry — `a52q` in base, for
example, has no `debloat.sh` and no `patches/` directory at all):

```
target/<codename>/
  config.sh                  # required — see below
  debloat.sh                 # optional per-target debloat lists
  sff.sh                     # SEC Floating Feature flags
  camera/camera-feature.xml
  dvfs/siop_model.xml
  installer/
    assertions.edify         # bootloader / firmware assertions, e.g. m51: M515FXXS6DXE3
    customize.sh             # m51 only (in the samples checked) — see §4
    install-end.edify        # m51 only (in the samples checked)
    recovery.fstab
  overlay/
    values/{arrays,bools,dimens,integers,strings}.xml
    xml/power_profile.xml
  patches/<name>/           # one Magisk-style module per feature
    module.prop              # id / name / author / description
    customize.sh             # applied at build/flash time
    system.prop / vendor.prop (some modules)
    vendor/... / smali/... / *.diff / firmware blobs (some modules)
  vintf/compatibility_matrix.device.xml   # some targets; m51 uses patches/_vintf instead
```

- **`config.sh`** — the device definition. `buildenv.sh` runs
  `scripts/internal/gen_config_file.sh <codename>` and then sources the
  generated `out/config.sh`. Fields seen in the files (all are plain
  `VAR=value` shell assignments): `TARGET_NAME`, `TARGET_CODENAME`,
  `TARGET_ASSERT_MODEL` (array, e.g. m51 `("SM-M515F")`, r9s
  `("SM-G990E")`), `TARGET_FIRMWARE` (`MODEL/CSC/<digits>`),
  `TARGET_EXTRA_FIRMWARES` (array, usually empty; m51 has one entry —
  see §4), `TARGET_PLATFORM` (when set), `TARGET_PLATFORM_SDK_VERSION`,
  `TARGET_PRODUCT_SHIPPING_API_LEVEL`, `TARGET_BOARD_API_LEVEL`,
  partition sizes (`TARGET_BOOT_PARTITION_SIZE`,
  `TARGET_DTBO_PARTITION_SIZE`, `TARGET_CACHE_PARTITION_SIZE`,
  `TARGET_SUPER_PARTITION_SIZE`,
  `TARGET_QTI_DYNAMIC_PARTITIONS_SIZE` or `TARGET_GROUP_BASIC_SIZE`,
  `TARGET_USE_DYNAMIC_PARTITIONS`, `TARGET_SUPER_GROUP_NAME`),
  OS (`TARGET_OS_SINGLE_SYSTEM_IMAGE` — `qssi` or `essi`,
  `TARGET_OS_BUILD_SYSTEM_EXT_PARTITION`, `TARGET_OS_FILE_SYSTEM_TYPE`
  — m51 mehedi only: `erofs`, `TARGET_DISABLE_AVB_SIGNING`),
  and a long `TARGET_*` SEC product-feature block: audio, Bluetooth,
  camera, common/MDNIE, DVFS (`TARGET_DVFSAPP_CONFIG_DVFS_POLICY_FILENAME`,
  `TARGET_DVFSAPP_CONFIG_SSRM_POLICY_FILENAME`), fingerprint
  (`TARGET_FINGERPRINT_CONFIG_SENSOR`), LCD/HFR, RIL
  (`TARGET_RIL_FEATURES`, SIM tray count), security ESE
  (`TARGET_SECURITY_CONFIG_ESE_CHIP_VENDOR` / `..._COS_NAME`), WLAN.
- **`debloat.sh`** — `<PARTITION>_DEBLOAT+="..."` lists, one path per
  line, no leading `/`, no partition name in the entry (the file's own
  header says so). Partitions used: `SYSTEM_`, `SYSTEM_EXT_`,
  `PRODUCT_`, `VENDOR_`.
- **`sff.sh`** — `SEC_FLOATING_FEATURE_*` flags (extra brightness,
  high-performance mode, HDR effect, Now Brief / App Lock on arnav m51).
- **`installer/`** — recovery installer pieces. `assertions.edify`
  is the gate: m51 requires bootloader `M515FXXS6DXE3` and rejects
  `ro.boot.rp` `6`.
- **`overlay/`** — resource overlays (`values/*.xml`,
  `xml/power_profile.xml`).
- **`patches/<name>/`** — each patch is a self-contained module:
  `module.prop` (`id`, `name`, `author`, `description`) plus
  `customize.sh` and, depending on the patch, `system.prop`,
  `vendor.prop`, vendored binaries/firmware, `.diff` files or smali
  patches. `scripts/internal/apply_modules.sh` applies them.
- **`camera/` / `dvfs/`** — device camera feature XML and the SIOP
  DVFS model XML (`dvfs/siop_model.xml`).

## 3. How a target is selected and built (from the repo, not a guide)

- `buildenv.sh` discovers targets automatically:
  `find "$SRC_DIR/target" -mindepth 1 -maxdepth 1 -type d` → `TARGETS`.
  Adding a directory under `target/` is what registers a device; there
  is no separate registry file to edit.
- Usage (from `buildenv.sh`): `source buildenv.sh [--debug] <target>`.
  With no argument it prints the discovered list and prompts with
  `select`. It refuses a codename with no `target/<codename>/` directory.
- It then sets `APKTOOL_DIR`, `WORK_DIR`, `TMP_DIR` under
  `out/target/<codename>/`, runs `scripts/internal/gen_config_file.sh`,
  and sources the generated config.
- `buildenv.sh` defines `unica` as an alias for `run_cmd`, which runs
  `scripts/<cmd>.sh`. `scripts/make_rom.sh` is the ROM build entry point
  (`--force`/`-f`, `--no-target-files`/`-x`, `--build-rom-zip`/`-z`).
  `make_rom.sh` includes `platform/$TARGET_PLATFORM` only
  `if [ "${TARGET_PLATFORM//none/}" ] && [ -d "$SRC_DIR/platform/$TARGET_PLATFORM" ]`
  — for sm7150 (no `TARGET_PLATFORM` set, no `platform/sm7150/`
  directory) it builds from `unica/` + `target/<codename>/` only.
- The other scripts in `scripts/` are the pipeline stages:
  `download_fw.sh`, `extract_fw.sh`, `build_fs_image.sh`,
  `build_flashable_zip.sh`, `apktool.sh`, `cleanup.sh`,
  `generate_ota_manifest.sh`, plus `scripts/internal/`:
  `gen_config_file.sh`, `create_work_dir.sh`, `apply_modules.sh`,
  `create_target_files_zip.sh`, `update_prebuilt_blobs.sh`.
  The forks add `build_incremental.sh` and `release_rom.sh`
  (both forks) and arnav adds `upload_gofile.py`.
- `unica/` holds the shared side: `unica/configs/` (`version.sh`,
  `qssi.sh`, `essi.sh`), `unica/debloat.sh`, `unica/mods/`,
  `unica/patches/`.

## 4. What the SM7150 forks change to add `m51`

### 4.1 The addition itself

Base `sixteen` has no `target/m51/`. Both forks add the whole directory:

| | mehedi `sixteen` | arnav `seventeen` |
|---|---|---|
| `target/m51/` paths (recursive tree) | 106 | 105 |
| `config.sh` size | 3,132 bytes | 3,275 bytes |
| `debloat.sh` size | 1,324 bytes | 1,692 bytes |
| `sff.sh` size | 503 bytes | 670 bytes |

Everything else in `target/` is the same set of 15 codenames as base.
The m51 folder is modelled on `a71` — the other sm7150 device already in
base (same DVFS policy `dvfs_policy_sm7150_xx`, same 8,053,063,680-byte
super partition, same `qti_dynamic_partitions` group, same
`TARGET_OS_SINGLE_SYSTEM_IMAGE="qssi"`), with M51-specific values
substituted (see below). `a71` has 66 paths in base; `m51` has ~105
because it carries many more `patches/` modules.

### 4.2 `target/m51/config.sh` — shared facts (both forks)

- `TARGET_NAME="Galaxy M51"`, `TARGET_CODENAME="m51"`,
  `TARGET_ASSERT_MODEL=("SM-M515F")`
- `TARGET_FIRMWARE="SM-M515F/BVO/357563172596302"`
- `TARGET_EXTRA_FIRMWARES=("SM-G990B/EUX/353718681234563")` — a second
  firmware (Galaxy S21 FE 5G, SM-G990B) is declared as an extra source.
  This file does not say which blobs come from it; do not assume.
- `TARGET_PRODUCT_SHIPPING_API_LEVEL=29`,
  `TARGET_BOARD_API_LEVEL=30`
- Partitions: boot 67,108,864; DTBO 10,485,760; cache 419,430,400;
  super 8,053,063,680; QTI dynamic 8,048,869,376; dynamic partitions on,
  group `qti_dynamic_partitions`; OS `qssi`, no system_ext partition;
  `TARGET_DISABLE_AVB_SIGNING=true`
- DVFS: `dvfs_policy_sm7150_xx`, SSRM `siop_m51_sm7150`
- Fingerprint: `google_touch_side,settings=3,navi=1` (side-mounted)
- LCD: MDNIE mode `62481`, auto-brightness `3`, HFR default 60,
  HFR mode `0`, `TARGET_LCD_SUPPORT_MDNIE_HW=true`
- Audio: record-alive lib `07010`, no dual speaker, no virtual vibration
- Camera: CameraX extension false, cutout protection false,
  mass-app flavour true, SDK service false
- WLAN: all the `TARGET_WLAN_*` flags are `false`/`0` except
  `TARGET_WLAN_SUPPORT_WIFI_CONCURRENCY=true` and
  `TARGET_WLAN_SUPPORT_SWITCH_FOR_INDIVIDUAL_APPS=true`
- No `TARGET_PLATFORM` line in either fork's `config.sh` — the sm7150
  identity is carried by the DVFS/SSRM filenames and by the
  `debloat.sh` / `sff.sh` headers ("Qualcomm Snapdragon 730G devices
  (sm7150)" / "Galaxy M51 (m51)"), not by a platform variable.
  This matches `a71`, which also omits `TARGET_PLATFORM`.

### 4.3 `target/m51/config.sh` — mehedi `sixteen` vs arnav `seventeen`

| Field | mehedi `sixteen` | arnav `seventeen` |
|---|---|---|
| `TARGET_PLATFORM_SDK_VERSION` | 31 | 33 |
| `TARGET_OS_FILE_SYSTEM_TYPE` | `erofs` | — (not set) |
| `TARGET_COMMON_SUPPORT_HDR_EFFECT` | `true` | `false` |
| `TARGET_RIL_FEATURES` | `""` (comment: none) | `"onebinary embms_qc"` |
| `TARGET_BLUETOOTH_SUPPORT_A2DPSINK_PROFILE` | `false` | `true` |
| ESE (`TARGET_SECURITY_CONFIG_ESE_*`) | — (not set) | `NXP` / `JCOP4.0`, `TARGET_SECURITY_SUPPORT_ESEK=false` |
| Copyright header | `Salvo Giangreco` 2025 | `Salvo Giangreco` + `Arnav` 2026 |

### 4.4 `target/m51/debloat.sh` and `sff.sh` — fork differences

Mehedi `sixteen` debloats (among others): `WifiRROverlayAppLls`,
`mafpc_write`, HDCP provisioning, `EarphoneTypeC`,
`IntelligentDynamicFpsService`, `SamsungPositioning`, `OMCAgent5`,
`GameDriver-SM8450`, Qualcomm location files, `etc/cgroups.json`.

Arnav `seventeen` debloats the above subset plus:
`WifiRROverlayAppH2E`, `HotwordEnrollmentOKGoogleEx4HEXAGON` /
`HotwordEnrollmentXGoogleEx4HEXAGON` (in `PRODUCT_DEBLOAT`), and
**Bixby Wakeup** (`system/app/BixbyWakeup` + its permissions/sysconfig
files) with the in-file comment "no hardware DSP support on M51,
causes crash loop & battery drain". It does **not** debloat
`IntelligentDynamicFpsService`, `SamsungPositioning` or `OMCAgent5`.

`sff.sh` — mehedi: High Performance Mode, Enhanced CPU Responsiveness,
HDR effect, Extra Brightness. Arnav: Extra Brightness, plus Now Brief /
Personal Data Engine (`AI_VERSION=20263`, `LLM_VERSION=1.70`,
`NOW_BRIEF`, `PERSONALIZED_DATA_CORE`, `AI_BRIEF_FOR_UT`) and App Lock.

### 4.5 `target/m51/patches/` — mehedi vs arnav

Patch groups present (from the recursive tree):

- Mehedi (20 groups): `_vintf`, `audio`, `biometrics`, `camera`,
  `dvfs`, `edge_lighting`, `fcm`, `fmradio`, `hotword`, `hwui`,
  `kernel`, `keymaster`, `netflix`, `ril`, `screenlock`, `selinux`,
  `sidefp`, `tweaks`, `vibrator`, `wfd`.
- Arnav (18 groups): `_vintf`, `audio`, `blobs`, `camera`, `display`,
  `dvfs`, `edge_lighting`, `emulated_storage`, `fbe`, `fcm`, `kernel`,
  `keymaster`, `miscs`, `ril`, `selinux`, `stock_props`, `tweaks`,
  `vibrator`.
- Arnav's `tweaks/` additionally ships Python patch scripts
  (`patch_camera.py`, `patch_composer.py`, `patch_iccc.py`,
  `patch_keystoreutils.py`, `patch_libmeminfo.py`); mehedi's `tweaks/`
  has only `customize.sh` + `module.prop`.
- Arnav has **no `sidefp` patch** in its tree; mehedi's `sidefp/`
  contains a smali patch
  (`smali/system/framework/services.jar/0001-Hardcode-fingerprint-sensor-position-value.patch`,
  module `sidefp`, "Sets correct fingerprint sensor position value").
  Do not assume arnav handles the side fingerprint the same way — this
  is an observed difference, not a verified equivalence.
- Both forks' `ril/` patch vendors the same 8 libraries under
  `vendor/lib64/` (`libSemDataProps.so`, `libSemTelephonyProps.so`,
  `libqmiservices-ext.so`, `libqmiservices.so`, `libril_sem.so`,
  `libsec-ril.so`, `libsecril-client.so`,
  `libsemnativecarrierfeature.so`), plus `vendor/bin/hw/rild`,
  `vendor/etc/init/init.vendor.rilchip.rc` /
  `init.vendor.rilcommon.rc`, `file_context-vendor` and
  `fs_config-vendor`. These are the RIL blobs a new sm7150 device must
  supply from its own stock firmware — they are device-specific, not
  shared with a71 (a71's `ril/` vendors only 3 of these libraries).
- Mehedi's `camera/` patch also ships `ueventd.rc.diff`; both forks'
  `camera/` patches exist.

### 4.6 `target/m51/installer/` and the kernel — the two external downloads

- `installer/assertions.edify` (both forks, same in mehedi):
  requires bootloader `M515FXXS6DXE3`, rejects `ro.boot.rp` `6`.
- `installer/customize.sh` (both forks) clones
  `https://github.com/mehedihjoy0/M51-FIRMWARES` at build/install time
  and moves its contents into the temp dir. Mehedi clones straight into
  `$TMP_DIR`; arnav caches it under
  `out/cache/M51-FIRMWARES` (re-clones only if `vbmeta.img` is missing),
  deletes any packaged `recovery.img` ("Never package or overwrite
  user's custom recovery"), and patches `vbmeta.img` byte 123 to `0x03`
  (AVB disabled) to prevent dm-verity / custom-kernel bootloops.
  The firmware files themselves are **not in the UN1CA repo** — they
  come from that separate repo at build time.
- `patches/kernel/customize.sh` (mehedi, read in full): downloads a
  "LostPrime" kernel for m51 from
  `kurtnettle/android_kernel_samsung_sm7150` GitHub releases, picking
  the latest asset matching `m51-ksu*.zip`, then unpacks the stock
  `boot.img` and replaces its kernel/DTB. The kernel is therefore also
  **not in the UN1CA repo** — it is a build-time download from a third
  repo. The arnav kernel patch was not read in full in this research;
  do not assume it is identical.

### 4.7 What "support SM7150 devices" actually means in these forks

- `a71` was already supported in base; the forks did not add it.
- The forks add exactly one new device, `m51`, by copying the `a71`
  pattern and substituting M51 firmware, partitions, fingerprint
  (side vs a71's in-display optical), LCD, RIL and CSC values, plus
  M51-specific patches (sidefp, fmradio, Bixby/hotword handling).
- The other SM7150-family devices people associate with these forks
  (`A52`, `A72`, `M52`) are **not** sm7150 at all in this tree:
  A52/A72 are `sm7125`, M52 is `sm7325`. They were already in base.
  A new sm7150 device (e.g. another Snapdragon 730/730G phone) would
  follow the `m51` template, not the `a52q` template.

## 5. Gaps / things not verified in this research

- No build was run (GitHub-only, read-only task). Nothing here proves
  a given `config.sh` builds or boots.
- `TARGET_EXTRA_FIRMWARES` (m51's SM-G990B entry): the file declares
  it, but this research did not trace which blobs, if any, are taken
  from that firmware. The `devices/m51.json` in this project records
  it as declared, with that caveat.
- Arnav's `patches/kernel/customize.sh` was not read in full.
- The `.github/workflows/` of the three upstream repos were not
  compared here — that is the workflow-builder agent's area, not this
  file's.
- `TARGET_FIRMWARE` trailing digits (e.g. `.../357563172596302`) are
  reproduced verbatim as in the repos. Do not edit them by hand;
  they come from the stock firmware the target was built against.

## 6. Which device fields most often cause build failures — and their fixes

Standing rule for this project (user, 2026-11-23): **if it fails,
continue to modify and fix errors and repeat the modify-and-fix loop
until all errors are fixed and the ROM builds. Do not stop at the
first failure.** For device work that means: if a device JSON /
target file is wrong and a validate/build run fails on it, fix the
file from the real upstream `target/` files and re-validate.

No build was run in this research, so the table below is not a list
of failures that were observed happening — it is the list of fields
to check first when a validate/build run fails, grounded in what the
repos actually enforce (the `buildenv.sh` directory check, the
`assertions.edify` gate, the `download_fw.sh` firmware lookup, the
per-device `patches/ril/` blobs, and the build-time kernel/firmware
downloads). Each fix is: re-read the upstream file named, copy the
value verbatim, re-validate.

| Field | How it fails (repo evidence) | Fix |
|---|---|---|
| `codename` | `buildenv.sh` refuses it: `"X" is not a valid device`. Targets are discovered by `find target -mindepth 1 -maxdepth 1 -type d`, so the name must match a `target/<codename>/` directory exactly. | Rename to the exact upstream directory name. Check the GitHub `target/` listing. |
| `base_firmware` / `TARGET_FIRMWARE` | Wrong firmware downloaded, or the build targets the wrong model. The trailing digits are part of the identifier. | Copy `TARGET_FIRMWARE` verbatim from `target/<codename>/config.sh`. Never edit the trailing digits by hand. |
| `csc` | Wrong regional firmware / wrong variant; installer assertions fail. CSC is the second field of `TARGET_FIRMWARE`. | Copy the CSC from the firmware string (m51: `BVO`; extra firmware: `EUX`). Do not guess it. |
| RIL blobs | No signal / RIL crash. m51's `patches/ril/vendor/lib64/` has 8 libraries; a71's has only 3. They are device-specific. | Take the list from the device's own `patches/ril/vendor/lib64/`. Do not reuse another device's RIL blobs. |
| Kernel | Build cannot find the kernel, or the phone bootloops. No kernel is in the UN1CA repo (m51 mehedi downloads `m51-ksu*.zip` from `kurtnettle/android_kernel_samsung_sm7150` at build time). | Use the device's `patches/kernel/customize.sh` source. If that release is gone, find the replacement and update the JSON. |
| Firmware files | Missing `vbmeta.img` / firmware at install time. m51 downloads them from `mehedihjoy0/M51-FIRMWARES` in `installer/customize.sh`. | Check that repo still exists and the cache path matches the branch (arnav: `out/cache/M51-FIRMWARES`). |
| Partition sizes | Image too large for super, or flashing fails. | Copy the sizes verbatim from `config.sh` (m51: super 8053063680, QTI dynamic 8048869376, boot 67108864, DTBO 10485760). |
| `bootloader_required` | Installer aborts in recovery. m51's `assertions.edify` requires `M515FXXS6DXE3` and rejects `ro.boot.rp == "6"`. | The test device must be on that firmware first; do not edit the assertion to match the device. |
| DVFS / SSRM filenames | DVFS policy not found, or wrong thermal behaviour. On sm7150 the SoC is carried by these names — there is no `TARGET_PLATFORM` line to fix instead. | Copy `TARGET_DVFSAPP_CONFIG_DVFS_POLICY_FILENAME` / `..._SSRM_POLICY_FILENAME` verbatim (m51: `dvfs_policy_sm7150_xx` / `siop_m51_sm7150`). |
| Fingerprint sensor | Enrolment fails / wrong sensor position. m51: `google_touch_side,settings=3,navi=1`; mehedi's `sidefp` smali patch hardcodes the position, arnav has no `sidefp` patch. | Copy `TARGET_FINGERPRINT_CONFIG_SENSOR` verbatim and verify fingerprint separately per branch. |
| Branch mix-up (`sixteen` vs `seventeen`) | A `sixteen` patch list / SDK value on a `seventeen` build. m51 SDK 31 vs 33; patch lists 20 vs 18 groups. | Keep `branch` + `unica_version` in the device JSON and use only that branch's `target/` files for that build. |

The loop, in practice: run validate/build → keep the full log → fix
the one error the log names, from the upstream file above → re-validate
→ repeat until the build succeeds. Mark a device `tested: true` in its
JSON only after a real build run.

## Sources

- `https://github.com/salvogiangri/UN1CA` — branch `sixteen`,
  `target/`, `target/<codename>/config.sh` (all 15),
  `target/a71/`, `target/m52xq/` trees, `buildenv.sh`,
  `scripts/make_rom.sh`, `unica/configs/version.sh`, `platform/`.
- `https://github.com/mehedihjoy0/UN1CA-SM7150` — branch `sixteen`,
  `target/m51/` (config, debloat, sff, installer, patches tree),
  `unica/configs/version.sh`, `platform/`.
- `https://github.com/Arnav3078/UN1CA-SM7150` — branch `seventeen`,
  `target/m51/` (config, debloat, sff, installer, patches tree),
  `unica/configs/version.sh`, `platform/`.
- All reads via the GitHub Contents API and `raw.githubusercontent.com`,
  2026-11-23. File sizes / counts are as returned by those APIs on
  that date.
