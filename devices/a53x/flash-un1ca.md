# Flash UN1CA - Galaxy A53 5G (SM-A536B)

Flash the UN1CA One UI port on the SM-A536B. This file is for the
SM-A536B only. Do not use it on any other model.

## What UN1CA is on this device

UN1CA is a One UI port: Samsung's flagship firmware rebuilt for
the a53x, with Galaxy AI, DeX, KnoxPatch, Play Integrity Fix, and
its own OTA app. The target exists in the upstream repo:
`target/a53x/` on branch `sixteen` of
https://github.com/salvogiangri/UN1CA, UN1CA **3.2.1**. Our
builds, when they exist, live in the sister repo
https://github.com/kkisdevil/un1ca-universal (the universal
porter: one manifest plus resolver, per-device targets; upstream
is https://github.com/salvogiangri/UN1CA).

The build for this device is based on the Galaxy S22 Exynos
donor firmware: `unica/configs/essi.sh` on branch `sixteen` sets
the source firmware to `SM-S901B/EUX` (Galaxy S22 Exynos, One UI
8.0, SDK 36). The target firmware is `SM-A536B/EUX`
(`target/a53x/config.sh` line 11). Both sides are Exynos and both
are EUX, so the donor and the target match on SoC family class
and region.

## Build status (honest)

**No build has been run for this device in our repo yet.** There
is no `devices/a53x.json` manifest and no workflow run, artifact,
or SHA-256 to quote. The upstream target exists and is readable,
but nothing has been built from it by us, and nothing has been
flashed or tested on an a53x. Do not go looking for a download
link: there is not one yet.

A previous, unrelated UN1CA port for this phone existed on XDA:
"[EOL][ROM][14][SM-A536B/E][UNOFFICIAL] UN1CA 2.5.6 (One UI
6.1.1) for Galaxy A53", now closed and end of life. It is not
the sixteen/3.2.1 build described here and must not be confused
with it.

TODO: run the first a53x build (add `devices/a53x.json`, run the
porter workflow), then fill in the build number, run id,
duration, artifact name, size, SHA-256, retention, and
download-by date here. Signing keys are also TODO: no decision
has been recorded for this device.

## What the zip does (read before flashing)

Read from the upstream installer scripts
(`target/a53x/installer/` on branch `sixteen`):

- It flashes Samsung bootloader and modem firmware for your
  variant. For the EUX variant (our SM-A536B), the installer
  carries BL and CP `A536BXXSHFYI1` and flashes them when the
  phone is not already on that bootloader: `modem.bin` to the
  radio partition, `vbmeta.img` to vbmeta, and the bootloader
  blobs (fld, harx, keystorage, ldfw, sboot, tzar, tzsw, uh,
  up_param) to the bota partition. Source:
  `target/a53x/installer/customize.sh` lines 16-20 and
  `target/a53x/installer/install-end.edify` lines 110-158.
- It fetches a DTBO from the UN1CA `kernel_samsung_s5e8825`
  releases, but only the Japanese variants get the `dtbo_jpn.img`
  flashed (SC53C/SCG15 bootloader check). The A536B path in the
  edify file does not flash a DTBO.
- It patches the vbmeta image byte at offset 123 during install
  (verification disable), per `customize.sh` lines 160-168.
- TODO: whether the zip wipes fingerprint enrolments or
  dalvik-cache on this device has not been verified from the
  installer. Do not copy the m51 answer.
- TODO: whether the installer refuses a phone on a newer
  bootloader has not been verified. The installer targets FYI1
  firmware while current stock is far newer (bootloader binary
  24, GZI3). A phone already on a newer bootloader needs a check
  before flashing: read the installer assert (if any) and test
  on a spare flash before using the zip on a daily phone.
- TODO: whether the zip touches recovery has not been verified
  from the main installer script for this device. Do not assume
  the m51 "installer deletes recovery.img" rule applies here.
  Verify it from the built zip before flashing.

## The fix pack

TODO: no fix pack exists for this device. Nothing is known yet
about what lags on the a53x under the S22 firmware, and no
thermal, blur, zram, or swappiness values have been measured or
set for this phone. Do not copy the m51 fix pack: the m51 lags
for Snapdragon 730G reasons, and the a53x is a different SoC
(Exynos 1280) with a different thermal and DVFS setup (the
target uses `dvfs_policy_s5e8825_xx` and `siop_a53x_s5e8825`).
Measure first, then write the pack.

## How the build is made

The porter workflow (same shape as the m51 build) downloads the
two stock firmwares (S22 Exynos source, a53x target), extracts
them, applies the a53x target
(salvogiangri/UN1CA branch `sixteen`) and any patches, then
builds the flashable zip. Firmware download uses samloader (the
m51 build pins samloader-rs v2.0.0; the pin for an a53x run is
TODO). The a53x target carries its own patch set:
`target/a53x/patches/` holds blobs, bluetooth, camera,
edge_lighting, hfr, kernel, raw_camera, singlesim, stock_props,
tweaks, variants, and vendor, plus `target/a53x/dvfs/`,
`target/a53x/camera/`, `target/a53x/overlay/values/`,
`debloat.sh`, and `sff.sh`. The display runs 60/120 Hz with HFR
mode 2 (`TARGET_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE="60,120"`
in config.sh). The OTA system for this device is TODO: no OTA
manifest exists for a53x yet.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first. A Format
   Data is needed when coming from stock or another ROM.
3. **Battery above 50%, ideally full.**
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A536B** and the service
   provider software version must show **EUX**.
5. TODO: minimum bootloader version for this device. The
   installer targets FYI1; whether a phone must already be on
   FYI1 or newer, and what happens on a newer bootloader, is
   unverified (see above).
6. The UN1CA zip on the phone or an SD card, and its SHA-256
   checked against the build record. TODO: no zip exists yet.

## Steps

1. TWRP installed (prereq 1), backup taken (prereq 2). The phone
   must meet the bootloader condition in prereq 5 once it is
   known.
2. Copy the UN1CA zip to the phone (or an SD card).
3. In TWRP: Wipe, Format Data, type `YES` if coming from stock or
   another ROM (encryption differs). If updating from an older
   UN1CA, a dirty flash is usually fine. TODO: whether the zip
   wipes dalvik itself on this device is unverified.
4. Install, select the UN1CA zip, flash it. Wait. It is a large
   zip and it also flashes the BL and modem.
5. Reboot, System. First boot takes several minutes. Set up, then
   leave the phone idle about 30 min for dexopt before judging
   lag.
6. Check the lag fix landed (see "Verify" below) once a fix pack
   exists.

## Verify

- Settings shows the UN1CA version (3.2.1) and the device name
  Galaxy A53 5G.
- TODO: fix-pack checks (effective swappiness value, refresh
  rate, thermal behaviour) cannot be written until the fix pack
  exists and its values are measured on this phone.
- TODO: confirm the bootloader and modem versions after the flash
  (Settings, About phone, Software information) against the FYI1
  versions the installer carries.

## Troubleshooting

- **Installer refuses with a bootloader assertion.** TODO: the
  exact assertion for this device is unverified. If it refuses,
  read the exact message, check the bootloader version on the
  phone against FYI1, and report it before retrying.
- **Bootloop after flashing.** Boot into TWRP, Format Data, and
  re-flash the zip. If it still bootloops, capture a log (`adb
  logcat -d`) before wiping, and report it.
- **Fix values wrong at runtime.** TODO: no fix pack exists yet,
  so there is nothing to check against. Once one exists, check
  the effective values (never the props) and name the daemon
  that overrides them on this device.
- **Fingerprint enrolments gone after flashing.** TODO:
  unverified for this device. If they are gone, re-enrol and
  record it here.

## Going back to stock

Flash the [flash-stock.md](flash-stock.md) firmware with Odin
(AP/BL/CP/CSC), then Format Data in stock recovery. Knox stays
tripped. That cannot be undone.

## Sources

- Target exists on branch `sixteen`, UN1CA 3.2.1; target
  firmware `SM-A536B/EUX`; partitions; DVFS filenames;
  60/120 Hz HFR: `target/a53x/config.sh` in
  salvogiangri/UN1CA branch `sixteen`
  (https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/a53x/config.sh).
- Source firmware S22 Exynos `SM-S901B/EUX`, One UI 8.0, SDK 36:
  `unica/configs/essi.sh` in the same repo and branch
  (https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/unica/configs/essi.sh).
- Installer flashes FYI1 BL/CP for EUX, patches vbmeta, fetches
  DTBO from `UN1CA/kernel_samsung_s5e8825`:
  `target/a53x/installer/customize.sh`
  (https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/a53x/installer/customize.sh).
- Per-variant flash blocks, A536B FYI1 block, Japanese DTBO
  only: `target/a53x/installer/install-end.edify`
  (https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/a53x/installer/install-end.edify).
- Target file list (camera, dvfs, installer, overlay/values,
  patches, config.sh, debloat.sh, sff.sh) and patch list:
  https://github.com/salvogiangri/UN1CA/tree/sixteen/target/a53x
  and https://github.com/salvogiangri/UN1CA/tree/sixteen/target/a53x/patches
- No `devices/a53x.json` and no a53x workflow run: checked in
  this repo (`~/workspace/un1ca-universal/`) on 2026-11-25.
- Older EOL UN1CA 2.5.6 port for this phone (closed):
  XDA forum listing for the Galaxy A53 5G,
  https://xdaforums.com/f/samsung-galaxy-a53-5g.12575/?prefix_id=33
