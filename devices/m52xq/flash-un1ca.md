# Flash UN1CA - Galaxy M52 5G (SM-M526B / SM-M526BR)

Flash the UN1CA One UI port on the SM-M526B / SM-M526BR. This file
is for the SM-M526B and SM-M526BR only. Do not use it on any other
model.

## What UN1CA is

UN1CA is a One UI port: Samsung's flagship firmware rebuilt for
the m52xq, with Galaxy AI, DeX, KnoxPatch, Play Integrity Fix,
and its own OTA app. Upstream is
https://github.com/salvogiangri/UN1CA, branch `sixteen`, and the
m52xq target lives at
https://github.com/salvogiangri/UN1CA/tree/sixteen/target/m52xq.
The upstream README says UN1CA is based on the latest stable
Galaxy S22 firmware, is EROFS powered, and integrates Galaxy AI,
KnoxPatch, TrickyStore key attestation spoof options, and an
integrated Play Integrity Fix.

TODO: the One UI version of UN1CA 3.2.1 is not stated in the
3.2.1 release notes. The XDA thread for the previous release
calls UN1CA 3.1.0 "One UI 8.0" for the M52. Do not assume 3.2.1
is the same One UI version; record it from Settings after
flashing.

## Build status (honest)

There is **no porter build of UN1CA for the m52xq in our repo
yet**. The build below is the **upstream** release, not one we
built or verified ourselves.

Upstream release **3.2.1**, published 2026-09-29:

- Galaxy M52 5G (m52xq) download links: gofile.io and Google
  Drive (Drive file id `1Il-ABdu6VLD6ErQ_eSvWgzCije_GMN-5`).
- MD5: `af5f29aa0d43f0c79489ca8d403ee2af`
- SHA1: `ac9ec17dd6723d67ad5894febda9c0b33f27e4a6`
- Changelog entries touching this device: "(A52s/M52) Added
  'Pause USB charging when gaming' feature", "(A52s/A73/M52)
  Updated kernel to 5.4.302", "(A71/M52) Improved speaker audio
  quality". Other entries: RKP keyboxes support, Samsung Camera
  OCR fix on legacy devices, minor adjustments and fixes.
- TODO: the zip filename and byte size are not in the release
  notes; record them from the actual download before flashing,
  and verify the MD5 and SHA1 above.

**Not yet flashed or tested on an m52xq by us.** No build run,
no artifact check, and no flash of this zip has been done in
this project.

## What the target is (verified from upstream)

From
https://github.com/salvogiangri/UN1CA/blob/sixteen/target/m52xq/config.sh
(48 lines, fetched live 2026-11-25):

- Target firmware: `SM-M526BR/BTU/355568761234563` (line 8). The
  UN1CA build is based on the SM-M526BR / BTU firmware.
- Platform `sm7325` (Snapdragon 778G), platform SDK version 33
  (Android 13), product shipping API level 30 (lines 7, 10, 11).
- Super partition 10,328,473,600 bytes; QTI dynamic partitions
  10,324,279,296 bytes (lines 14-15).
- Display: 120 Hz default refresh rate, HFR mode 2, supported
  rates 60 and 120 (lines 35, 39-41).
- Fingerprint: side sensor, `google_touch_side,settings=3,navi=1`
  (line 32).
- RIL: `onebinary embms_qc`, single-SIM tray count 1 (lines
  46-47).
- DVFS policy `dvfs_policy_sm7325_xx`, SSRM policy
  `siop_m52xq_sm7325` (lines 30-31).

Patch list in
https://github.com/salvogiangri/UN1CA/tree/sixteen/target/m52xq/patches:
`blobs`, `edge_lighting`, `hfr`, `ril`, `sidefp`, `singlesim`,
`wpss`. Notable contents, all read live from the repo:

- `sidefp`: sets the correct fingerprint sensor position value
  (module.prop; smali patch
  `0001-Hardcode-fingerprint-sensor-position-value.patch`). The
  actual position coordinates were not retrieved; TODO, and do
  not copy another device's coordinates.
- `singlesim`: hex-patches `vendor/bin/secril_config_svc` to set
  the SIM count from 2 to 1.
- `hfr`: seamless refresh rate support (idle timer 250 ms, touch
  timer 300 ms, content detection for refresh rate).
- `edge_lighting`: fixes the Edge lighting corner radius
  (`ro.factory.model=SM-A715F`).
- `debloat.sh` (target root): removes only EarphoneTypeC
  (`system/priv-app/EarphoneTypeC` and its permissions XML).
- `sff.sh` (target root): enables HDR effect, seamless refresh
  rate (HFR mode 2), and extra brightness.
- `installer/assertions.edify`: the zip refuses to install unless
  the bootloader is at least `M526BXXU1CVJ7`, `M526BPUU1CVJ7`,
  or `M526BRXXU1CVJ7` (Android 13 firmware), else it aborts with
  "E3003: This package requires Android 13 firmware."

## What the zip does (TODO: verify before flashing)

The following were **not** verified in the upstream files read
during research, so they are TODO, not facts:

- TODO: does the 3.2.1 zip flash bootloader or modem firmware for
  this device, and which versions? Verify from the built zip's
  updater-script before flashing.
- TODO: does it wipe fingerprint enrolments or dalvik-cache on
  every flash? Verify from the updater-script.
- TODO: does it touch recovery? It must not. Verify from the
  updater-script; do not assume.
- TODO: is there a fix pack for this device (thermal caps, blur,
  zram, swappiness)? No fix pack for the m52xq exists in this
  project, and none was found in the upstream target. Do not
  claim any lag fix for this device.

## How the build is made

The upstream build system downloads firmware, extracts it,
applies the m52xq target and patches, and generates a flashable
zip (upstream README). No porter build workflow for the m52xq
exists in our repo yet. TODO: record the firmware download tool
and version, the target pin (repo, branch, commit), and the OTA
system for this device once a porter build exists.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first. A Format
   Data is needed when coming from stock or another ROM.
3. **Battery above 50%, ideally full.**
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-M526B** or **SM-M526BR**
   and the service provider software version must show the CSC
   for your region.
5. The phone must already be on bootloader **at least CVJ7**
   (Android 13 firmware). Any recent stock build satisfies this:
   the latest stock builds are bootloader 7
   (`M526BXXS7CYD2` / `M526BRXXS7CYE1`, see
   [flash-stock.md](flash-stock.md)). If the phone is on older
   firmware, flash stock first.
6. The UN1CA 3.2.1 zip for m52xq on the phone or an SD card, with
   its MD5 and SHA1 checked against the build record above.

## Steps

1. TWRP installed (prereq 1), backup taken (prereq 2). The phone
   must already be on bootloader at least CVJ7.
2. Copy the UN1CA zip to the phone (or an SD card).
3. In TWRP: Wipe, Format Data, type `YES` if coming from stock or
   another ROM (encryption differs). If updating from an older
   UN1CA, a dirty flash is usually fine.
4. Install, select the UN1CA zip, flash it. Wait. It is a large
   zip; the flash takes a while.
5. Reboot, System. First boot takes several minutes. Set up, then
   leave the phone idle about 30 min for dexopt before judging
   speed or smoothness.

## Verify

- Settings shows the UN1CA version (3.2.1) and the device name
  Galaxy M52 5G.
- Settings, About phone: the One UI version. Record it here
  (TODO: it is not in the release notes).
- The display runs at 120 Hz where the HFR config allows it
  (60/120 supported rates, config.sh lines 35, 40). TODO: confirm
  the actual refresh rate behaviour on the phone after flashing.
- TODO: there is no fix pack for this device, so there are no
  fix-pack values (swappiness, thermal caps) to check. Do not
  invent any.

## Troubleshooting

- **Installer refuses with a bootloader assertion (E3003).** The
  phone is below CVJ7. Flash the stock firmware first
  ([flash-stock.md](flash-stock.md)), which is bootloader 7, then
  retry.
- **Bootloop after flashing.** Boot into TWRP, Format Data, and
  re-flash the zip. If it still bootloops, capture a log (`adb
  logcat -d`) before wiping, and report it.
- **Fingerprint enrolments are gone after flashing.** TODO:
  whether the 3.2.1 zip wipes enrolments on every flash is
  unverified (see "What the zip does"). If they are gone,
  re-enrol, and record the finding here.
- **Lag after 30 min idle.** Record the numbers (swappiness,
  thermal zones, frequencies) and report them with a log bundle.
  Do not judge speed before dexopt finishes. There is no fix pack
  for this device yet, so lag is an open item, not a fixed one.

## Going back to stock

Flash the [flash-stock.md](flash-stock.md) firmware with Odin
(AP/BL/CP/CSC), then Format Data in stock recovery. Knox stays
tripped. That cannot be undone.

## Sources

- Upstream release 3.2.1,
  https://github.com/salvogiangri/UN1CA/releases/tag/3.2.1
  (published 2026-09-29; m52xq MD5
  af5f29aa0d43f0c79489ca8d403ee2af, SHA1
  ac9ec17dd6723d67ad5894febda9c0b33f27e4a6; changelog entries for
  M52: kernel 5.4.302, Pause USB charging when gaming, improved
  speaker audio). Read live via the GitHub API 2026-11-25.
- Upstream target config,
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/m52xq/config.sh
  (48 lines; target firmware line 8, SDK 33 line 10, shipping
  API 30 line 11, super size line 14, DVFS/SSRM lines 30-31,
  fingerprint line 32, HFR lines 35, 39-41, RIL lines 46-47).
  Fetched live 2026-11-25 and verified byte-identical to the
  copy at `/tmp/upstream-cfg/m52xq-config.sh`.
- Upstream target patches,
  https://github.com/salvogiangri/UN1CA/tree/sixteen/target/m52xq/patches
  (blobs, edge_lighting, hfr, ril, sidefp, singlesim, wpss).
  Individual patch files read live via raw.githubusercontent.com.
- Upstream installer assertions,
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/m52xq/installer/assertions.edify
  (minimum bootloader M526BXXU1CVJ7 / M526BPUU1CVJ7 /
  M526BRXXU1CVJ7, E3003 message).
- Upstream debloat and floating-feature files,
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/m52xq/debloat.sh
  and
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/m52xq/sff.sh
- Upstream README,
  https://github.com/salvogiangri/UN1CA/blob/sixteen/README.md
  (based on latest stable Galaxy S22 firmware; Galaxy AI,
  KnoxPatch, Play Integrity Fix, TrickyStore, OTA app).
- XDA forum listing for the M52 5G,
  https://xdaforums.com/f/samsung-galaxy-m52-5g.12703/ (UN1CA
  3.1.0 thread titled "One UI 8.0" for the M52). Read via search
  results 2026-11-25.
