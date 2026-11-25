# Flash UN1CA - Galaxy S21 Ultra 5G (SM-G998B)

Flash the UN1CA One UI port on the SM-G998B. This file is for the
SM-G998B only. Do not use it on any other model. The Korean
SM-G998N shares the codename p3s and has its own assertion in the
installer (see below), but this file is written for the G998B.

## What UN1CA is

UN1CA is a One UI port: Samsung's flagship firmware rebuilt for
the p3s, with Galaxy AI, DeX, KnoxPatch, Play Integrity Fix, and
its own OTA app. Upstream is
https://github.com/salvogiangri/UN1CA, branch `sixteen`, and the
p3s target is `target/p3s/` in that repo. Our porter repo is the
universal porter (one manifest plus resolver, per-device targets);
no p3s build has been run in our porter yet (see "Build status").

The upstream target for this device, read live on 2026-11-25:

- `TARGET_NAME="Galaxy S21 Ultra 5G (Exynos)"`, codename `p3s`,
  platform `exynos2100`, SDK version 35 (Android 15).
- `TARGET_FIRMWARE="SM-G998B/AUT/350635581234563"`: the target
  firmware is the AUT (Switzerland) SM-G998B build.
- Super partition 11,744,051,200 B, group basic 11,739,856,896 B.
- Fingerprint sensor `google_touch_display_ultrasonic`
  (ultrasonic under-display). HFR default 120, mode 3, rates
  60, 48, 96, 120. eSIM true, dual-SIM tray count 2, 6 GHz WiFi
  true, MIMO true. DVFS policy `dvfs_policy_exynos2100_xx`, SIOP
  `siop_p3s_exynos2100`.
- `target/p3s/` contains: camera, config.sh, dvfs, installer,
  overlay, patches, sff.sh, vintf. There is no `debloat.sh` in
  the p3s target. The patches folder contains camera, raw_camera
  and variants.

## Build status (honest)

**Upstream release: UN1CA 3.2.1 is the latest upstream release**
(released 29 Sep, commit `9f8add9`). For p3s the release page
lists gofile.io and drive.google.com downloads with MD5
`8044baa950e75064a0f31cd9cbf29ee5` and SHA1
`316d53cbc943e0f3690e544eef6d0c46a9996f4b`. Changelog for 3.2.1:
RKP keyboxes support, Samsung Camera OCR fix on legacy devices,
minor adjustments and fixes, plus device-specific items for other
models. No p3s-specific changelog line is listed for 3.2.1. The
previous release, 3.2.0, lists two p3s-specific fixes: "(S21
Ultra) Fixed camera issues" and "(S21 Ultra) Fixed Extra
brightness feature", with source firmware
S901EXXSEGZH4/S901BXXSOGZH3 (Galaxy S22) and August security
patches. The 3.1.0 changelog lists for the S21 series: Korean
variant support, LED cover fixes, RAW support for all cameras,
and "(S21 Ultra) Fixed Screen resolution settings issues".

**Our porter build: none yet.** No UN1CA build for p3s has been
run in our un1ca-universal repo, so there is no build number, run
id, duration, artifact name, size, SHA-256, retention, or
download-by date to record here. TODO: run the porter build for
p3s and record all of those here. Signing keys: TODO. The
upstream release zip's signing is not described on the release
page; do not claim test keys or real keys until verified.

**Not yet flashed or tested on the p3s by us.** The upstream
release exists and is downloadable, but no flash or test on a
p3s in front of us has happened. Do not present UN1CA on p3s as
working until a flash is done and recorded here.

## What the zip does (read before flashing)

Verified from the upstream installer, read live 2026-11-25
(`target/p3s/installer/assertions.edify`):

- **afaneh92's TWRP is NOT supported.** The installer aborts with
  `E3000: This package does not support afaneh92's recovery`
  if it detects it. Do not flash UN1CA from afaneh92's TWRP. See
  TODO below for which recovery to use instead.
- **Bootloader assertion for SM-G998B:** if the rollback
  protection counter (`ro.boot.rp`) is greater than 19, the phone
  must already be on bootloader `G998BXXSJHZC2`, or the installer
  aborts with E3003. In practice: be on the HZC2 firmware first
  (see [flash-stock.md](flash-stock.md)). If the counter is 19 or
  lower, the assertion does not fire, but being on HZC2 is still
  the safe base.
- **Bootloader assertion for SM-G998N:** if rp is greater than
  12, the phone must be on `G998NKSSCHZA9`, or the installer
  aborts with E3003. G998N only; do not apply this string to a
  G998B.

TODO, not verified from the installer files read so far:

- TODO: does the zip flash bootloader or modem firmware for this
  device? Which versions? The assertions only check the
  bootloader; they do not say the zip flashes one.
- TODO: does it wipe fingerprint enrolments or dalvik-cache on
  every flash? Not verified for p3s. Do not copy the m51 answer.
- TODO: does it touch recovery? The m51 installer deletes
  `recovery.img` from the zip. Whether the p3s installer does the
  same is TODO: check the p3s installer script and record it.
- TODO: which recovery does UN1CA 3.2.1 for p3s require? The
  E3000 abort rules out afaneh92's TWRP. The S21 (o1s) UN1CA XDA
  thread says "Download and install a custom recovery
  (TWRP/OrangeFox)", but that is the o1s thread, not p3s. TODO:
  find the p3s UN1CA thread or the upstream install guide and
  record the exact recovery here before flashing.

## The fix pack

There is **no p3s fix pack** in this repo. The m51 lag fix pack
(thermal caps, blur off, zram, swappiness, daemon fix) is
m51-specific and does not apply here. The p3s is an Exynos 2100
flagship running its own stock Android 15 base, not an S23
firmware port on a 730G. TODO: if lag or thermal issues are found
on the p3s UN1CA build once it is flashed, define a p3s fix pack
here from measured numbers. Do not invent one in advance.

What is kept and what is removed, by the user's rule for the m51
(keep all flagship features, remove blur effects only), has not
been stated for p3s. TODO: confirm whether that rule applies to
p3s before changing anything.

## How the build is made

TODO: the porter build for p3s has not been run, so none of this
is recorded yet.

- TODO: firmware download tool and version for p3s.
- TODO: target pin (repo, branch, commit) for the p3s porter
  build. Upstream is salvogiangri/UN1CA branch `sixteen`; the
  commit pinned for the build is TODO.
- TODO: OTA system for p3s, if one exists. Upstream UN1CA ships
  its own Updates app with incremental updates support (added in
  3.1.0). Whether the p3s build uses it, and where its manifest
  lives, is TODO.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)). Note the
   E3000 conflict above: the recovery you flash UN1CA from must
   NOT be afaneh92's TWRP. Until the TODO in "What the zip does"
   is resolved, do not flash UN1CA from the recovery in
   [flash-twrp.md](flash-twrp.md).
2. **Back up everything** and back up EFS in TWRP first. A Format
   Data is needed when coming from stock or another ROM.
3. **Battery above 50%, ideally full.**
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G998B** and the service
   provider software version must show your region code.
5. The phone must already be on bootloader **G998BXXSJHZC2**
   (flash [flash-stock.md](flash-stock.md) first if it is not).
   This satisfies the installer assertion for any rp value.
6. The UN1CA zip on the phone or an SD card, and its MD5 checked
   against the build record. For upstream 3.2.1 p3s the MD5 is
   `8044baa950e75064a0f31cd9cbf29ee5` (SHA1
   `316d53cbc943e0f3690e544eef6d0c46a9996f4b`). For a future porter
   build, check against that build's own record instead. TODO:
   record the zip file name and size for 3.2.1 p3s; the release
   page lists only the MD5 and SHA1, not the file name or size.

## Steps

1. TWRP installed (prereq 1), backup taken (prereq 2). The phone
   must already be on bootloader G998BXXSJHZC2.
2. Copy the UN1CA zip to the phone (or an SD card).
3. In TWRP: Wipe, Format Data, type `YES` if coming from stock or
   another ROM (encryption differs). If updating from an older
   UN1CA, a dirty flash is usually fine on Samsung ports, but
   this is TODO for p3s: confirm the dirty-flash rule from the
   p3s UN1CA thread before relying on it.
4. Install, select the UN1CA zip, flash it. Wait. It is a large
   zip; do not interrupt it.
5. Reboot, System. First boot takes several minutes. Set up, then
   leave the phone idle about 30 min for dexopt before judging
   speed or lag.
6. Check the version in Settings (see "Verify" below).

## Verify

- Settings shows the UN1CA version (3.2.1 for the upstream
  release) and the device name Galaxy S21 Ultra 5G.
- `adb shell dumpsys SurfaceFlinger` should show the refresh
  rate. The upstream config sets HFR default 120 with rates 60,
  48, 96, 120, so a 120 Hz reading is expected on this device,
  unlike the m51 where the build rewrites 120 to 60. TODO: confirm
  the actual reading after the first flash.
- Camera, extra brightness, and screen resolution settings: these
  are the three items the 3.2.0 and 3.1.0 changelogs say were
  fixed for the S21 Ultra. Check each one after flashing and
  record pass or fail here.
- TODO: swappiness, thermal behaviour, and any other fix-pack
  checks. None exist for p3s yet, so no values are asserted here.

## Troubleshooting

- **Installer refuses with E3000.** You are in afaneh92's TWRP.
  Use the recovery UN1CA requires (TODO above) and retry.
- **Installer refuses with E3003.** The phone is not on
  G998BXXSJHZC2 (or G998NKSSCHZA9 for a G998N) and the rollback
  protection counter is above the threshold. Flash the stock
  HZC2 firmware first ([flash-stock.md](flash-stock.md)), then
  retry.
- **Bootloop after flashing.** Boot into TWRP, Format Data, and
  re-flash the zip. If it still bootloops, capture a log (`adb
  logcat -d`) before wiping, and report it.
- **Fingerprint enrolments gone after flashing.** TODO: not
  verified for p3s. Record whether it happens on the first flash
  and update this line.
- **Lag after 30 min idle.** Record the numbers (swappiness,
  thermal zones, frequencies) and report them with a log bundle.
  Do not judge speed before dexopt finishes.

## Going back to stock

Flash the [flash-stock.md](flash-stock.md) firmware with Odin
(AP/BL/CP/CSC), then Format Data in stock recovery. Knox stays
tripped. That cannot be undone.

## TODO

- TODO: porter build for p3s (run id, artifact, size, SHA-256,
  retention, signing keys).
- TODO: which recovery UN1CA 3.2.1 for p3s requires (E3000 rules
  out afaneh92's TWRP).
- TODO: does the zip flash BL/modem, wipe fingerprints or
  dalvik-cache, touch recovery.
- TODO: zip file name and size for upstream 3.2.1 p3s.
- TODO: dirty-flash rule for updating from an older UN1CA on p3s.
- TODO: source firmware for 3.2.1 (the 3.2.1 changelog lists no
  source firmware update; the 3.2.0 source was
  S901EXXSEGZH4/S901BXXSOGZH3).
- TODO: first flash and test on a real p3s, with the verify checks
  above recorded.

## Sources

- Upstream target config: salvogiangri/UN1CA branch `sixteen`,
  `target/p3s/config.sh`, read live 2026-11-25.
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/p3s/config.sh
- Installer assertions (E3000, E3003, G998BXXSJHZC2, rp over 19,
  G998NKSSCHZA9, rp over 12): salvogiangri/UN1CA branch
  `sixteen`, `target/p3s/installer/assertions.edify`, read live
  2026-11-25.
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/p3s/installer/assertions.edify
- Upstream releases (3.2.1 latest, commit 9f8add9, p3s MD5
  8044baa950e75064a0f31cd9cbf29ee5, SHA1
  316d53cbc943e0f3690e544eef6d0c46a9996f4b; 3.2.0 p3s fixes and
  source firmware; 3.1.0 S21 series fixes):
  https://github.com/salvogiangri/UN1CA/releases
- Target folder contents (camera, config.sh, dvfs, installer,
  overlay, patches, sff.sh, vintf; patches contain camera,
  raw_camera, variants; no debloat.sh): task handoff, verified
  against the upstream repo listing.
- S21 UN1CA install shape (custom recovery TWRP/OrangeFox, Android
  15 bootloader required): XDA o1s thread, "[ROM][16][G991B]
  UN1CA 3.1.0 (One UI 8.0) for Galaxy S21 5G (Exynos)
  (04/06/2026)",
  https://xdaforums.com/t/rom-16-g991b-un1ca-3-0-6-one-ui-8-0-for-galaxy-s21-5g-exynos-03-02-2026.4773332/
  (o1s thread, not p3s; used only for the general shape).

## Next step

Flash the stock ROM back if needed: [flash-stock.md](flash-stock.md).
