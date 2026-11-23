# Copyright (c) 2026 Kartik Deepak Sormare (kkisdevil) — UN1CA Universal
# SPDX-License-Identifier: GPL-3.0-or-later

# Patches — where they live, what format they are, and how they are applied

This directory holds **this project's own patches**, in the exact layout
upstream UN1CA uses, so that anything validated here can be dropped into
an upstream-style build unchanged. Upstream itself is not copied here:
the build workflow checks out the upstream fork and applies *its*
patches from *its* tree. Patches in this directory are additions or
overrides that belong to un1ca-universal.

Upstream reference (read-only, GitHub-only, checked 2026-11-23):
`salvogiangri/UN1CA`, branch `sixteen`, version 3.2.1.

## 1. Where patches live upstream

Upstream has three patch layers, applied in this order by
`scripts/make_rom.sh` (see `research/03-patches-modifications.md` §2):

| Order | Directory in the upstream tree | What it is |
|---|---|---|
| 1 | `platform/<platform>/patches/` | SoC-family fixes, e.g. `platform/sm7325/patches/` (DVFS, kernel, stock props). Only present for some platforms. |
| 2 | `target/<codename>/patches/` | Device fixes, e.g. `target/m51/patches/` in the SM7150 forks (side fingerprint, RIL blobs, camera, DVFS). |
| 3 | `unica/patches/` | ROM-wide compatibility patches, grouped by area: `bluetooth/`, `camera/`, `dvfs/`, `ese/`, `legacy/`, `product_feature/`, `selinux/`, `vintf/`, `vndk/`, … |
| 4 | `unica/mods/` | Feature mods — the same module format, plus new files and `customize.sh` logic. Applied after the three patch layers. |

Each layer is a folder of **modules**. One module = one folder, and
`scripts/internal/apply_modules.sh` walks the folders in `LC_ALL=C`
sorted order and runs `APPLY_MODULE` on each one.

A module is:

```
<name>/
  module.prop          # REQUIRED — id, name, author, description
  customize.sh         # optional — shell code, run after files are copied
  system/              # optional — files copied into the system partition
  system_ext/          # optional — files copied into system_ext
  product/ odm/ vendor/ # optional — same, for those partitions
  smali/               # optional — *.patch files, applied with git apply
  *.prop               # optional — build.prop-style key=value lines
                       # (one file per partition: system.prop, vendor.prop)
  disable              # optional — if this empty file exists, the module
                       #   is skipped entirely (upstream uses this, e.g.
                       #   unica/mods/blocklist/disable in Carbon's
                       #   core_unica/ copy)
```

`module.prop` format — exactly four `key=value` lines, no quotes:

```
id=network-speed
name=Real-time network speed in status bar
author=salvogiangri
description=Enables the real-time network speed indicator in the status bar (upstream UN1CA csc mod).
```

`id` must be unique inside its layer. `author` is the credit — it is
printed in the build log (`Processing "…" by @…`) and it is how credit
is kept. Never change `author` on a patch you did not write.

## 2. Patch format

Two different things are both called "patch" in UN1CA. Do not mix them up.

### 2a. Git smali patches — `smali/<partition>/<path>/<file>.apk|jar/<NNNN>-<name>.patch`

This is the main mechanism. A file under a module's `smali/` directory
is a **unified diff against apktool-decoded smali**, produced by
`git format-patch` from a decoded APK tree. Layout:

```
smali/system/priv-app/SecSettings/SecSettings.apk/
  0001-Enable-real-time-network-speed-in-status-bar.patch
```

- The directory path under `smali/` is the partition + the path of the
  APK/JAR **inside the work dir**, e.g. `system/priv-app/SecSettings/
  SecSettings.apk`. (`system/` is stripped for the system partition
  when the file is located; other partitions keep their prefix.)
- The number prefix (`0001-`) sets the order: patches are applied in
  sorted order (`find … -name "*.patch" | sort -n`). Number them
  `0001`, `0002`, … and leave gaps if you expect to insert one later.
- The patch header must be a real `git format-patch` header:
  `From <sha>`, `From: <author>`, `Date:`, `Subject: [PATCH] …`,
  then `diff --git a/… b/…` hunks with `@@` context lines.
- The diff is applied with
  `git apply --directory=<apktool-dir>/<partition>/<file> --verbose
  --unsafe-paths <patch>` (see `scripts/utils/module_utils.sh`,
  `APPLY_PATCH`). Before that, the APK/JAR is decoded with apktool
  (`DECODE_APK`, `scripts/apktool.sh d … --no-debug-info`).
- The context lines (`@@ … @@` plus the 3 lines around each change)
  must match the decoded smali **exactly**. If the source firmware
  changes one line of context, the patch fails — see §5.

The example in this directory,
`network-speed/smali/system/priv-app/SecSettings/SecSettings.apk/
0001-Enable-real-time-network-speed-in-status-bar.patch`, is a real
upstream patch, copied verbatim (SHA-256 `5c08ed3a049c9952b6895c8e74d
46f7190a1584f0c5c1ec7f4d796889756c34a`). It replaces a
`SemCscFeature.getBoolean("CscFeature_Common_SupportZProjectFunction
InGlobal", false)` check with a hardcoded `const/4 v0, 0x1` in three
smali files, so the network-speed setting is always available. See §4
for a line-by-line walkthrough.

### 2b. Dynamic smali patches — `SMALI_PATCH` in `customize.sh`

For changes too small or too conditional for a patch file, upstream
`customize.sh` scripts call `SMALI_PATCH` (defined in
`scripts/utils/smali_utils.sh`):

```
SMALI_PATCH <partition> <apk/jar> <smali-file> <operation> [method] [value] [replacement]
```

Operations: `null` (empty a method), `remove` (delete a smali file),
`replace <method> <value> <replacement>`, `replaceall <value>
<replacement>`, `return <method> <value>` (make a method return a
constant), `strip <method>` (delete a method).

Example from upstream `unica/mods/knoxpatch/customize.sh` — force a
root check to return false:

```
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali/com/android/server/StorageManagerService.smali" "return" \
    'isRootedDevice()Z' 'false'
```

`SMALI_PATCH` decodes the APK first if it is not already decoded, and
fails loudly (`LOGE …; return 1`) with the file and method name if the
smali file or the method is not found — including a list of possible
matches. That is the behaviour the modify-and-fix loop depends on.

### 2c. Binary patches — `HEX_PATCH` in `customize.sh`

For native libraries / binaries, `HEX_PATCH` (in
`scripts/utils/module_utils.sh`) replaces one equal-length hex string
with another and fails if the `FROM` string is not found or the lengths
differ:

```
HEX_PATCH <file> <from-hex> <to-hex>
```

### 2d. Props and floating features — `*.prop` files and `SET_*` helpers

- A `<partition>.prop` file at a module's root (e.g. `system.prop`,
  `vendor.prop`) is a list of `key=value` lines. `apply_modules.sh`
  (`READ_AND_APPLY_PROPS`) writes each one with `SET_PROP`; a line
  with an empty value (`key=`) **deletes** that prop. A malformed line
  (no `=`) fails the build.
- `SET_FLOATING_FEATURE_CONFIG <config> <value>` (same file) adds,
  replaces or deletes (`-d` / `--delete`) an entry in
  `/system/system/etc/floating_feature.xml` — the Samsung feature-flag
  file. This is how most "enable X on this device" switches work:
  the source firmware already contains the code, the flag turns it on.
- `SET_PROP_IF_DIFF <partition> <prop> <value>` only writes when the
  current value differs.
- `GET_FLOATING_FEATURE_CONFIG <config>` reads a flag, so a
  `customize.sh` can branch on what the source firmware supports.

## 3. How a module is applied, step by step

`scripts/internal/apply_modules.sh`, function `APPLY_MODULE`:

1. The folder must contain `module.prop`, or the build fails with
   `File not found: …/module.prop`. A `disable` file in the folder
   skips the module silently.
2. Unless `customize.sh` contains `SKIPUNZIP=1`, the module's
   `odm/`, `product/`, `system/`, `system_ext/`, `vendor/` trees are
   copied into the work dir with fixed owners/modes/SELinux contexts
   (`ADD_TO_WORK_DIR` — system files `0:0 755
   u:object_r:system_file:s0`, vendor files `0:2000`).
3. `*.prop` files are applied (`READ_AND_APPLY_PROPS`).
4. `customize.sh` is sourced (`.` — it runs in the build shell, with
   `$MODPATH`, `$WORK_DIR`, `$APKTOOL_DIR` and all the helpers above).
5. Every `*.patch` under `smali/` is applied in sorted order
   (`APPLY_SMALI_PATCHES` → `APPLY_PATCH` → apktool decode, then
   `git apply`).
6. The decoded APKs/JARs are rebuilt at the end of `make_rom.sh`
   (`BUILD_APKS`, max 8 parallel jobs, `scripts/apktool.sh b …`),
   re-signed with the platform key (`signapk`, `security/
   *_platform.pk8/.x509.pem`) for APKs, zipaligned for JARs, and
   copied back into the work dir.

Order matters: platform patches → device patches → ROM patches →
ROM mods. A mod can therefore override a patch, and a device patch can
override a platform patch. Two patches that touch the same smali lines
must be ordered so the second one's context matches the first one's
output.

## 4. Worked example — the `network-speed` patch in this directory

Source (verbatim, credited): upstream
`unica/mods/csc/smali/system/priv-app/SecSettings/SecSettings.apk/
0001-Enable-real-time-network-speed-in-status-bar.patch`,
from `salvogiangri/UN1CA` branch `sixteen`, commit `cf9b438bc847d1
71dcfd6b54cd2c134052e982b0`, 2025-10-17, author Salvo Giangreco
<giangrecosalvo9@gmail.com>, subject "[PATCH] Enable real time
network speed in status bar". GPL-3.0-or-later, as upstream.

What it changes (3 files, 8 insertions, 46 deletions):

| Smali file | Change |
|---|---|
| `smali_classes3/…/notification/ConfigureNotificationMoreSettings$1.smali` | `getNonIndexableKeys()` no longer hides the setting when the CSC flag is off. |
| `smali_classes3/…/notification/StatusBarNetworkSpeedController.smali` | `<clinit>` sets `SUPPORT_NETWORK_SPEED` to true instead of reading the CSC flag. |
| `smali_classes4/…/eternal/provider/items/NotificationsItem.smali` | The settings item no longer gates on the CSC flag. |

The core edit, repeated in all three files, is:

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

That is the canonical UN1CA pattern for a CSC-gated feature: find the
`SemCscFeature.getBoolean("<CscFeature_…>", <default>)` call that gates
it, and replace the whole call sequence with a constant `0x1` (true)
or `0x0` (false). The `.locals` count is adjusted down in the same
hunk (fewer registers are used after the call is removed) — forgetting
that is a common failure, see §5.

Why this patch is in *this* repo: it is the smallest complete example
of the mechanism — one module, one `smali/` tree, no `customize.sh`
logic, no new files — and it is the pattern to copy for any other
CSC-gated feature. It is **not** a new feature of un1ca-universal; it
is upstream's work, kept here as a tested reference.

To use it as a template for a new feature:

1. Copy `patches/network-speed/` to `patches/<your-feature>/`.
2. Edit `module.prop`: new `id` and `name`, your name in `author`
   only for the parts you wrote; keep the upstream credit in
   `patches/README.md` (this file) and in the patch header if you
   reuse upstream hunks.
3. Replace the `smali/` tree with your APK/JAR path and your
   `NNNN-<name>.patch` file(s), numbered in apply order.
4. Run the validator: `.github/workflows/test.yml` checks every patch
   in `patches/` (see §6). Fix what it reports, push again, repeat
   until it is green — that is the modify-and-fix loop.

## 5. Patch failures — what breaks, and how each is fixed

The standing rule for this project: **if it fails, continue to modify
and fix errors and repeat the modify-and-fix loop until all errors are
fixed and the ROM builds. Do not stop at the first failure.**

`test.yml` fails loudly on a bad patch or device file, with the exact
file and error in the log, so the next fix round can target it. The
failures below are the ones upstream's own code produces; the error
strings are quoted from the scripts, so you can grep for them.

| # | Failure | Exact symptom (log) | Cause | Fix |
|---|---|---|---|---|
| 1 | **Bad patch context** | `git apply` fails: `error: patch failed: <file>:<line>` / `error: <file>: patch does not apply` | The decoded smali changed — usually a different source firmware (new One UI / security patch) moved or edited the lines around your hunk. The `@@` context no longer matches. | Re-decode the APK from the *new* source firmware (`unica apktool d system <apk>`), regenerate the patch from the new decode (`git diff` / `git format-patch`), and re-check the `.locals` counts. Never hand-edit the `@@` line numbers — regenerate. |
| 2 | **Wrong file** | `LOGE "Smali not found: "/system/…/<file>.smali""` plus `Possible matches?` (from `SMALI_PATCH`), or `git apply` failing with `No such file or directory` | The smali path is wrong — wrong `smali_classes<N>` bucket (apktool splits classes into `smali`, `smali_classes2`, …), a renamed class, or the APK/JAR path under `smali/` is wrong. | Use the `Possible matches?` list the log prints. Check the decoded tree (`find $APKTOOL_DIR/<partition>/<file> -name "*<ClassName>*"`) and correct the path / bucket number. |
| 3 | **Missing dependency (module order)** | A later patch fails with `patch does not apply`, or `LOGE "Method "…" not found in /…"` | Patch B assumes patch A's output (e.g. a hook method A introduces), but B runs first — modules run in sorted folder order, patches in sorted filename order. | Rename the module folder or the patch number so the dependency applies first. Document the ordering in the module's `customize.sh` comment. |
| 4 | **Missing module.prop** | `LOGE "File not found: …/module.prop"` (from `APPLY_MODULE`) | A new module folder was added without `module.prop`. | Add the four-line `module.prop` (§1). The validator (`test.yml`) catches this before any build starts. |
| 5 | **Malformed prop line** | `LOGE "Malformed string in <file>: "<line>""` (from `READ_AND_APPLY_PROPS`) | A line in a `*.prop` file has no `=` (or a stray space / comment without `#`). | Fix the line, or prefix comments with `#`. Remember `key=` (empty value) is valid — it *deletes* the prop. |
| 6 | **Invalid partition** | `LOGE ""<x>" is not a valid partition name"` | A `smali/` path or an `APPLY_PATCH`/`SMALI_PATCH` call uses a partition that is not one of `system`, `system_ext`, `product`, `vendor`, `odm` (see `IS_VALID_PARTITION_NAME` in `scripts/utils/common_utils.sh`). | Fix the first path component under `smali/` (or the partition argument) to a real partition. |
| 7 | **Apktool decode failure** | `apktool.sh d` fails, or `LOGE "Output directory already exists … Use --force flag"` | The APK was already decoded (a previous failed run left `out/target/<codename>/apktool/…` behind), or the framework tag mismatches the source firmware. | Delete the stale decode dir, or re-run with `--force`. Upstream `make_rom.sh` deletes `$APKTOOL_DIR` on a forced / changed build; a dry run that stops halfway does not. |
| 8 | **`git apply --check` "fails" locally** | `error: <file>.smali: No such file or directory` when you run `git apply --check` in this repo | **Not a failure.** `--check` needs the decoded target files to exist. In this repo there is no decoded firmware, so `--check` cannot pass. | Validate patch *format* with `git apply --stat` (parses the diff, needs no target files) — that is what `test.yml` does. Only run `--check` inside a real build work dir, after `apktool d`. |
| 9 | **Wrong branch / generation** | A patch that applied on `sixteen` fails on `seventeen` (or vice versa) | `sixteen` (One UI 8, UN1CA 3.2.1) and `seventeen` (One UI 9, UN1CA 5.4.0) have different smali. Research `02-targets-sm7150.md` §4 documents this for m51. | Port the patch: re-decode from the *target branch's* source firmware and regenerate. Do not copy a `sixteen` patch onto `seventeen` and hope. |
| 10 | **Keybox / PIF without a keybox** | Play Integrity still fails after the build, or the Settings toggle does nothing | `unica/mods/pif/` only *hooks* attestation; a valid keybox is still required (`Requires a valid keybox` in the README). The `keybox` mod only imitates one for testing. | Do not ship a keybox in the repo. Document that the user must supply their own valid keybox; test with the keybox mod only on a test device. |
| 11 | **Signature mismatch after rebuild** | Rebuilt APKs fail to install / SystemUI crashes on boot | APKs are re-signed with the platform key (`security/*_platform.pk8`); a full build needs the `PLATFORM_KEY_PK8` / `PLATFORM_KEY_PEM` secrets, and the key must match the one the rest of the system was signed with. | In CI, set the two repository secrets (base64, as upstream CI does). Locally, never commit a private key — `security/` contains only the AOSP test keys and the AVB test key in the public tree. |
| 12 | **Build cache hides a change** | `make_rom.sh` says `No changes have been detected in the build environment` and skips the build | `GET_WORK_DIR_HASH` hashes `unica/`, `platform/<platform>/` and `target/<codename>/`; if your change is outside those trees (or the `.completed` marker is stale), it is not detected. | Run `unica make_rom --force` (`-f`), or delete `out/target/<codename>/work_dir/.completed`. |

**The loop, concretely** (standing user rule, 2026-11-23):

1. `test.yml` (or `build.yml` in dry-run, then full) fails and names the
   exact file and error in its log — read the log artifact, not the
   summary line.
2. Fix *that* failure only, in the file it names (patch context →
   regenerate; wrong file → correct the path; missing prop → add it).
3. Commit, push, let the workflow re-run. It will fail on the *next*
   error, if any. Repeat.
4. Do not stop at the first failure, do not "fix" a failure by
   deleting the patch or the test, and do not merge while red.
5. When `test.yml` is green, run `build.yml` in dry-run, then full.
   A full build that fails is the same loop, one level up: the build
   log artifact (`build-logs-<device>-<run_id>`) is uploaded even on
   failure — fix from that log.

## 6. How this directory is tested

`.github/workflows/test.yml` — the workflow tester — validates this
directory on every push, PR and manual run, and fails loudly:

- Every `patches/*/module.prop` exists and has `id`, `name`,
  `author` (non-empty).
- Every `*.patch` under `patches/` parses: `git apply --stat`
  succeeds, and the file has a `Subject:` and a `diff --git` header.
  A patch that does not parse fails the run with its exact path.
- Every `smali/` patch path starts with a valid partition
  (`system`, `system_ext`, `product`, `vendor`, `odm`).
- Every `customize.sh` under `patches/` passes `bash -n` and
  shellcheck (same exclusions upstream uses: `-e SC1090,SC1091`).

The same workflow also validates `devices/*.json`, every workflow
YAML in `.github/workflows/`, that the upstream repos/branches the
devices point to exist, and runs a dry-run build-config check (sparse
clone of the upstream fork, `source buildenv.sh <codename>`, verify
`out/config.sh`) — no firmware is downloaded. See the workflow file
for the exact steps.

## 7. Licence and credits — the rules

- **This repo is GPL-3.0** (matching upstream UN1CA). Every file
  derived from upstream keeps its upstream copyright header
  (`Copyright (c) … Salvo Giangreco, SPDX-License-Identifier:
  GPL-3.0-or-later`). New files in this repo carry the
  unca-universal header (`Copyright (c) 2026 Kartik Deepak Sormare
  (kkisdevil), SPDX-License-Identifier: GPL-3.0-or-later`).
- **Credit is mandatory, not polite.** Every patch, mod, tool, guide
  or piece of information used must name its author and source in
  `CREDITS.md` (repo root) and, for patches, in the patch header
  (`From:` / `Subject:`) and in the module's `module.prop` `author`
  field. The `network-speed` example above is credited to Salvo
  Giangreco / salvogiangri/UN1CA in all three places.
- **What must be credited:** the upstream repo and branch you took a
  patch/mod from; the author in the patch `From:` line; any tool
  (apktool, samloader, erofs-utils, … — see `external/` and
  `.gitmodules` in upstream); any guide or XDA/GitHub source you
  followed; and any contributor who fixed a failure in the loop.
- **What must NOT be copied:** Samsung's proprietary firmware, blobs
  and apps (they are downloaded at build time from Samsung, not
  committed); anyone's private key or keybox (never commit one);
  another project's branding as your own. Carbon's own modules are
  under the ARGLP licence, not GPL-3.0 — do not copy
  `alrigroup/un1ca-carbon` `carbon_ours/` code into a GPL-3.0 tree
  without checking its licence first.
- **If you are missing from CREDITS.md** and you contributed, open an
  issue — the file is meant to grow.
