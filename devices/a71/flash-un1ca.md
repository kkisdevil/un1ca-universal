# Flash UN1CA - Galaxy A71 (SM-A715F)

Flash UN1CA on the SM-A715F. This file is for the SM-A715F only.
Do not use it on any other model. Do not use it on the Galaxy
A71 5G (SM-A716, codename a71xq): that is a different phone with
no UN1CA target.

## What UN1CA is on this device

UN1CA is a custom firmware system for Samsung Galaxy phones. It
downloads stock firmware, applies patches, and builds a
flashable zip per device. For the A71 it is based on the latest
stable Galaxy S22 firmware, with Galaxy AI, EROFS, DeX,
KnoxPatch, Play Integrity Fix, and its own OTA app.

A UN1CA target **exists** for this device, in both branches:

- Primary: `Arnav3078/UN1CA-SM7150`, branch `seventeen`, UN1CA
  5.4.0. Target: `target/a71/`.
- Alternative: `mehedihjoy0/UN1CA-SM7150`, branch `sixteen`,
  UN1CA 3.2.1. Target: `target/a71/`.

**The two targets are identical.** The config, the assertions,
and the patch list are byte-identical between the branches
(verified by diff, 2026-11-25). The latest commit touching
`target/a71/config.sh` is the same in both:
`571409392ce6edd3099cfe2a045037347809def4` (2026-09-24). The
only difference between the branches is the UN1CA version
itself (5.4.0 vs 3.2.1). Unlike the m51, there is no SDK split
here: both branches build the A71 at SDK 33.

## Build status (honest)

- **No a71 build has been run.** Not by us, not in this repo.
  There is no run id, no artifact, no SHA-256, no download.
- **No a71 build has been flashed or tested.** Nothing in this
  file has been run end-to-end on an A71 by us.
- Signing keys: unknown. Builds in this repo sign with throwaway
  test keys unless real keys are set up. Test keys are never a
  release build.

## What the zip does

Read from the target files (Arnav `seventeen`, identical in
Mehedi `sixteen`):

- **Target firmware:** SM-A715F/ROM/352641111234568
  (`target/a71/config.sh:7`). SDK 33, shipping API 29, board
  API 30 (`config.sh:9-11`).
- **Bootloader assertion:** the installer aborts unless the
  bootloader is at least `A715FXXU8DVK1` (or
  `A715FZHU8DVK1` for the ZH variant), "requires Android 13
  firmware" (`target/a71/installer/assertions.edify:3`). There
  is **no model assert** and **no `ro.boot.rp` check** in the
  a71 assertions.
- **The zip does NOT flash bootloader or modem firmware.**
  `target/a71/installer/` contains only `assertions.edify` and
  `recovery.fstab`. There is no `customize.sh` and no
  `install-end.edify` (the m51 has both, and the m51's modem/BL
  flash lives in its install-end.edify). The generated
  updater-script writes only the dynamic partitions, the kernel
  bins, and `boot.img`. **TODO: verify on a real a71 artifact**
  (the KERNEL_BINS list was not located in the build scripts).
- **The zip does NOT wipe fingerprint enrolments or dalvik-cache
  on its own.** Those wipes live in the m51's install-end.edify,
  which the a71 does not have. **TODO: verify on a real a71
  artifact.**
- **The zip does NOT touch recovery.** The generated
  updater-script never writes a recovery image, and the target
  has no installer script that could. **TODO: verify on a real
  a71 artifact** (no recovery.img in the zip, no recovery write
  in the updater-script).

## BLOCKER: the installer refuses the only TWRP that exists

**Do not flash UN1CA on the A71 until this is settled.**

The a71 assertions file (`target/a71/installer/assertions.edify:1-2`)
aborts the install if the recovery version string contains
"afaneh92":

```text
abort("This recovery is not supported, please use a different recovery")
```

afaneh92's TWRP is the **only** TWRP found for this phone (see
[flash-twrp.md](flash-twrp.md)). Its version string is
`3.7.0_11-1-afaneh92`, which contains "afaneh92". So the UN1CA
zip, as shipped, **cannot be flashed from the only recovery
this device has**.

**TODO: this is unresolved.** The questions to answer before
any a71 UN1CA flash:

1. Is there another recovery for the A71 that the installer
   accepts (LineageOS recovery? another TWRP build whose
   version string does not contain "afaneh92"?)? No candidate
   was found.
2. Or does the check target an old afaneh92 build and a newer
   one is accepted? The check matches the string, not the
   version, so a newer afaneh92 build is refused the same way.
3. Or should the assertion be patched out of our own build?
   That is a fork change, not a user step, and it needs a
   decision.

Do not flash UN1CA on the A71 until one of these is settled.
This file records the blocker, not a workaround.

## The fix pack (none exists for this device)

**There is no a71 fix pack.** The m51 fix pack (thermal caps,
blur off, zram, swappiness, daemon override) lives in
`patches/m51-performance/` and applies to the m51 only. The a71
target has **no `tweaks` module** at all (its patch list is:
blobs, camera, dvfs, edge_lighting, emulated_storage, fbe, fcm,
kernel, miscs, ril, stock_props). The m51 fix pack's
`tweaks/customize.sh` override has nothing to hook into on the
a71.

The a71's own lag profile has not been measured. The m51's
causes (S23 firmware on a Snapdragon 730, thermal caps at
35-38 C, blur forced on, zram off, swappiness 100) are
**not** copied here as a71 facts. **TODO: measure the a71 lag
profile from the a71's own files** (its `siop_a71_sm7150` DVFS
policy, its own patches) before writing a fix pack for it.

What the a71 target does have, from its own files:

- DVFS policy `dvfs_policy_sm7150_xx`, SIOP `siop_a71_sm7150`
  (`config.sh:38-39`).
- Floating features: only
  `SEC_FLOATING_FEATURE_LCD_SUPPORT_EXTRA_BRIGHTNESS=TRUE`
  (`target/a71/sff.sh`). No blur flags are set here at all.
- HFR 60, mode 0 (`config.sh:43-44`).
- In-display optical fingerprint:
  `TARGET_FINGERPRINT_CONFIG_SENSOR="google_touch_display_optical,settings=3"`
  (`config.sh:40`).
- Kernel: the Paradigm kernel, downloaded as `boot.img` +
  `dtbo.img` from
  https://github.com/UN1CA/kernel_samsung_sm7150/releases/latest/download
  (`target/a71/patches/kernel/customize.sh`). Latest release
  20261106-144920: boot.img 49,889,280 B, dtbo.img 2,346,289 B.
  The boot image fits the 64 MB boot partition
  (`config.sh:15`).

## How the build is made

- Firmware download: samloader-rs (the same tool as the m51
  flow; pinned v2.0.0 for the UN1CA flow in this repo).
- Target pin: Arnav `seventeen`, `target/a71/config.sh` last
  touched by commit `57140939` (2026-09-24). The full pin for a
  build is the workflow run's head commit, not this file's
  commit.
- OTA system: **TODO: unknown for a71.** The m51 OTA backend
  (UN1CA-M51-Updates) is m51-only. Whether an a71 OTA manifest
  exists, and where, was not checked.

## Prereqs

1. **Unlocked bootloader.** Do
   [unlock-bootloader.md](unlock-bootloader.md) first.
2. **TWRP installed.** Do
   [flash-twrp.md](flash-twrp.md) first. **But see the blocker
   above: the UN1CA installer refuses afaneh92's TWRP.**
3. **Back up everything** (and back up EFS in TWRP).
4. **Battery above 50%, ideally full.**
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A715F**.
6. **Minimum bootloader: A715FXXU8DVK1** (or A715FZHU8DVK1 for
   the ZH variant). The latest stock build A715FXXSBDXB1
   (bootloader 11) satisfies this. See
   [flash-stock.md](flash-stock.md).
7. **The UN1CA zip and its SHA-256, checked against the build
   record.** **TODO: no a71 build exists yet, so there is no zip
   to check.**

## Steps

**Do not run these until the TWRP blocker above is settled and
a real a71 build exists.** The steps below are the standard
UN1CA flash flow, written down so the procedure is ready when
the blocker clears.

1. Copy the UN1CA zip onto the phone.
2. Boot into TWRP (power off, hold Volume Up + Power).
3. **Coming from stock or another ROM:** Wipe, Format Data, type
   `yes`. **Updating from an older UN1CA:** a dirty flash (no
   Format Data) is the usual route, but **TODO: the a71
   update path has not been verified.**
4. Install, choose the UN1CA zip, swipe to flash.
5. Reboot to System. First boot takes a few minutes (dexopt).
   Let it finish.
6. Check Settings, About phone: the UN1CA version should read
   5.4.0 (or 3.2.1 for the Mehedi branch).

## Verify

- Settings, About phone: UN1CA version reads 5.4.0 (or 3.2.1).
- The phone boots, calls work, data works, Wi-Fi works.
- The in-display fingerprint enrols (sensor at 540|2105|90).
- **TODO: no a71 fix pack exists, so there are no fix-pack
  values to verify on this device** (no swappiness, refresh
  rate, or thermal checks from the m51 pack apply here).

## Troubleshooting

- **Installer refuses with a bootloader assertion.** The phone
  is on a bootloader older than A715FXXU8DVK1. Flash the stock
  firmware first ([flash-stock.md](flash-stock.md)); the
  latest build A715FXXSBDXB1 is bootloader 11 and satisfies it.
- **Installer refuses with "This recovery is not supported".**
  That is the afaneh92 check (the blocker above). Do not
  work around it by renaming the recovery. Stop and settle the
  blocker first.
- **Bootloop after flashing.** Boot into TWRP and restore the
  backup (or flash stock from
  [flash-stock.md](flash-stock.md)). Do not wipe data first
  unless you have a backup: the bootloop may be fixable without
  losing data.
- **Fingerprint enrolments gone after flashing.** **TODO:
  unverified for a71.** The m51 zip wipes them on every flash
  (its install-end.edify does it). The a71 has no
  install-end.edify, so it should not happen, but that is
  unproven until a real a71 artifact is checked.

## Going back to stock

Flash the stock firmware: [flash-stock.md](flash-stock.md).
Knox stays tripped.

## Sources

- Target exists in both branches, config identical, SDK 33,
  target firmware SM-A715F/ROM/352641111234568, partitions
  (boot 67,108,864; DTBO 10,485,760; cache 419,430,400; super
  8,053,063,680; QTI dynamic 8,048,869,376), DVFS
  `dvfs_policy_sm7150_xx` / `siop_a71_sm7150`, fingerprint
  `google_touch_display_optical,settings=3`, HFR 60 mode 0, RIL
  "onebinary embms_qc", SIM tray count 1, ESE NXP JCOP4.0:
  Arnav3078/UN1CA-SM7150@seventeen, `target/a71/config.sh`
  (81 lines, full read 2026-11-25); diff against
  mehedihjoy0/UN1CA-SM7150@sixteen `target/a71/config.sh` is
  empty (verified 2026-11-25).
- Assertions (afaneh92 abort; bootloader >= A715FXXU8DVK1 or
  >= A715FZHU8DVK1; no model assert; no ro.boot.rp check):
  Arnav3078/UN1CA-SM7150@seventeen,
  `target/a71/installer/assertions.edify` (3 lines, full read
  2026-11-25); identical in mehedihjoy0@sixteen.
- Installer contains only `assertions.edify` + `recovery.fstab`
  (no `customize.sh`, no `install-end.edify`): GitHub API
  directory listing of `target/a71/installer/` on both branches
  (2026-11-25).
- Patch list (11 modules, no tweaks, no vibrator, no
  keymaster): GitHub API directory listing of
  `target/a71/patches/` on both branches (2026-11-25).
- `sff.sh` (only EXTRA_BRIGHTNESS=TRUE):
  Arnav3078/UN1CA-SM7150@seventeen, `target/a71/sff.sh` (full
  read 2026-11-25).
- Paradigm kernel download (boot.img + dtbo.img from
  UN1CA/kernel_samsung_sm7150 releases/latest/download):
  Arnav3078/UN1CA-SM7150@seventeen,
  `target/a71/patches/kernel/customize.sh` (full read
  2026-11-25). Latest release 20261106-144920, boot.img
  49,889,280 B, dtbo.img 2,346,289 B: GitHub API,
  https://api.github.com/repos/UN1CA/kernel_samsung_sm7150/releases/latest
  (2026-11-25).
- The generated updater-script writes only dynamic partitions,
  kernel bins, and boot.img: `scripts/internal/build_full_ota_zip.sh`
  `GENERATE_UPDATER_SCRIPT` (Arnav `seventeen`, read 2026-11-25).
- Target pin commit `57140939` (2026-09-24): GitHub API,
  commits for `target/a71/config.sh` on both branches
  (2026-11-25).
- afaneh92 is the only TWRP found: XDA thread
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-a71-snapdragon.4350893/
  (see [flash-twrp.md](flash-twrp.md)).
- m51 comparison facts (LostPrime kernel, install-end.edify
  modem/BL flash and fingerprint wipe, fix pack): the m51
  record and `target/m51/` in the same repo. Not a71 facts.
