# Flash UN1CA - Galaxy A72 (SM-A725F)

Flash the UN1CA One UI port on the SM-A725F. This file is for the
SM-A725F only. Do not use it on any other model. The installer
also accepts the SM-A725M, but this guide is written for the
SM-A725F and nothing here is verified on the SM-A725M.

## What UN1CA is

UN1CA is a One UI port: Samsung's flagship firmware rebuilt for
the A72, with Galaxy AI, KnoxPatch, Play Integrity Fix, and its
own OTA app. The upstream project is
https://github.com/salvogiangri/UN1CA, branch `sixteen`, and the
A72 target lives at
https://github.com/salvogiangri/UN1CA/tree/sixteen/target/a72q.
This porter's UN1CA base for this device is **3.2.1**.

The target directory holds: `config.sh` (device configuration),
`camera/camera-feature.xml`, `dvfs/siop_model.xml`,
`installer/assertions.edify`, `overlay/values` and `overlay/xml`,
`sff.sh` (floating features), and
`vintf/compatibility_matrix.device.xml`. There is no patches
directory in the target: no device-specific patch list is shipped
with it. TODO: check the main UN1CA build scripts for patches
applied to all `sixteen` targets and record which ones touch the
a72q build.

## Build status (honest)

Upstream **UN1CA 3.2.1** was released 2026-09-29. The official
release page lists a Galaxy A72 (a72q) download:

- gofile.io: https://gofile.io/d/phgptdHz
- Google Drive:
  https://drive.google.com/file/d/1evGI8FoxGmbIAcnS5DCoxkYoYQJCr2aA/view?usp=sharing
- MD5: `13914f15f057d1ff4c941a91832eaedf`
- SHA1: `7695f5554402b72da3b8b03b7061265166b77582`

The 3.2.1 changelog lists RKP keyboxes support, a Samsung Camera
OCR fix on legacy devices, and minor adjustments and fixes. No
A72-specific changelog line is given.

TODO: this is the upstream release, not our own porter build.
No UN1CA build has been made in this porter for the a72q yet, so
there is no build number, run id, artifact name, size, SHA-256,
retention or download-by date to record. No signing key decision
has been made for this device either. **The zip has not been
flashed or tested on an A72 in front of us.** Download the
upstream zip, verify the MD5 and SHA1 above, and record the
flash result here.

## What the zip does (read before flashing)

- The installer asserts the model and the bootloader. From
  `target/a72q/installer/assertions.edify`:
  - SM-A725F requires bootloader **A725FXXU6EWL4 or newer**,
    otherwise it aborts with
    `E3003: This package requires Android 14 firmware.`
  - SM-A725M requires bootloader **A725MUBU6EXB3 or newer**,
    same abort message.
  - So the phone must already be on Android 14 firmware. The
    FYC1 stock build (bootloader B, 11, see flash-stock.md) is
    newer than A725FXXU6EWL4 (bootloader 6), so a phone on FYC1
    passes the assertion. A phone still on an older bootloader
    must flash stock first.
- TODO: does the zip flash bootloader or modem firmware? The
  assertions file only checks versions; it does not flash them.
  Read the upstream installer script for the `sixteen` branch
  and record whether BL/CP are flashed, and which versions.
- TODO: does it wipe fingerprint enrolments or dalvik-cache?
  The m51 build does both on every flash. Do not assume the
  same here until the installer script is read.
- TODO: does it touch recovery? It must not. Verify from the
  installer script, do not assume. The target directory has no
  installer script beyond `assertions.edify`, so the check has
  to be done against the main build tree.

## The fix pack

There is **no a72q fix pack yet**. No lag report exists for this
device in this porter, and no thermal, blur, zram or swappiness
values have been measured on it. The upstream target does ship
device tuning files: a DVFS policy
(`dvfs_policy_sm7125_xx`, config.sh line 29), an SIOP model
(`siop_a72q_sm7125`, line 30, file `dvfs/siop_model.xml`), and
an extra brightness floating feature (`sff.sh`). Those are
upstream tuning, not a fix pack we wrote. TODO: measure the
phone on UN1CA 3.2.1 (thermals, refresh rate behaviour, memory
pressure) and decide whether a fix pack is needed at all.

What is known about the display: the panel defaults to 90 Hz
and supports 60 and 90 (config.sh lines 34 to 36), so the
refresh rate check after flashing is 90 Hz, not 60. The
fingerprint sensor is in-display optical
(`google_touch_display_optical,settings=3`, line 31), not
side-mounted, so fingerprint enrolment behaviour after flashing
is a separate check from the m51.

## How the build is made

TODO: no porter build exists for this device yet. Record here,
once the first build is run: the firmware download tool and
version, the target pin (repo, branch, commit), the donor
firmware the build is based on, and the OTA system, if one is
set up for this device. The upstream README says the UN1CA build
system downloads and extracts firmware components, applies the
required patches, and generates a flashable zip. The donor base
for the `sixteen` branch is the latest stable Galaxy S22
firmware, per the upstream README. TODO: confirm the exact donor
build used for the 3.2.1 a72q zip.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first. A Format
   Data is needed when coming from stock or another ROM.
3. **Battery above 50%, ideally full.**
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A725F**.
5. The phone must already be on Android 14 firmware with
   bootloader **A725FXXU6EWL4 or newer** (FYC1, bootloader B,
   qualifies). Check the bootloader version in Download mode
   before flashing.
6. The UN1CA 3.2.1 zip for a72q on the phone or an SD card, with
   its MD5 and SHA1 checked against the build status above.

## Steps

1. TWRP installed (prereq 1), backup taken (prereq 2). The phone
   must already be on bootloader A725FXXU6EWL4 or newer.
2. Copy the UN1CA zip to the phone (or an SD card).
3. In TWRP: Wipe, Format Data, type `YES` if coming from stock or
   another ROM (encryption differs). If updating from an older
   UN1CA, a dirty flash is usually fine. TODO: confirm whether
   the 3.2.1 zip wipes dalvik itself.
4. Install, select the UN1CA zip, flash it. Wait. It is a large
   zip; the flash takes several minutes.
5. Reboot, System. First boot takes several minutes. Set up, then
   leave the phone idle about 30 min for dexopt before judging
   performance.
6. Check the version and the display (see "Verify" below).

## Verify

- Settings shows the UN1CA version (3.2.1) and the device name
  Galaxy A72.
- The display runs at 90 Hz by default. Check with
  `adb shell dumpsys SurfaceFlinger` and confirm 90.00 Hz, and
  confirm 60 Hz is also available.
- **In-display fingerprint enrols and unlocks.** Re-enrol after
  the flash; enrolments may be wiped by the install (TODO:
  confirm).
- Wi-Fi, calls, mobile data, and camera work. Record which of
  these were actually tested; a boot alone proves none of them.
- TODO: record the effective swappiness, thermal behaviour, and
  any lag measurements here once the first flash is done, so a
  fix pack decision has numbers behind it.

## Troubleshooting

- **Installer refuses with a bootloader assertion (E3003).**
  The phone is below A725FXXU6EWL4 or not on Android 14
  firmware. Flash the stock FYC1 firmware first
  ([flash-stock.md](flash-stock.md)), which is bootloader B
  (11), then retry.
- **Bootloop after flashing.** Boot into TWRP, Format Data, and
  re-flash the zip. If it still bootloops, capture a log (`adb
  logcat -d`) before wiping, and report it.
- **Fingerprint enrolments are gone after flashing.** Re-enrol.
  TODO: confirm whether the 3.2.1 zip wipes enrolments on every
  flash; if it does, this line becomes "Expected" instead of a
  TODO.
- **Lag or heat after 30 min idle.** Record the numbers
  (swappiness, thermal zones, frequencies, refresh rate) and
  report them with a log bundle. Do not judge speed before
  dexopt finishes.

## Going back to stock

Flash the [flash-stock.md](flash-stock.md) firmware with Odin
(AP/BL/CP/CSC), then Format Data in stock recovery. Knox stays
tripped. That cannot be undone.

## Sources

- Upstream target:
  https://github.com/salvogiangri/UN1CA/tree/sixteen/target/a72q
  (config.sh, camera, dvfs, installer, overlay, sff.sh, vintf;
  listed via the GitHub API 2026-11-25).
- Upstream target config:
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/a72q/config.sh
  lines 8 (BTU firmware), 10 (SDK 34), 29 to 31 (DVFS policy,
  SIOP model, in-display optical fingerprint), 34 to 36 (90 Hz
  default, 60/90 supported).
- Installer assertions:
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/a72q/installer/assertions.edify
  (A725FXXU6EWL4 / A725MUBU6EXB3 minimums, E3003 message).
- Floating feature:
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/a72q/sff.sh
  (extra brightness enabled).
- UN1CA 3.2.1 release:
  https://github.com/salvogiangri/UN1CA/releases/tag/3.2.1
  (published 2026-09-29; a72q MD5
  `13914f15f057d1ff4c941a91832eaedf`, SHA1
  `7695f5554402b72da3b8b03b7061265166b77582`; Drive link
  https://drive.google.com/file/d/1evGI8FoxGmbIAcnS5DCoxkYoYQJCr2aA/view?usp=sharing).
- Upstream README:
  https://github.com/salvogiangri/UN1CA/blob/sixteen/README.md
  (S22 firmware base, build system description).
