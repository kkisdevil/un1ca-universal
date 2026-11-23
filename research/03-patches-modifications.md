# Copyright (c) 2026 Kartik Deepak Sormare (kkisdevil) — UN1CA Universal
# SPDX-License-Identifier: GPL-3.0-or-later

# 03 — How UN1CA is modified and patched

> Status: research + ready-to-use files. Checked against the public
> upstream trees on 2026-11-23 (GitHub Contents API + raw file fetches).
> No ROM has been built or tested in this research — see §9.
>
> Upstream trees referenced:
> - `salvogiangri/UN1CA`, branch `sixteen` — UN1CA 3.2.1 (the base)
> - `mehedihjoy0/UN1CA-SM7150`, branch `sixteen` — SM7150 fork, UN1CA 3.2.1
> - `Arnav3078/UN1CA-SM7150`, branch `seventeen` — SM7150 fork, UN1CA 5.4.0
> - `alrigroup/un1ca-carbon`, tag `carbon-ix-v1.2.1` — Carbon, which
>   vendors UN1CA as `core_unica/` and re-implements the pipeline
>
> Companion files in this repo:
> - `patches/README.md` — where patches live, their format, one real
>   upstream example patch (credited), and the patch-failure table
> - `.github/workflows/test.yml` — the workflow tester (validates
>   patches, workflows, devices, and runs a dry-run build check)
> - `scripts/dry-run-build.sh` — the dry-run script test.yml calls
> - `scripts/validate-patches.py`, `scripts/validate-workflows.py` —
>   the validators test.yml calls
> - `research/02-targets-sm7150.md` — the target/fork map (which
>   codenames exist, `sixteen` vs `seventeen`)

## 1. The tree, directory by directory

Base tree (`salvogiangri/UN1CA@sixteen`): 3,244 entries, 163 `.patch`
files, 24 mods in `unica/mods/`. Top level:

| Directory / file | What it is |
|---|---|
| `buildenv.sh` (169 lines) | The entry point. `source buildenv.sh <target>` discovers targets from `target/` dir names, runs `scripts/internal/gen_config_file.sh <target>` to merge configs into `out/config.sh`, and exports `SRC_DIR`, `OUT_DIR` (`$SRC_DIR/out`), `ODIN_DIR`, `FW_DIR`, `TOOLS_DIR`, `APKTOOL_DIR`, `WORK_DIR`, `TMP_DIR`. Also defines the `unica` alias (`run_cmd`) that runs `scripts/<cmd>.sh`. |
| `unica/` | The ROM itself: configs, patches, mods, debloat lists. This is where almost all modification happens. |
| `platform/` | Per-SoC-family config + patches. Platforms in base: `exynos2100`, `sm7125`, `sm7325`, `sm8450`. Each has `config.sh` and sometimes `debloat.sh` / `patches/`. |
| `target/` | Per-device config. Base has 15 targets: `a52q`, `a52sxq`, `a53x`, `a71`, `a72q`, `a73xq`, `b0q`, `g0q`, `m52xq`, `o1s`, `p3s`, `r0q`, `r8q`, `r9s`, `t2s`. Each has `config.sh` and usually `debloat.sh`, `sff.sh`, `patches/`, `installer/`, `overlay/`. The SM7150 forks add `target/m51/` (see `research/02-targets-sm7150.md`). |
| `scripts/` | The build pipeline: `make_rom.sh` (192 lines), `download_fw.sh` (178), `extract_fw.sh` (421), `apktool.sh` (230), `build_flashable_zip.sh`, `build_incremental.sh` (forks), `release_rom.sh` (forks), `internal/` (`apply_modules.sh`, `gen_config_file.sh`, …), `utils/` (`module_utils.sh` 257 lines, `smali_utils.sh` 399 lines, `common_utils.sh`, `log_utils.sh`). |
| `prebuilts/` | Prebuilt blobs shipped in the ROM: `prebuilts/samsung/<device>/` vendor blobs, `prebuilts/samsung/*/system/saiv/` + `vendor/etc/saiv/` image-understanding models, and similar. These are Samsung/vendor binaries — they are *used* by the build, never copied into this repo. |
| `external/` | Build tools, as git submodules (`.gitmodules`): `android-tools`, `apktool` (iBotPeaches/Apktool), `erofs-utils` (sekaiacg/erofs-utils), `img2sdat`, `samloader` (ananjaser1211/samloader — downloads firmware from Samsung's FUS), `signapk`, plus `ext4_utils`, `f2fs_utils`, `make.sh`, and `patches/apktool/0001-feat-support-aapt-optimization.patch`. |
| `security/` | Signing keys. In the public tree only AOSP test keys (`aosp_platform.pk8/.x509.pem`, `aosp_testkey.pk8/.x509.pem`) and the AVB test key (`security/avb/testkey_rsa4096.pem`). Official builds use `unica_platform.*`, decoded in CI from the secrets `PLATFORM_KEY_PK8` / `PLATFORM_KEY_PEM` (upstream `.github/workflows/ci.yml`). `gen_config_file.sh` checks for the UN1CA cert by SHA1 (`PLATFORM_KEY_SHA1 5b0eb951718acc596370dabab83f546e779b21dc`, `OTA_KEY_SHA1 681aa9d28fe5fc60be8c25dc5f26a73ec3d6fb46`). **Never commit a real key or keybox.** |
| `.github/workflows/` | Upstream CI: `ci.yml` (135 lines — shellcheck, generate-matrix from `target/`, per-target build on `ubuntu-24.04`, JDK 17 Temurin, `modprobe erofs f2fs`, `nick-fields/retry` around `download_fw.sh`) and `blobs.yml` (129 lines). |
| `readme-res/` | Images for the upstream README. |

### 1.1 `unica/configs/` — only three files

- `version.sh` — `VERSION_MAJOR=3, VERSION_MINOR=2, VERSION_PATCH=1`
  (ROM 3.2.1). Appends `+` if commits exist since the last tag, the
  short commit hash, and `-dirty` if uncommitted changes are present
  (all `git` calls guarded with `2> /dev/null`, so a shallow clone
  without tags still works).
- `qssi.sh` — the Snapdragon source-firmware config. Source firmware
  is the Galaxy S22 `SM-S901E/TUR/350999641234561`, SDK 36, shipping
  API 31, board API 31, super group `qti_dynamic_partitions`, plus
  dozens of `SOURCE_*` product-feature flags (audio, Bluetooth,
  camera, MDNIE, fingerprint, HFR, RIL, WLAN).
- `essi.sh` — the Exynos equivalent.

### 1.2 `unica/patches/` — ROM-wide compatibility patches

289 entries, grouped by area: `__floating_feature`, `__props`,
`_debloat`, `adb`, `bluetooth`, `camera`, `dvfs`, `ese`, `fmradio`,
`fs`, `legacy`, `miscs`, `nfc`, `proca`, `product_feature` (audio,
fingerprint, hfr, mdnie, resolution, ril, wifi), `rro`, `saiv`,
`selinux`, `signature`, `spen`, `stock_blobs`, `uwb`, `vintf`, `vndk`.

### 1.3 `unica/mods/` — 24 feature mods

| Mod | Patches | What it does |
|---|---|---|
| `deknox` | 27 | Removes Knox: DualDAR, HDM, KnoxGuard, SDP, BlockchainTZService, Knox Matrix AI privacy, etc. (one patch per APK/JAR). |
| `settings` | 10 | Adds the UN1CA Settings section to SecSettings (fragments + preference controllers) and framework/services hooks (SamsungProps, FloatingFeature, HideDeveloperStatus, unlimited Google Photos storage, disable secure windows, app downgrade, old-target-SDK bypass, disable screenshot detection, disable ASKS). |
| `paradigm` | 9 | Brand sound, Adaptive color tone (`ead/`, `ead_mdnie`, `ead_resolution`), semantic search (`semanticsearch/` — SecSettingsIntelligence DQA description + embedding JSONs per locale). |
| `csc` | 6 | CSC-feature hooks + SecSettings/SystemUI patches (network speed, power-off lock, Secure Folder quick switch, Smart View tile). |
| `tweaks` | 5 | App-compaction disable, PM haptics fix, SystemUI marquee/dialog fixes, `vendor.prop`. |
| `knoxpatch` | 3 | KnoxPatch hooks (see §5). |
| `wallpaper` | 3 | Default wallpaper assets (QMG). |
| `hma` | 2 | Hide My Applist hooks (framework + services.jar). |
| `keybox` | 2 | Keybox imitation hooks + MGF digest fix (see §5). |
| `pif` | 2 | Play Integrity hooks (see §5). |
| `blocklist` | 1 | Custom `unica_blocklist.xml` + services.jar patch. |
| `choidujour` | 1 | UN1CA Updates entry in Settings (`ChoiDujourPreferenceController.smali`, priv-app `ChoiDujour.apk`). |
| `daagent` | 1 | Dual Messenger for all apps (597-line patch). |
| `gamesprops` | 1 | GamesProps utils hook. |
| `multiuser` | 1 | Multi-user enablement. |
| `setupwizard` | 1 | Custom disclaimer page + branded SecSetupWizard resources. |
| `bootanim`, `bootsound`, `callsounds`, `monotype`, `outdoor`, `pinconfirm`, `preload`, `prophide` | 0 (assets / props / customize.sh only) | Boot animation/sounds, call sounds, fonts, outdoor mode, PIN confirm, preloaded apps, prop hiding, setup-wizard branding. |

## 2. How a build runs, and when patches apply

`scripts/make_rom.sh` (`unica make_rom [--force|-f]
[--no-target-files|-x] [--build-rom-zip|-z]`):

1. `source buildenv.sh <target>` → `gen_config_file.sh` merges
   `unica/configs/version.sh` + `target/<codename>/config.sh` +
   `platform/<platform>/config.sh` (re-sourced, then the target config
   re-sourced so the target wins) + `unica/configs/<qssi|essi>.sh`
   into `out/config.sh`. Fails if `TARGET_OS_SINGLE_SYSTEM_IMAGE` is
   unset or its config file is missing.
2. If forced (`-f`) or the work-dir hash changed (hash of all files
   under `unica/`, `platform/<platform>/`, `target/<codename>/`),
   the build proceeds; otherwise it prints `No changes have been
   detected in the build environment` and stops.
3. Download firmwares if needed (`download_fw.sh`, samloader:
   `samloader -m <MODEL> -r <CSC> -i <IMEI> -s <SERIAL_NO> download`),
   unzip, verify Odin `.md5` packages, write a `.downloaded` marker.
4. Extract (`extract_fw.sh`): unpack BL/AP tars, handle
   `super.img` / `super.img.lz4` via `lpunpack`, mount EROFS images
   with `fuse.erofs`, record partition metadata.
5. Create the work dir (`create_work_dir.sh`), then apply, **in this
   order, each via `scripts/internal/apply_modules.sh <folder>`**:
   platform patches → device patches → ROM patches → ROM mods.
6. Rebuild APKs/JARs (`BUILD_APKS`, max 8 parallel jobs,
   `apktool.sh b`), write `WORK_DIR/.completed` with the new hash.
7. Create the target-files zip and, with `-z`, the flashable zip
   (`build_flashable_zip.sh`).

**Order is the whole game.** A mod can override a ROM patch, and a
device patch can override a platform patch. Two patches touching the
same smali lines must be ordered so the second one's context matches
the first one's output.

## 3. The patch system — three layers, one module format

### 3.1 The module

One module = one folder. `scripts/internal/apply_modules.sh` walks
the folders in `LC_ALL=C` sorted order and runs `APPLY_MODULE` on
each. A module is:

```
<name>/
  module.prop          # REQUIRED — id, name, author, description
  customize.sh         # optional — shell code, run after files are copied
  system/ system_ext/ product/ odm/ vendor/   # optional — file trees
  smali/               # optional — *.patch files, applied with git apply
  *.prop               # optional — <partition>.prop key=value files
  disable              # optional — if present, the module is skipped
```

`module.prop` is four `key=value` lines, no quotes. `id` must be
unique in its layer. `author` is the credit — it is printed in the
build log (`Processing "…" by @…`). `module.prop` is safe from the
`*.prop` reader because its basename (`module`) is not a partition
name (see §3.4).

`APPLY_MODULE` (`scripts/internal/apply_modules.sh`, 140 lines):

1. `module.prop` must exist, or the build fails with
   `File not found: …/module.prop`. A `disable` file skips the module
   silently.
2. Unless `customize.sh` contains `SKIPUNZIP=1`, the module's
   `odm/`, `product/`, `system/`, `system_ext/`, `vendor/` trees are
   copied into the work dir with fixed owners/modes/SELinux contexts
   (`ADD_TO_WORK_DIR` — system `0:0 755
   u:object_r:system_file:s0`, vendor `0:2000 755
   u:object_r:vendor_file:s0`).
3. `*.prop` files are applied (`READ_AND_APPLY_PROPS`).
4. `customize.sh` is sourced (`.` — it runs in the build shell, with
   `$MODPATH`, `$WORK_DIR`, `$APKTOOL_DIR` and all helpers).
5. Every `*.patch` under `smali/` is applied in sorted order
   (`APPLY_SMALI_PATCHES` → `APPLY_PATCH`).
6. Decoded APKs/JARs are rebuilt at the end of `make_rom.sh`
   (`BUILD_APKS`), re-signed with the platform key (`signapk`) for
   APKs, zipaligned for JARs, and copied back into the work dir.

`apply_modules.sh` runs with `set -e`, so **a failure in any module
aborts the build**. That is what makes the modify-and-fix loop work:
the log names the failing module and file.

### 3.2 Git smali patches — `smali/<partition>/<path>/<file>.apk|jar/<NNNN>-<name>.patch`

The main mechanism. A file under a module's `smali/` directory is a
unified diff against apktool-decoded smali, produced by
`git format-patch` from a decoded APK tree. Example (real, upstream,
credited — see `patches/README.md` §4 and
`patches/network-speed/` in this repo):

```
smali/system/priv-app/SecSettings/SecSettings.apk/
  0001-Enable-real-time-network-speed-in-status-bar.patch
```

- The directory path under `smali/` is the partition + the path of
  the APK/JAR inside the work dir.
- The number prefix sets the order: patches apply in sorted order
  (`find … -name "*.patch" | sort -n`). Number `0001`, `0002`, …
  and leave gaps if you expect to insert one later.
- The patch header must be a real `git format-patch` header:
  `From <sha>`, `From: <author>`, `Date:`,
  `Subject: [PATCH] …`, then `diff --git a/… b/…` hunks.
- Applied with `git apply --directory=<apktool-dir>/<partition>/<file>
  --verbose --unsafe-paths <patch>` (`APPLY_PATCH` in
  `scripts/utils/module_utils.sh`), after the APK/JAR is decoded with
  apktool (`DECODE_APK`, `scripts/apktool.sh d … --no-debug-info -j
  <threads> -p <framework> -t <incremental>`).
- The `@@` context lines must match the decoded smali **exactly**.
  If the source firmware changes one line of context, the patch fails
  — see §8, failure #1.
- `APPLY_PATCH` fails (`LOGE`, return 1) if the partition is invalid,
  the patch file is missing, or `git apply` fails.

### 3.3 Dynamic smali patches — `SMALI_PATCH` in `customize.sh`

For changes too small or too conditional for a patch file,
`customize.sh` scripts call `SMALI_PATCH` (defined in
`scripts/utils/smali_utils.sh`, 399 lines):

```
SMALI_PATCH <partition> <apk/jar> <smali-file> <operation> [method] [value] [replacement]
```

Operations: `null` (empty a method body), `remove` (delete a smali
file — refused if used elsewhere), `replace <method> <value>
<replacement>`, `replaceall <value> <replacement>`,
`return <method> <value>` (force a method to return a constant),
`strip <method>` (delete a method).

It validates the method regex and prints `Possible matches?` (up to
10) when a smali file or method is not found, then returns 1.

Real examples from upstream:

```bash
# knoxpatch/customize.sh — force a root check to return false
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali/com/android/server/StorageManagerService.smali" "return" \
    'isRootedDevice()Z' 'false'

# pif/customize.sh — inject a hook call into Instrumentation.newApplication
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali/android/app/Instrumentation.smali" "replace" \
    'newApplication(Ljava/lang/Class;Landroid/content/Context;)Landroid/app/Application;' \
    'return-object p0' \
    '    invoke-static {p1}, Lio/mesalabs/unica/PlayIntegrityHooks;->setProps(Landroid/content/Context;)V\n\n    return-object p0' \
    > /dev/null
```

### 3.4 Props, floating features, hex patches

- **`<partition>.prop` at a module's root** (`system.prop`,
  `vendor.prop`, …): `key=value` lines. `READ_AND_APPLY_PROPS`
  writes each with `SET_PROP`; a line with an empty value (`key=`)
  **deletes** that prop. A malformed line (no `=`) fails the build
  (`LOGE "Malformed string in <file>: "<line>""`).
- **`SET_FLOATING_FEATURE_CONFIG <config> <value>`** — adds, replaces
  or deletes (`-d` / `--delete`) an entry in
  `/system/system/etc/floating_feature.xml`, Samsung's feature-flag
  file. This is how most "enable X on this device" switches work:
  the source firmware already contains the code; the flag turns it
  on. `GET_FLOATING_FEATURE_CONFIG` reads a flag so a `customize.sh`
  can branch on what the source firmware supports; the flag values
  themselves live in `unica/patches/__floating_feature/`.
- **`SET_PROP_IF_DIFF <partition> <prop> <value>`** — only writes
  when the current value differs.
- **`HEX_PATCH <file> <from> <to>`** — replaces one equal-length hex
  string with another in a native binary; fails if the `FROM` bytes
  are not found or the lengths differ.
- **`apktool.sh`** — decode with `apktool d --no-debug-info -j
  <threads> -p <framework> -t <incremental>`; build with
  `apktool b -srp` (`--shorten-resource-paths`), copies the original
  `META-INF`, signs APKs with `signapk` (AOSP keys in the public tree,
  `unica` keys for official builds), zipaligns JARs, deletes `oat/`
  and `.prof`/`.bprof` beside rebuilt files.

## 4. A small modification, end to end

The canonical UN1CA pattern for a CSC-gated feature, using the real
upstream patch that ships as the example in `patches/network-speed/`:

**Goal:** enable the real-time network-speed indicator in the status
bar (it is gated behind a CSC flag in stock firmware).

**1. Find the gate.** In the decoded `SecSettings.apk`, the feature is
gated by
`SemCscFeature.getBoolean("CscFeature_Common_SupportZProjectFunctionInGlobal",
false)`. Three smali files call it:
`ConfigureNotificationMoreSettings$1.smali`,
`StatusBarNetworkSpeedController.smali`, `NotificationsItem.smali`.

**2. Write the patch.** Replace the whole call sequence with a
constant in each file:

```diff
-    invoke-static {}, Lcom/samsung/android/feature/SemCscFeature;->getInstance()Lcom/samsung/android/feature/SemCscFeature;
-
-    move-result-object v0
-
-    const-string v1, "CscFeature_Common_SupportZProjectFunctionInGlobal"
-
-    const/4 v2, 0x0
-
-    invoke-virtual {v0, v1, v2}, Lcom/samsung/android/feature/SemCscFeature;->getBoolean(Ljava/lang/String;Z)Z
-
-    move-result v0
+    const/4 v0, 0x1
```

Adjust the `.locals` count down in the same hunk (fewer registers are
used after the call is removed). Produce the patch with
`git format-patch` from the decoded tree so the header (`From:`,
`Date:`, `Subject: [PATCH] …`) is correct.

**3. Put it in a module.** `patches/network-speed/` in this repo is
exactly this, copied verbatim from upstream
(`salvogiangri/UN1CA@sixteen`,
`unica/mods/csc/smali/system/priv-app/SecSettings/SecSettings.apk/
0001-Enable-real-time-network-speed-in-status-bar.patch`,
commit `cf9b438bc847d171dcfd6b54cd2c134052e982b0`, 2025-10-17, Salvo
Giangreco). Its `module.prop` (`id=network-speed`,
`author=salvogiangri`) and a comment-only `customize.sh` are included;
`apply_modules.sh` applies the `smali/` patch automatically, so no
`customize.sh` logic is needed.

**4. Validate.** `python3 scripts/validate-patches.py` checks the
module and the patch format; `.github/workflows/test.yml` runs the
same check on every push/PR. Then `scripts/dry-run-build.sh m51 …`
proves the device config still generates; then `build.yml` (dry-run,
then full) builds the ROM.

**5. Test safely** — see §7. Never flash a first build on a daily
driver; use the incremental path (`scripts/build_incremental.sh` in
the forks) and the device's own test checklist before calling a
feature working.

**The same pattern, for a new feature:** copy
`patches/network-speed/` to `patches/<your-feature>/`, give it a new
`id`/`name` in `module.prop` (keep the upstream credit in
`patches/README.md` and in the patch header if you reuse upstream
hunks), replace the `smali/` tree with your APK/JAR path and your
`NNNN-<name>.patch`, and run the validator. If the change is a
one-liner that depends on the source firmware (e.g. "only if the flag
exists"), use `SMALI_PATCH` / `SET_FLOATING_FEATURE_CONFIG` in
`customize.sh` instead of a patch file — see `unica/mods/settings/
customize.sh` for the battery-regulatory example, which deletes a
floating-feature flag only if it is present.

## 5. How the named features are actually enabled

### 5.1 KnoxPatch — `unica/mods/knoxpatch/`

`module.prop`: `id=knoxpatch`, `name=KnoxPatch`,
`author=salvogiangri`, "Set of patches inspired by the homonym mod".
`customize.sh` (86 lines):

- Deletes WSM (Workspace) files: `system/etc/
  public.libraries-wsm.samsung.txt`, `libhal.wsm.samsung.so`,
  `vendor.samsung.hardware.security.wsm.service-V1-ndk.so`, lib + lib64.
- Applies `framework.jar/0001-Introduce-KnoxPatchHooks.patch` and
  `knoxsdk.jar/0001-Introduce-KnoxPatchHooks.patch`, then injects
  `Lio/mesalabs/unica/KnoxPatchHooks;->init(...)` into both
  `Instrumentation.newApplication` overloads via `SMALI_PATCH …
  replace`.
- Bypasses ICD verification
  (`AttestParameterSpec.isVerifiableIntegrity()Z` → `true`, plus
  `services.jar/0001-Bypass-ICD-verification.patch`), forces
  `DarManagerService.checkDeviceIntegrity(…)Z` and
  `isDeviceRootKeyInstalled()Z` → `true`,
  `StorageManagerService.isRootedDevice()Z` → `false`.
- If `KmxService.apk` exists, downloads the latest Knox Matrix app
  from Galaxy Store and forces `RootOfTrust.getVerifiedBootState()I`
  → `0`, `isDeviceLocked()Z` → `true`,
  `IntegrityStatus.getStatus()I` → `0`, `isNormal()Z` → `true`
  (repeated across several smali classes).

### 5.2 Play Integrity / keybox — `unica/mods/pif/` and `unica/mods/keybox/`

- `pif/` (`id=pif`, "Set of patches inspired by the homonym mod"):
  `customize.sh` + `framework.jar/
  0001-Introduce-PlayIntegrityHooks.patch` + `services.jar/
  0001-Introduce-PlayIntegrityHooks.patch`. It injects
  `PlayIntegrityHooks.setProps(Context)` into both
  `Instrumentation.newApplication` overloads, and — only if the
  keybox hooks are not already present — forces
  `shouldBlockKeyAttestation()Z` → `true`.
- `keybox/`: `framework.jar/
  0001-Introduce-KeyboxImitationHooks.patch` +
  `0002-Disable-MGF-digest-param-omit.patch`.
- Settings UI for both lives in `unica/mods/settings/
  SecSettings.apk/smali_classes4/io/mesalabs/unica/settings/
  {pif,keybox,hma,spoof,ui,extra,pm,wm}/`
  (`PIF*PreferenceController`, `Keybox*PreferenceController`,
  `KeyboxUtils`, …).
- **A valid keybox is still required for strong integrity** — the
  hooks alone do not create one (upstream README: "* Requires a valid
  keybox"). The keybox mod only *imitates* one for testing. Do not
  ship a keybox in the repo; the user must supply their own.

### 5.3 CSC features — `unica/mods/csc/`

`customize.sh` is only 12 lines; the work is in the `smali/` patches:
`framework.jar/0001-Introduce-CscFeatureHooks.patch`, `SecSettings.apk`
patches (real-time network speed, power-off lock, quick switch to
Secure Folder), `SystemUI.apk` patches (network speed, Smart View
tile visibility). The `customize.sh` itself uses `SMALI_PATCH` for
the power-off lock (`SystemPropertiesWrapper.isBrazilianCountryISO()Z`
→ `true`, `DeviceController.isSupportPowerOffLock()Z` → `true`) and
hides the Remote management tile in Settings.

CSC values themselves come from two places: the `TARGET_*` /
`SOURCE_*` flags in the config files (e.g. `TARGET_WLAN_*`,
`TARGET_RIL_*` — the `SOURCE_*` set in `unica/configs/qssi.sh` is
the source firmware's feature list), and `floating_feature.xml` via
`SET_FLOATING_FEATURE_CONFIG` (`unica/patches/__floating_feature/`).

### 5.4 Blur

**Traced, not fully proven — do not claim a single blur switch
exists.** What the tree shows: the live-blur toggle UI is
`unica/mods/settings/…/settings/ui/
LiveBlurPreferenceController.smali`; no dedicated blur patch file was
found under that name. Live blur is a capability of the source
firmware's framework (S22/S23 One UI) plus the settings toggle; the
framework side is stock Samsung code, not a UN1CA patch. If blur does
not work on a ported device, the fault is in the source firmware's
framework or the device's `floating_feature.xml`, not in a missing
UN1CA mod.

### 5.5 Galaxy AI

**There is no single "Galaxy AI" mod.** Galaxy AI in UN1CA is
emergent from three things:

1. **The source firmware itself** — the S22 firmware
   (`SM-S901E/TUR/…`) that UN1CA is built on already contains the
   Galaxy AI apps and framework. UN1CA does not add AI; it keeps
   the source's AI working on the target.
2. **Prebuilt models** — `prebuilts/samsung/*/system/saiv/` +
   `vendor/etc/saiv/` image-understanding models (SAIV = Samsung
   AI Vision) and the `unica/patches/saiv/` compatibility patches.
3. **Feature flags + paradigm** — `unica/mods/paradigm/
   semanticsearch/` (SecSettingsIntelligence DQA description +
   embedding JSONs per locale), `ead/` (Adaptive color tone),
   `ead_mdnie` / `ead_resolution`, and the `floating_feature.xml`
   entries that gate AI features per device.

Consequence for porting: if a target's stock firmware lacks a given
AI feature, UN1CA cannot conjure it — the port must bring the
feature from a source firmware that has it, or leave it out. Do not
promise "Galaxy AI on every phone"; the honest claim is "the AI the
source firmware has, kept working on the target".

### 5.6 Hide My Applist, games props, and the rest

- `hma/` — Hide My Applist hooks in `framework.jar` + `services.jar`
  (same injection pattern as KnoxPatch/PIF, via
  `Instrumentation.newApplication`).
- `gamesprops/` — `0001-Introduce-GamesPropsUtils.patch`.
- `tweaks/` — app-compaction disable, PM haptics fix, SystemUI
  marquee/dialog fixes, `vendor.prop`.
- `settings/` — the UN1CA Settings section; also the place where
  framework hooks (`0002-Introduce-SamsungPropsHooks.patch`,
  `0003-Introduce-FloatingFeatureHooks.patch`,
  `0004-Introduce-HideDeveloperStatusUtils.patch`) and services
  patches (disable secure windows, app downgrade, old-target-SDK
  bypass, disable screenshot detection, disable ASKS) live, plus
  `0001-Allow-unlimited-storage-for-Google-Photos.patch`.
- `deknox/` — 27 patches, one per Knox component; the largest mod.
- `blocklist/` — custom `unica_blocklist.xml` + services.jar patch
  (`0001-Allow-custom-PackageBlockListPolicy.patch`, 230 lines).
- `daagent/` — Dual Messenger for all apps
  (`0001-Allow-all-apps-in-Dual-Messenger.patch`, 597 lines).
- `choidujour/` — the UN1CA Updates entry in Settings.

## 6. How Carbon reuses UN1CA (contrast)

`alrigroup/un1ca-carbon` (tag `carbon-ix-v1.2.1`, 2,597 entries) does
**not** reuse upstream `buildenv.sh` / `scripts/` / `ci.yml` directly.
It vendors the UN1CA tree as `core_unica/` (1,077 entries — its own
`buildenv.sh`, `mods/`, `LICENSE`) and adds its own layers:

- `carbon_ours/` (1,069 entries) — Carbon's own modules
  (bootanimation, branding_settings, …).
- `carbon_engine/` (36 entries) — a C++20 engine (`CMakeLists.txt`,
  `Carbonfile.json`, `PLAN.md`, `specs.md`,
  `include/carbon/` DAG/pipeline/recipe/fingerprint/ledger/key_manager,
  `src/core/pipeline.cpp`, `src/core/recipe_executor.cpp`,
  `src/dag/dependency_graph.cpp`).
- `vendors_rezoss/` (335 entries, incl. `mods_hma/` with Java source
  + tests) and `vendors_npl/` (33 entries, `mods_cosine` wallpapers
  with `ATTRIBUTION.md`) — vendored upstream work.
- `docs/` — FEATURES / INSTALLATION / CHANGELOG / SECURITY_AND_KEYS
  and `dev_guides/01–04` (incl.
  `02_PORTING_UN1CA_SCRIPTS_TO_ENGINE.md`).
- `make_carbon.sh` / `make_carbon_engine.sh` — the Carbon build
  orchestrators (ARGLP licence header, target `dm1q` default,
  `DEBLOAT_TELEMETRY`, `BOOTANIMATION_STYLE=carbon|stock`).

Lesson for un1ca-universal: Carbon's approach — vendor the upstream
tree, keep your own modules in a separate directory, and re-implement
the pipeline around it — is the same shape as this repo's `patches/`
+ `devices/` + workflows, but Carbon's own modules are under the
ARGLP licence, not GPL-3.0. **Do not copy `carbon_ours/` code into a
GPL-3.0 tree without checking its licence first.** The `core_unica/`
part is GPL-3.0 (credited to Salvo Giangri) and is the part that can
be reused on GPL terms.

## 7. How to test a modification safely

1. **Validate before building.** `python3
   scripts/validate-patches.py` (patch format + module.prop) and
   `python3 scripts/validate-workflows.py` (workflow YAML) run
   locally in seconds. `.github/workflows/test.yml` runs the same
   checks on every push/PR, plus device JSON validation and the
   dry-run.
2. **Dry-run the config.** `bash scripts/dry-run-build.sh m51
   Arnav3078/UN1CA-SM7150 seventeen` — sparse-clones the fork,
   sources `buildenv.sh m51`, verifies `out/config.sh`. No firmware
   is downloaded. A green dry-run means the config is coherent and
   the upstream tree is reachable, not that the ROM builds.
3. **Build in CI, dry-run mode first.** `.github/workflows/build.yml`
   has a `mode` input (`dry-run` default / `full`). Dry-run stops
   before firmware download; full mode needs the
   `PLATFORM_KEY_PK8` / `PLATFORM_KEY_PEM` secrets for signing.
   Runner limits are real (6 h job cap, 4 vCPU / 16 GB / ~14 GB
   disk, 10 GB cache cap) — the build workflow's header documents
   them.
4. **Flash on a spare device first, never a daily driver.** Use the
   forks' incremental path (`scripts/build_incremental.sh`) for
   re-tests after a small patch change. Keep a known-good stock
   firmware (Odin) ready to restore.
5. **Verify the exact thing you changed, in the exact app.** A fix
   that works in one app does not transfer to another on assumption
   (the same rule as the YouTube vs YouTube Music lesson elsewhere
   in this project). For a SecSettings patch, open SecSettings and
   check the setting; for a SystemUI patch, check the status bar /
   quick panel; for a framework hook, check the behaviour it gates.
6. **Read the build log artifact, not the summary line.**
   `build.yml` uploads `build-logs-<device>-<run_id>` even on
   failure (`if: always()`). The failing module and file are in that
   log.

## 8. Patch failures — what breaks, and how each is fixed

Standing user rule (2026-11-23): **if it fails, continue to modify
and fix errors and repeat the modify-and-fix loop until all errors
are fixed and the ROM builds. Do not stop at the first failure.**

`test.yml` fails loudly on a bad patch or device file, with the exact
file and error in the log, so the next fix round can target it. The
full table — with the exact log strings, which are quoted from the
upstream scripts so you can grep for them — lives in
`patches/README.md` §5. The short version:

| # | Failure | Symptom | Fix |
|---|---|---|---|
| 1 | **Bad patch context** | `git apply` fails: `error: patch failed: <file>:<line>` / `patch does not apply` | The decoded smali changed (new source firmware). Re-decode the APK from the *new* source firmware and regenerate the patch (`git format-patch`). Never hand-edit `@@` line numbers. Check `.locals` counts. |
| 2 | **Wrong file** | `LOGE "Smali not found: …"` + `Possible matches?`, or `git apply` `No such file or directory` | Wrong `smali_classes<N>` bucket, renamed class, or wrong APK/JAR path. Use the `Possible matches?` list; check the decoded tree with `find`. |
| 3 | **Missing dependency (module order)** | A later patch fails, or `LOGE "Method … not found"` | Patch B assumes patch A's output but runs first. Rename the module folder or patch number so the dependency applies first; document the ordering. |
| 4 | **Missing module.prop** | `LOGE "File not found: …/module.prop"` | Add the four-line `module.prop`. `test.yml` catches this before any build starts. |
| 5 | **Malformed prop line** | `LOGE "Malformed string in <file>: "<line>""` | Fix the line; comments need `#`. `key=` (empty) is valid — it *deletes* the prop. |
| 6 | **Invalid partition** | `LOGE ""<x>" is not a valid partition name"` | First component under `smali/` (or the partition argument) must be one of `system`, `system_ext`, `product`, `vendor`, `odm`. |
| 7 | **Apktool decode failure** | `apktool.sh d` fails, or `LOGE "Output directory already exists … Use --force flag"` | Delete the stale decode dir under `out/target/<codename>/apktool/`, or re-run with `--force`. |
| 8 | **`git apply --check` "fails" locally** | `error: <file>.smali: No such file or directory` | **Not a failure.** `--check` needs decoded target files, which do not exist in this repo. Validate format with `git apply --stat` (what `test.yml` does); only run `--check` inside a real build work dir after `apktool d`. |
| 9 | **Wrong branch / generation** | A `sixteen` patch fails on `seventeen` (or vice versa) | `sixteen` (One UI 8, UN1CA 3.2.1) and `seventeen` (One UI 9, UN1CA 5.4.0) have different smali. Re-decode from the *target branch's* source firmware and regenerate. Do not copy across. |
| 10 | **Keybox / PIF without a keybox** | Play Integrity still fails after the build | The hooks need a valid keybox (upstream README). Supply your own; never commit one. |
| 11 | **Signature mismatch after rebuild** | Rebuilt APKs fail / SystemUI crashes on boot | APKs are re-signed with the platform key; CI needs `PLATFORM_KEY_PK8` / `PLATFORM_KEY_PEM` (base64, as upstream CI does). Never commit a private key. |
| 12 | **Build cache hides a change** | `No changes have been detected in the build environment` | Run `unica make_rom --force`, or delete `out/target/<codename>/work_dir/.completed`. |

**The loop, concretely:**

1. `test.yml` (or `build.yml` in dry-run, then full) fails and names
   the exact file and error — read the log artifact, not the summary.
2. Fix *that* failure only, in the file it names.
3. Commit, push, let the workflow re-run. It will fail on the *next*
   error, if any. Repeat.
4. Do not stop at the first failure, do not "fix" a failure by
   deleting the patch or the test, and do not merge while red.
5. When `test.yml` is green, run `build.yml` dry-run, then full.

## 9. What was actually verified in this research (and what was not)

Verified on 2026-11-23, GitHub-only, read-only:

- Tree shapes and counts for all four repos (GitHub Contents API,
  recursive trees): base 3,244 entries / 163 `.patch` files / 24
  mods; Mehedi fork 3,386 entries (150 paths only in the fork, 8 only
  in base); Arnav fork 3,502 entries (303 only in the fork, 45 only
  in base); Carbon 2,597 entries.
- The build flow and patch-apply code, read in full:
  `buildenv.sh`, `scripts/make_rom.sh`, `scripts/internal/
  apply_modules.sh`, `scripts/utils/module_utils.sh`,
  `scripts/utils/smali_utils.sh`, `scripts/apktool.sh`,
  `scripts/download_fw.sh`, `scripts/extract_fw.sh`,
  `scripts/internal/gen_config_file.sh`, `unica/configs/
  {version,qssi,essi}.sh`, upstream `.github/workflows/{ci,blobs}.yml`.
- Four real example patches, fetched verbatim:
  `unica/mods/csc/…/0001-Enable-real-time-network-speed-in-status-bar.patch`
  (121 lines), `unica/mods/blocklist/…/0001-Allow-custom-
  PackageBlockListPolicy.patch` (230 lines),
  `unica/mods/daagent/…/0001-Allow-all-apps-in-Dual-Messenger.patch`
  (597 lines), `unica/mods/csc/…/0001-Introduce-CscFeatureHooks.patch`
  (682 lines).
- The `network-speed` example patch in this repo is a byte-for-byte
  copy of the upstream file (SHA-256
  `5c08ed3a049c9952b6895c8e74d46f7190a1584f0c5c1ec7f4d796889756c34a`)
  and parses cleanly (`git apply --stat`: 3 files, 8 insertions,
  46 deletions).
- Local validation of this repo's new files (2026-11-23):
  `scripts/validate-patches.py` green (1 module, 1 patch, 0 errors),
  `scripts/validate-workflows.py` green (3 workflow files, 0 errors)
  after one fix round (it initially flagged `scripts/*.sh`
  references in `build.yml` — those are upstream scripts run with
  `working-directory: upstream`, not repo scripts; the validator now
  respects `working-directory`), `bash -n` clean on
  `scripts/dry-run-build.sh`, `scripts/validate-device.sh
  devices/m51.json` green offline.
- Negative tests prove the validators fail loudly (2026-11-23, on a
  scratch copy in `/tmp`, since removed): deleting `module.prop`
  and CRLF-ifying the example patch produced two `::error`
  annotations naming the exact files and the exact problems
  (exit 1); removing `jobs:` from `test.yml` produced one `::error`
  naming `.github/workflows/test.yml` (exit 1). The negative test
  also caught a real bug in `validate-patches.py` — a missing
  `module.prop` used to skip the rest of that module's checks and
  hide the patch errors; fixed so every error is reported in one
  run, then re-tested green (positive) and correctly failing
  (negative).
- **Dry-run — NOT executed locally (blocked, see below).**
  `scripts/dry-run-build.sh` is written, syntax-checked (`bash -n`
  clean), and wired into `test.yml`'s `dry-run` job. Its live
  execution — sparse-cloning the upstream fork and sourcing its
  `buildenv.sh` — was started locally and then **stopped**: the
  clone step tripped an execution-risk check on the cloned upstream
  content, and the rule is not to make exceptions on my own, even
  for a familiar project. The running clone was killed and the
  temporary clone directory removed; no upstream code was sourced
  or executed locally. The dry-run is designed to execute on the
  GitHub-hosted runner via `test.yml` — the isolated environment
  the user authorised for this project (GitHub-only: build runners,
  workflow tester, direct GitHub access; no user servers). That is
  where it should first run: push these files, let `test.yml` run,
  and read its `dry-run` job log. If a local dry-run is wanted
  instead, the user/parent must explicitly say so — that is the
  go-ahead the execution-risk rule requires.

**Not verified / not done:**

- No ROM has been built, no firmware downloaded, no patch applied
  to a real decoded APK in this research. `devices/m51.json` still
  says `status.tested: false`, `built_in_this_research: false`.
- Galaxy AI and blur are traced, not proven (§5.4, §5.5) — there is
  no single switch for either in the tree.
- `devices/README.md`, referenced by `devices/m51.json` and
  `devices/_template.json`, does not exist in the repo yet — it is
  owed by the sibling work that created those files, not by this
  research.

## 10. Licence and credit rules

- **This repo is GPL-3.0** (matching upstream UN1CA). Every file
  derived from upstream keeps its upstream copyright header
  (`Copyright (c) … Salvo Giangreco, SPDX-License-Identifier:
  GPL-3.0-or-later`). New files in this repo carry the
  un1ca-universal header (`Copyright (c) 2026 Kartik Deepak Sormare
  (kkisdevil), SPDX-License-Identifier: GPL-3.0-or-later`).
- **Credit is mandatory.** Every patch, mod, tool, guide or piece of
  information used must name its author and source in `CREDITS.md`
  (repo root) and, for patches, in the patch header (`From:` /
  `Subject:`) and in the module's `module.prop` `author` field. The
  `network-speed` example is credited to Salvo Giangreco /
  salvogiangri/UN1CA in all three places.
- **What must be credited:** the upstream repo and branch a
  patch/mod came from; the author in the patch `From:` line; any tool
  (apktool, samloader, erofs-utils, …); any guide or XDA/GitHub
  source followed; anyone who fixed a failure in the loop.
- **What must NOT be copied:** Samsung's proprietary firmware, blobs
  and apps (downloaded at build time from Samsung, not committed);
  anyone's private key or keybox; another project's branding as your
  own. Carbon's own modules are ARGLP-licensed, not GPL-3.0 — do not
  copy `carbon_ours/` code into a GPL-3.0 tree without checking its
  licence first.
- **If you contributed and are missing from CREDITS.md**, open an
  issue — the file is meant to grow.
