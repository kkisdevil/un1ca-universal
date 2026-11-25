# devices/

One JSON file per device. The build/validate workflow reads these files;
`target/<codename>/` in the upstream UN1CA repo is the source of truth.
If a JSON value and the upstream file disagree, the upstream file wins.

## The universal porter

This folder is the porter's data. The workflow does not hard-code which
upstream fork/branch a device builds from — it resolves it:

- `devices/<codename>.json` — one manifest per device (m51 first).
- `devices/soc-families.json` — SoC family → primary upstream
  fork/branch. sm7150 is `mapped` (a71, m51); the other six families are
  `listed` (codename mapping verified from the upstream `target/` table
  in research/02-targets-sm7150.md, family defaults not yet built).
- `scripts/resolve-device.py` — resolves a device to (SoC family,
  upstream repo, branch, UN1CA version). The build workflow's `resolve`
  job runs it; `scripts/validate-device.sh` checks the device's SoC
  family exists in the manifest.
- `_template.json` — copy it to add a device (see below).

## Files here

- `m51.json` — Galaxy M51 (SM-M515F), sm7150 / Snapdragon 730G.
  The worked example. Primary upstream: Arnav `seventeen`
  (UN1CA 5.4.0); alternative: mehedi `sixteen` (UN1CA 3.2.1).
- `_template.json` — copy it to add a device. Do not edit it in place.

## Per-device folders — `devices/<codename>/`

One folder per device, with that device's guides in deep detail.
Universal does not mean the same for every phone: each folder holds
only its own device's facts, files and steps.

- `devices/m51/` — **complete**: the verified m51 guides, mirrored
  from the m51-hyperos repo (`docs/devices/m51/` is the canonical
  home; if the two copies disagree, that copy wins). Device card +
  unlock bootloader, flash TWRP, root, flash stock ROM, flash the
  HyperOS GSI, flash UN1CA, flash a custom kernel.
- Every other device folder (`a71`, `a52q`, `a72q`, `a52sxq`, `a73xq`,
  `m52xq`, `a53x`, `r8q`, `o1s`, `p3s`, `r9s`, `t2s`, `b0q`, `g0q`,
  `r0q`) — **started, not yet researched**: a device-card README
  with the verified facts (codename, model, SoC family, primary
  upstream from `soc-families.json`) plus the 7 procedure files as
  the blank template. Fill them from the device's own sources —
  never copy the m51 values.

Each folder has the same 8 files: `README.md` (device card) +
`unlock-bootloader.md`, `flash-twrp.md`, `root.md`, `flash-stock.md`,
`flash-gsi.md`, `flash-un1ca.md`, `flash-kernel.md`. A folder is only
"complete" when every guide in it is filled from that device's own
sources and its README says so.

## Add a new device

1. Copy `_template.json` to `devices/<codename>.json`
   (lowercase codename, exactly the `target/<codename>/` directory name —
   `buildenv.sh` discovers targets by directory name).
2. Fill it from the real `target/<codename>/config.sh` in the upstream
   repo: copy firmware strings, partition sizes and DVFS filenames
   verbatim. Never invent them.
3. Copy the closest sibling with the same SoC as your starting point.
   For sm7150 use `a71` (in base) or `m51` (in the forks); for sm7325
   use `a52sxq` / `m52xq`; for sm8450 use `r0q` / `b0q`.
4. List the patches actually present under `target/<codename>/patches/`
   for the branch you are using. Patch lists differ between branches.
5. Validate, then build — see the loop below.

## Modify-and-fix loop (standing rule)

**If it fails, continue to modify and fix errors and repeat the
modify-and-fix loop until all errors are fixed and the ROM builds.
Do not stop at the first failure.**

1. Run the validate/build run and keep the full log.
2. Fix the one error the log names — in the JSON and, if the JSON was
   right, in the generated `target/<codename>/` files — from the real
   upstream `target/` files, not from memory.
3. Re-validate. If the JSON was wrong, fix the JSON; if the upstream
   files changed, re-read them and update the JSON to match.
4. Repeat until the build succeeds. A device is only marked
   `tested: true` in its JSON after a real build run.

## Fields that most often break a build — and their fixes

See also `research/02-targets-sm7150.md` §6. In order of how often
they are the cause, from the repo evidence:

| Field | How it fails | Fix |
|---|---|---|
| `codename` | `buildenv.sh` refuses it: `"X" is not a valid device` — the directory `target/<codename>/` does not exist, or the JSON codename does not match the directory name exactly. | Rename the JSON file and the `codename` field to the exact upstream directory name. Check with the GitHub `target/` listing. |
| `base_firmware` / `target_firmware` | Wrong firmware is downloaded (`download_fw.sh`), or the build targets the wrong model. The trailing digits are part of the identifier — changing them by hand breaks the match. | Copy `TARGET_FIRMWARE` verbatim from `target/<codename>/config.sh`. Never edit the trailing digits. |
| `csc` | Wrong CSC in the firmware string → wrong regional firmware, wrong variant, installer assertions fail. | CSC is the second field of `TARGET_FIRMWARE` (`MODEL/CSC/...`). For m51 it is `BVO`; extra firmware is `EUX`. Copy it, do not guess it. |
| RIL blobs (`ril.vendor_libs_required`) | No signal / no calls / RIL crash. The 8 libraries in m51's `patches/ril/vendor/lib64/` are device-specific — a71 vendors only 3 of them. | Take the list from the device's own `target/<codename>/patches/ril/vendor/lib64/`. Do not reuse another device's RIL blobs. |
| Kernel | Build cannot find the kernel, or the phone bootloops. The kernel is not in the UN1CA repo. | Use the device's `patches/kernel/customize.sh` source (m51 mehedi: latest `m51-ksu*.zip` from `kurtnettle/android_kernel_samsung_sm7150`). If that release is gone, find the replacement release and update `kernel` in the JSON. |
| Firmware files (`installer/customize.sh`) | Missing `vbmeta.img` / firmware files at install time. | m51 downloads them from `mehedihjoy0/M51-FIRMWARES` at build/install time. Check that repo still exists and that the cache path is correct for your branch (arnav caches under `out/cache/M51-FIRMWARES`). |
| Partitions (super / dynamic / boot / DTBO) | Image too large for the super partition, or flashing fails. | Copy the partition sizes verbatim from `config.sh`. m51: super 8053063680, QTI dynamic 8048869376, boot 67108864, DTBO 10485760, cache 419430400. |
| `bootloader_required` | Installer aborts in recovery (`assertions.edify`). | m51 requires bootloader `M515FXXS6DXE3`. Arnav's `assertions.edify` has no `ro.boot.rp` check (verified in the build #8 artifact); Mehedi's sixteen tree exempts `ro.boot.rp == "6"` from the abort — it does not reject it. The test device must be on that firmware first. |
| DVFS / SSRM filenames | Build cannot find the DVFS policy, or thermal behaviour is wrong. | Copy `TARGET_DVFSAPP_CONFIG_DVFS_POLICY_FILENAME` and `..._SSRM_POLICY_FILENAME` verbatim (m51: `dvfs_policy_sm7150_xx`, `siop_m51_sm7150`). The SoC is carried by these names on sm7150 — there is no `TARGET_PLATFORM` line to fix instead. |
| Fingerprint sensor | Fingerprint enrolment fails or the sensor position is wrong. | Copy `TARGET_FINGERPRINT_CONFIG_SENSOR` verbatim (m51: `google_touch_side,settings=3,navi=1`). Mehedi's `sidefp` smali patch hardcodes the position; arnav has no `sidefp` patch — verify fingerprint separately on `seventeen`. |
| Branch mix-up (`sixteen` vs `seventeen`) | A `sixteen` patch list / SDK value applied to a `seventeen` build, or vice versa. m51 SDK is 31 on sixteen, 33 on seventeen; patch lists differ (20 vs 18 groups). | Keep the branch in the JSON (`upstream[].branch` + `unica_version`) and use only that branch's `target/<codename>/` files for that build. |

## What this folder is not

- It is not the ROM source. The ROM source is the upstream UN1CA repo
  (plus the forks for m51). These JSON files are an index to it.
- No firmware, blobs or kernel binaries live here. They are downloaded
  at build time from the sources named in each JSON file.
