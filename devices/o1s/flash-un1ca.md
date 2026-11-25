# Flash UN1CA - Galaxy S21 5G (SM-G991B)

Flash the UN1CA One UI port on the SM-G991B. This file is for the
SM-G991B only. Do not use it on any other model.

## What UN1CA is

UN1CA is a One UI port: Samsung's flagship firmware rebuilt for
the o1s, with Galaxy AI, DeX, KnoxPatch, Play Integrity Fix, and
its own OTA app. Upstream is
https://github.com/salvogiangri/UN1CA, our o1s target is the
`sixteen` branch, UN1CA 3.2.1. The XDA thread for this device is
"[ROM][16][G991B] UN1CA 3.1.0 (One UI 8.0) for Galaxy S21 5G
(Exynos) (04/06/2026)",
https://xdaforums.com/t/rom-16-g991b-un1ca-3-0-6-one-ui-8-0-for-galaxy-s21-5g-exynos-03-02-2026.4773332/
TODO: reconcile the version numbers. The porter pins 3.2.1 on
branch `sixteen`; the XDA thread title says 3.1.0, One UI 8.0,
Android 16.

Per the XDA thread, UN1CA for this device is based on the latest
stable Galaxy S22 firmware, runs Android 16 / One UI 8.0, and
includes Galaxy AI, Galaxy S25 wallpapers and sounds,
BluetoothLibraryPatcher, KnoxPatch, extra CSC features (call
recording, Hiya, network speed in status bar, AltZLife), an
integrated OTA updates app, ROM settings with customizations,
Play Integrity Fix, and unlimited Google Photos backup storage.
Supported devices: SM-G991B (o1sxxx) and SM-G991N (o1sksx).

## Build status (honest)

**No porter build exists yet for o1s.** No build number, run id,
artifact, size, hash, or retention to record. TODO: record the
first porter build here when it runs. Upstream releases do list
o1s builds (for example release 3.0.5 lists an o1s download with
MD5 `4c9c5750db7b70d2db035cc83ad7e641`), but the porter has not
built or verified one. **Not yet flashed or tested on the o1s
by us.** Do not present UN1CA on o1s as working until a flash
and a boot are recorded.

## What the zip does (read before flashing)

- **Android 15 bootloader is required** before installing (XDA
  thread). Install it first if the phone is not on it yet; see
  [flash-stock.md](flash-stock.md).
- **Bootloader assertion (verbatim from the installer):**
  afaneh92's TWRP is NOT supported (the installer aborts with
  E3000); SM-G991B requires bootloader `G991BXXSJHZC2` when
  `ro.boot.rp` is above 19; SM-G991N requires `G991NKSSCHZA9`
  when `ro.boot.rp` is above 12. Source: upstream
  `target/o1s/installer/assertions.edify`, read live 2026-11-25.
  TODO: confirm whether the AUT HZA6 build (binary 19, same
  binary as HZC2) satisfies the G991B assertion, or whether HZC2
  must be flashed first. See the firmware note in
  [flash-stock.md](flash-stock.md).
- **Recovery:** use TWRP or OrangeFox (XDA thread). Do NOT use
  afaneh92's TWRP: the installer refuses it. TODO: verify which
  exact recovery build to use on o1s.
- **Backup before flashing:** the XDA thread says to back up
  Boot, DTBO, Vendor Boot, and Super if you want to restore your
  current ROM.
- **Format data if coming from another ROM** (XDA thread).
- TODO: does the zip flash bootloader or modem firmware itself?
  Verify from the installer script; do not assume. TODO: does it
  wipe fingerprint enrolments or dalvik-cache on every flash?
  (The m51 zip does; do not copy that fact to o1s until it is
  verified here.) TODO: does it touch recovery? Verify from the
  installer script; do not assume.

## The fix pack

TODO: no fix pack exists for o1s in this repo. What lags on this
device, and what a fix pack should change (thermal caps, blur,
zram, swappiness, daemon overrides), is all unrecorded. Do not
copy the m51 fix pack: the m51 lags for m51 reasons (730G,
S23 firmware, thermal caps at 35 to 38 C). The o1s runs an
Exynos 2100 with a 120 Hz panel by default (per the upstream
config), so its behaviour will differ. TODO: measure the o1s
after the first flash, then write the fix pack from those
numbers.

## How the build is made

TODO: firmware download tool and version for this device,
target pin (repo, branch, commit), and OTA system. The upstream
target is `salvogiangri/UN1CA`, branch `sixteen`,
`target/o1s/`, UN1CA 3.2.1, with target firmware
`SM-G991B/AUT/350261971234566` and SDK 35. The porter build
recipe for o1s has not been written yet.

## Prereqs

1. **TWRP or OrangeFox installed** (NOT afaneh92's TWRP; see
   above). TODO: link the verified recovery once it is known.
2. **Back up everything** and back up EFS in TWRP first. A Format
   Data is needed when coming from stock or another ROM. Back up
   Boot, DTBO, Vendor Boot, and Super as the XDA thread advises.
3. **Battery above 50%, ideally full.**
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G991B** and the service
   provider software version must show **AUT**.
5. The phone must already be on an **Android 15 bootloader**,
   and per the installer assertion, SM-G991B needs
   `G991BXXSJHZC2` when `ro.boot.rp` is above 19.
6. The UN1CA zip on the phone (internal storage or USB OTG; the
   S21 has no SD card slot), and its hash checked against the
   build record. TODO: no zip or hash exists yet.

## Steps

1. Recovery installed (prereq 1), backup taken (prereq 2). The
   phone must already be on the Android 15 bootloader.
2. Copy the UN1CA zip to the phone (internal storage or USB OTG).
3. In recovery: Wipe, Format Data, type `YES` if coming from stock
   or another ROM. If updating from an older UN1CA, a dirty flash
   is usually fine. TODO: confirm the dirty-flash rule for o1s.
4. Install, select the UN1CA zip, flash it. Wait.
5. Reboot, System. First boot takes several minutes. Set up, then
   leave the phone idle about 30 min for dexopt before judging
   speed.
6. Check the install landed (see "Verify" below).

## Verify

- Settings shows the UN1CA version and the device name Galaxy S21.
  TODO: record the exact version string after the first flash.
- TODO: device-specific checks. The upstream config says the
  panel defaults to 120 Hz with rates 60, 48, 96, 120; check the
  refresh rate the phone actually runs at after the flash.
  The fingerprint is ultrasonic under-display; check enrolment
  works after the flash (and whether enrolments survive it).
- TODO: record swappiness, thermal behaviour, and smoothness
  numbers after the first flash, so a fix pack can be written
  from measurements instead of guesses.

## Troubleshooting

- **Installer refuses with E3000.** You are on afaneh92's TWRP.
  Switch to a supported recovery (TWRP or OrangeFox build that
  the installer accepts) and retry. TODO: name the exact build.
- **Installer refuses with a bootloader assertion.** The phone is
  below the required bootloader. Flash the Android 15 stock
  firmware first ([flash-stock.md](flash-stock.md)), aiming for
  the HZC2 bootloader the assertion names, then retry.
- **Bootloop after flashing.** Boot into recovery, Format Data,
  and re-flash the zip. If it still bootloops, capture a log
  (`adb logcat -d`) before wiping, and report it.
- **Install fails on HYK1 firmware.** One XDA thread report: a
  user on G991B build HYK1 tried all installation methods without
  success, and was told to flash the HYK1 firmware with Odin
  first. That report is unresolved in the thread; treat it as a
  warning, not a verified fix. TODO: confirm the correct base
  firmware for the current UN1CA version.
- **Fingerprint enrolments are gone after flashing.** TODO:
  verify whether the o1s zip wipes them (the m51 zip does; do
  not assume the same here).

## Going back to stock

Flash the [flash-stock.md](flash-stock.md) firmware with Odin
(AP/BL/CP/CSC), then Format Data in stock recovery. Knox stays
tripped. That cannot be undone.

## Sources

- Target, branch, version, target firmware, SDK, HFR, eSIM,
  fingerprint: upstream `salvogiangri/UN1CA` branch `sixteen`,
  `target/o1s/config.sh`, read live 2026-11-25.
- Bootloader assertion and afaneh92 TWRP refusal (E3000):
  upstream `target/o1s/installer/assertions.edify`, read live
  2026-11-25.
- Features, supported models, Android 15 bootloader requirement,
  recovery choice, backup list, format-data rule, HYK1 user
  report: XDA thread "[ROM][16][G991B] UN1CA 3.1.0 (One UI 8.0)
  for Galaxy S21 5G (Exynos) (04/06/2026)",
  https://xdaforums.com/t/rom-16-g991b-un1ca-3-0-6-one-ui-8-0-for-galaxy-s21-5g-exynos-03-02-2026.4773332/
- Upstream release 3.0.5 o1s MD5:
  https://github.com/salvogiangri/UN1CA/releases/tag/3.0.5
- No SD card slot on the S21: XDA BeyondROM thread,
  https://xdaforums.com/t/rom-beyondrom-v7-5-25-10-2024-gxh7-exynos-sm-g99xb.4254933/page-20
