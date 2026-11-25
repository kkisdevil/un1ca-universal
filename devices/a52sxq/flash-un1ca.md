# Flash UN1CA - Galaxy A52s 5G (SM-A528B)

Flash the UN1CA One UI port on the SM-A528B. This file is for the
SM-A528B only. Do not use it on any other model. The SM-A528N
(Korean variant) is listed as supported by upstream under a
different codename (a52sxqks); do not flash an SM-A528B zip on
it.

## What UN1CA is

UN1CA is a One UI port: Samsung's flagship firmware rebuilt for
the A52s, with Galaxy AI, KnoxPatch, Play Integrity Fix, and its
own OTA app. The upstream target for this device lives at
`target/a52sxq/` in
https://github.com/salvogiangri/UN1CA (branch `sixteen`, UN1CA
3.2.1). The XDA thread for the device (3.1.0, One UI 8.0, Android
16, May 2026 security patches) lists the features as Android 16
(One UI 8.0), based on the latest stable Galaxy S22 firmware,
Galaxy AI support, high-end animations, native/live blur support,
AOD clock transition, adaptive color tone, adaptive refresh rate,
extra brightness, BluetoothLibraryPatcher, KnoxPatch, and extra
CSC features (call recording, Hiya, network speed in status bar,
AltZLife).

The target directory (listed live 2026-11-25 from the upstream
repo) contains: `camera/`, `config.sh`, `dvfs/`, `installer/`,
`overlay/`, `patches/`, `sff.sh`, `vintf/`. The patches directory
contains five patch groups: `camera`, `edge_lighting`, `hfr`,
`singlesim`, `wpss`. The `hfr` patch group is the seamless
refresh-rate feature: upstream `config.sh` lines 69-82 say to
check `target/a52sxq/patches/hfr/customize.sh` for more info.

## Build status (honest)

**No UN1CA build for the A52s has been made by this project
(un1ca-universal) yet.** There is no build number, run id,
artifact, size, or SHA-256 to record here, and nothing has been
flashed or tested on an A52s by us. The upstream project does
ship A52s builds: the XDA thread covers UN1CA 3.1.0 (04/06/2026)
and an earlier 3.0.5 thread, and the upstream releases page lists
a 3.2.1 release with A52s downloads (gofile.io and Google Drive).
TODO: pin the exact 3.2.1 A52s zip (filename, size, MD5, SHA-1)
from the upstream releases page
https://github.com/salvogiangri/UN1CA/releases and record it
here before anyone flashes. Do not flash a 3.1.0 zip on the
assumption it is 3.2.1.

What is known about 3.2.1 from the upstream releases changelog:
RKP keyboxes support, Samsung Camera OCR fix on legacy devices,
and for the A52s specifically: "Pause USB charging when gaming"
(A52s/M52) and kernel updated to 5.4.302 (A52s/A73/M52). The
3.1.0 changelog (from the releases page) records source firmware
S901EXXSEGZE3/S901BXXSNGZD7, May 2026 security patches, and
incremental updates support. TODO: confirm which source firmware
and patch level the 3.2.1 A52s zip uses; the S901 source firmware
above is from the 3.1.0 entry, not necessarily 3.2.1.

Signing keys: TODO. Upstream zips are signed by upstream; our
own porter builds (when made) need a key decision first, as on
the m51 (throwaway test keys vs real keys). Do not assume either.

## What the zip does (read before flashing)

- It requires an **Android 14 bootloader** before flashing. The
  XDA thread states this in bold: "Android 14 bootloader is
  required to avoid issues/bugs, please install it if you haven't
  done it yet." For this device that means stock firmware
  A528BXXSBGYI3 (bootloader B (11)); see
  [flash-stock.md](flash-stock.md).
- It **does not** say in the XDA thread whether the zip flashes
  bootloader or modem firmware. TODO: read the installer script
  (`target/a52sxq/installer/assertions.edify` and the main
  installer) and record what it flashes and what it asserts.
  The installer directory contains only `assertions.edify` at
  the target level; the main installer logic lives elsewhere in
  the upstream repo. The contents of `assertions.edify` could not
  be read in this session (upstream rate limit), so the minimum
  bootloader assertion is TODO.
- Fingerprint enrolments: TODO. The m51 UN1CA zip wipes them on
  every flash; whether the A52s zip does the same is not recorded
  in the XDA thread and must be checked from the installer
  script before flashing. Re-enrol the in-display fingerprint
  after flashing in any case.
- Recovery: TODO. Verify from the installer script that it does
  not touch recovery; do not assume it. The XDA thread says to
  install TWRP or OrangeFox first, which implies the zip expects
  a custom recovery to survive the flash, but that is not proof.

## The device facts that shape this build

From upstream `target/a52sxq/config.sh` (read live 2026-11-25):

- Target firmware: `SM-A528B/BTU/352599501234566` (line 13).
  No extra firmwares (line 15: `TARGET_EXTRA_FIRMWARES=()`).
- Platform SDK 34, shipping API level 30 (lines 17, 19).
- Super partition 10,643,046,400 B; QTI dynamic partitions
  10,638,852,096 B (lines 24, 26).
- Dual speakers (line 35). DVFS policy
  `dvfs_policy_sm7325_xx`, SSRM policy `siop_a52sxq_sm7325`
  (lines 57, 59).
- Fingerprint: in-display optical sensor
  `google_touch_display_optical,settings=3` (line 61). This is
  NOT a side-mounted sensor.
- Display: HFR default refresh rate 120 (line 67), HFR mode 2
  (line 75), supported rates 60,120 (line 77), seamless
  brightness 89,91 and lux 200,2500 (lines 79, 81).
- RIL: `onebinary` (line 87), single-SIM tray (line 89),
  waterproof SIM tray message (line 91).
- `target/a52sxq/sff.sh`: HFR mode 2 and extra brightness
  enabled (`SEC_FLOATING_FEATURE_LCD_SUPPORT_EXTRA_BRIGHTNESS=TRUE`).

What `config.sh` does **not** contain: there is no boot partition
size, no assert-model line, no filesystem-type line, and no
bootloader-version line in this file. Do not quote any of those
from config.sh; they are TODO from the installer script and the
partition table.

There is **no device-specific fix pack** for the A52s in this
project. The m51 lag fix pack (thermal caps, blur off, zram,
swappiness, daemon fix) is m51-specific and must not be copied
here. The A52s runs a Snapdragon 778G with a 120 Hz display and
an Android 14 vendor, a different thermal and display situation
from the m51. If lag is found on the A52s UN1CA build, measure it
first (refresh rate, thermal zones, frequencies, swappiness) and
write an A52s fix pack from those numbers. TODO: record the
first-boot measurements after the first flash.

## How the build is made

TODO: no porter build exists for this device yet. When one is
made, record here: firmware download tool and version, target pin
(upstream repo, branch `sixteen`, commit), build workflow, and
OTA system. The upstream build is made from the salvogiangri
UN1CA repo; our porter repo (un1ca-universal) has no A52s build
record to cite.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
   OrangeFox is also named as acceptable in the XDA thread.
2. **Back up everything** and back up EFS in TWRP first. The XDA
   thread recommends backing up **Boot, DTBO, Vendor Boot, and
   Super** before flashing, so you can restore the current ROM.
   A Format Data is needed when coming from stock or another ROM.
3. **Battery above 50%, ideally full.**
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A528B**. The XDA thread
   lists supported variants as SM-A528B (a52sxqxx), SM-A528B
   (a52sxqzt), and SM-A528N (a52sxqks); this guide covers the
   SM-A528B only.
5. The phone must already be on an **Android 14 bootloader**
   (stock A528BXXSBGYI3, bootloader B (11)). TODO: record the
   exact minimum bootloader assertion from
   `assertions.edify` once it is read.
6. The UN1CA zip on the phone or an SD card, with its hash
   checked against the upstream releases page. TODO: pin the
   3.2.1 zip and hashes first (see "Build status").

## Steps

1. TWRP installed (prereq 1), backup taken (prereq 2). The phone
   must already be on an Android 14 bootloader.
2. Copy the UN1CA zip to the phone (or an SD card).
3. Reboot to recovery: power off the phone, connect it to a
   computer via USB, and hold **Volume Up + Power**. (XDA thread
   wording.)
4. In TWRP: Wipe, Format Data, type `YES` if coming from stock or
   another ROM. If updating from an older UN1CA, a dirty flash is
   usually fine on Samsung ports, but this is not confirmed for
   the A52s: TODO confirm from the XDA thread or a test flash.
5. Install, select the UN1CA zip, flash it. Wait. Note the
   Droidwin A52s UN1CA guide adds a second Format Data after
   flashing the zip, before the first boot; the XDA thread does
   not. TODO: decide which order to use from a test flash and
   record it here; do not present the second format as settled.
6. Reboot, System. First boot takes several minutes. Set up, then
   leave the phone idle about 30 min for dexopt before judging
   speed.
7. Check the device facts landed (see "Verify" below).

## Verify

- `adb shell dumpsys SurfaceFlinger` should show 120.00 Hz (the
  HFR default from config line 67), not 60 Hz. This phone is a
  120 Hz device; a 60 Hz reading is a regression to record.
- Settings shows the UN1CA version (3.2.1) and the device name
  Galaxy A52s 5G.
- In-display fingerprint enrols and unlocks after re-enrolment.
- After the 30 min idle: scrolling is smooth at 120 Hz, apps stay
  in memory, and the phone does not throttle hard at normal
  temperatures. Record the numbers (refresh rate, thermal zones,
  frequencies, `adb shell cat /proc/sys/vm/swappiness`) rather
  than judging by feel.
- TODO: record the first flash result (booted or not, plus logs)
  here. No A52s UN1CA flash has been done by us.

## Troubleshooting

- **Installer refuses with a bootloader assertion.** The phone is
  below the required Android 14 bootloader. Flash the stock
  GYI3 firmware first ([flash-stock.md](flash-stock.md)), which
  is bootloader B (11), then retry. TODO: record the exact
  assertion text from `assertions.edify`.
- **Bootloop after flashing.** Boot into TWRP, Format Data, and
  re-flash the zip. If it still bootloops, capture a log
  (`adb logcat -d`) before wiping, and report it.
- **Wi-Fi does not work after flashing.** Reported in the XDA
  2.5.6 thread for a clean flash from stock One UI 6 Android 14
  with the latest TWRP. Also, an XDA downgrade tutorial warns
  "DO NOT GO FROM ANY UN1CA 3.X.X BUILDS! WIFI WON'T WORK".
  TODO: record whether Wi-Fi works on the 3.2.1 flash and what
  fixes it if not.
- **120 Hz / high FPS does not stay on in games.** Reported in
  the XDA 2.5.6 thread: the S23-style higher-FPS unlock stopped
  working in 2.5.2 while it worked in 2.5.1, with a workaround of
  flashing 2.5.1 first then dirty-flashing 2.5.2. TODO: test
  refresh rate behaviour on 3.2.1 and record it; do not assume
  the old workaround applies.
- **Fingerprint enrolments are gone after flashing.** Expected
  until proven otherwise; re-enrol. TODO: confirm whether the
  A52s zip wipes enrolments.
- **Lag is still bad after 30 min idle.** Record the numbers
  (refresh rate, thermal zones, frequencies, swappiness) and
  report them with a log bundle. Do not judge speed before
  dexopt finishes.

## Going back to stock

Flash the [flash-stock.md](flash-stock.md) firmware with Odin
(AP/BL/CP/CSC), then Format Data in stock recovery. Knox stays
tripped. That cannot be undone.

## Sources

- Upstream target listing and `config.sh` (device facts, patch
  groups, super sizes, 120 Hz, in-display fingerprint):
  https://github.com/salvogiangri/UN1CA/tree/sixteen/target/a52sxq
  and https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/a52sxq/config.sh
- Upstream patches listing (camera, edge_lighting, hfr,
  singlesim, wpss):
  https://github.com/salvogiangri/UN1CA/tree/sixteen/target/a52sxq/patches
- Upstream `sff.sh` (HFR mode 2, extra brightness):
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/a52sxq/sff.sh
- Upstream releases (3.2.1 changelog, A52s downloads):
  https://github.com/salvogiangri/UN1CA/releases
- XDA UN1CA 3.1.0 thread (Android 14 bootloader required,
  supported variants, backup list, recovery key combo, features):
  https://xdaforums.com/t/rom-16-a528b-n-un1ca-3-0-5-one-ui-8-0-for-galaxy-a52s-5g-23-12-2025.4768756/
- XDA UN1CA 2.5.6 thread (Wi-Fi report, 120 Hz game issue):
  https://xdaforums.com/t/rom-14-a528b-n-un1ca-2-5-0-one-ui-6-1-1-for-galaxy-a52s-5g-25-09-2024.4647289/page-3
- Droidwin UN1CA install steps (Format Data before and after
  flashing): https://droidwin.com/download-install-android-16-custom-roms-on-galaxy-a52s-5g/
- TODO: pin the 3.2.1 A52s zip filename, size, MD5, SHA-1, source
  firmware, and patch level. TODO: read
  `target/a52sxq/installer/assertions.edify` and record the
  bootloader assertion, what the zip flashes, and whether it
  touches recovery or wipes fingerprints. TODO: no fix pack
  exists for this device; measure first after the first flash.
  TODO: confirm dirty-flash and second-Format-Data behaviour.
