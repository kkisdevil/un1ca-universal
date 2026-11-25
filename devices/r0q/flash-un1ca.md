# Flash UN1CA - Galaxy S22 (SM-S901E)

Flash the UN1CA One UI port on the SM-S901E. This file is for
the Galaxy S22 (Snapdragon), codename `r0q`, models SM-S901E,
SM-S901N, and SM-S9010 only. Do not use it on the Exynos Galaxy
S22 (SM-S901B, codename `r0s`) or on the Galaxy S22 Ultra
(SM-S908x, codename `b0q`).

## What UN1CA is

UN1CA is a One UI port: Samsung's flagship firmware rebuilt with
extra features, in this case based on the S22's own stock firmware
(S901E) with Galaxy AI, DeX, KnoxPatch, Play Integrity Fix, and
its own OTA app. The upstream is
https://github.com/salvogiangri/UN1CA, branch `sixteen`, and the
r0q target lives at `target/r0q/` in that repo. The current
upstream release is **3.2.1** (One UI 8.0 / Android 16 base).

## Build status (honest)

- **Upstream release 3.2.1 exists for r0q.** Released 29 Sep
  (commit `9f8add9`), download links on the releases page
  (gofile.io and drive.google.com):
  https://github.com/salvogiangri/UN1CA/releases
  - MD5: `67784827bfa8ecb602e2f5f83eee5858`
  - SHA1: `6bbc8b5c72e01f42aad01e6b2c5a19e474a7ddae`
  - Source firmware per the 3.2.0 changelog:
    `S901EXXSEGZH4` (August 2026 security patches). The 3.2.1
    changelog lists no firmware change, so 3.2.1 is presumed to
    use the same source firmware. TODO: confirm the 3.2.1 zip's
    source firmware from the zip itself.
- **No build from our own porter yet.** The porter workflow
  (`.github/workflows/build.yml` in
  https://github.com/kkisdevil/un1ca-universal) builds any device
  that has a `devices/<codename>.json` manifest. No
  `devices/r0q.json` exists yet, so no porter run for r0q has
  happened. TODO: write the r0q manifest from the upstream
  `target/r0q/` files, then run the porter.
- **Not yet flashed or tested on an r0q by us.** No flash report,
  no boot test, no fix pack. Signed with the upstream's keys
  (upstream release, not our test keys).

## What the zip does (read before flashing)

TODO: read the r0q installer before flashing and fill this in.
The upstream `target/r0q/installer/` folder contains only
`assertions.edify`; the main installer is shared upstream code
we have not read for r0q. Do not assume the m51 zip behaviour
applies here. In particular, verify from the installer whether
the zip:

- flashes bootloader or modem firmware, and which versions;
- wipes fingerprint enrolments or dalvik-cache;
- touches recovery (it must not: TWRP must survive).

What is verified from `assertions.edify`: the installer **refuses
to install unless the phone is already on Android 15 firmware**.
For the S901E it requires bootloader **S901EXXUCFYDA or newer**
(bootloader C, 12); the matching minima for the other supported
models are S9010ZCU9FYDA and S9010ZHU9FYD9 (S9010), S901NKSU7FYD9
(S901N), SC51COMU1DYF2 (SC-51C), SCG13KDU1DYE8 (SCG13). Any recent
stock Android 15 or Android 16 firmware satisfies this.

## The fix pack

None exists for this device. The m51 performance fix pack
(thermal caps, blur, zram, swappiness) was built for the m51's
lag on S23 firmware. No equivalent lag report or fix pack exists
for r0q, and nothing in this file invents one.

## How the build is made

TODO: no porter build for r0q exists yet, so there is no build
record to describe. When the r0q manifest exists, the porter
resolves the device to `salvogiangri/UN1CA` branch `sixteen`
(via `devices/soc-families.json`: sm8450 family, primary upstream
`sixteen`, UN1CA 3.2.1) and builds the flashable zip on GitHub
runners. Firmware download tool and version, target pin (commit),
and OTA setup are all TODO until the first porter run.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first. A Format
   Data is needed when coming from stock or another ROM.
3. **Battery above 50%, ideally full.**
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-S901E** (or SM-S901N or
   SM-S9010).
5. The phone must already be on **Android 15 firmware or newer**
   (bootloader S901EXXUCFYDA or newer for the S901E). See
   [flash-stock.md](flash-stock.md) if it is not.
6. The UN1CA 3.2.1 zip for r0q, with its MD5 checked against the
   build status above (`67784827bfa8ecb602e2f5f83eee5858`).

## Steps

1. TWRP installed (prereq 1), backup taken (prereq 2). The phone
   must already be on Android 15 firmware or newer.
2. Copy the UN1CA zip to the phone (or an SD card).
3. In TWRP: Wipe, Format Data, type `YES` if coming from stock or
   another ROM (encryption differs). If updating from an older
   UN1CA, a dirty flash is usually fine.
4. Install, select the UN1CA zip, flash it. Wait. It is a multi-GB
   zip.
5. Reboot, System. First boot takes several minutes. Set up, then
   leave the phone idle about 30 min for dexopt before judging
   speed.
6. Check the version (see "Verify" below).

## Verify

- Settings shows the UN1CA version (3.2.1) and the device name
  Galaxy S22.
- Settings, About phone, Software information: build number
  matches the UN1CA 3.2.1 release.
- TODO: record the first real flash (booted or not, plus version
  shown and any log) here once it happens.

## Troubleshooting

- **Installer refuses with a bootloader assertion.** The phone is
  below Android 15 firmware. Flash a stock Android 15 or Android
  16 firmware first ([flash-stock.md](flash-stock.md)), then
  retry.
- **Bootloop after flashing.** Boot into TWRP, Format Data, and
  re-flash the zip. If it still bootloops, capture a log (`adb
  logcat -d`) before wiping, and report it.
- **Fingerprint enrolments are gone after flashing.** TODO:
  whether the r0q zip wipes enrolments is unverified (see "What
  the zip does"). If they are gone, re-enrol and record it here.

## Going back to stock

Flash the [flash-stock.md](flash-stock.md) firmware with Odin
(AP/BL/CP/CSC), then Format Data in stock recovery. Knox stays
tripped. That cannot be undone.

## Sources

- UN1CA 3.2.1 release, r0q MD5/SHA1, changelog:
  https://github.com/salvogiangri/UN1CA/releases (release 3.2.1,
  29 Sep, commit `9f8add9`; r0q MD5
  `67784827bfa8ecb602e2f5f83eee5858`, SHA1
  `6bbc8b5c72e01f42aad01e6b2c5a19e474a7ddae`)
- Source firmware `S901EXXSEGZH4`, August 2026 patches: 3.2.0
  changelog on the same releases page
- Target and branch: `target/r0q/config.sh` (upstream
  `salvogiangri/UN1CA`, branch `sixteen`) and
  `devices/soc-families.json` in
  https://github.com/kkisdevil/un1ca-universal (sm8450 family,
  primary upstream `sixteen`, UN1CA 3.2.1)
- Bootloader minima: `target/r0q/installer/assertions.edify`
  (upstream, branch `sixteen`): S901EXXUCFYDA (S901E),
  S9010ZCU9FYDA / S9010ZHU9FYD9 (S9010), S901NKSU7FYD9 (S901N),
  SC51COMU1DYF2, SCG13KDU1DYE8; aborts with "requires Android 15
  firmware"
- Porter build setup: `.github/workflows/build.yml` in
  https://github.com/kkisdevil/un1ca-universal (builds devices
  with a `devices/<codename>.json` manifest; no `devices/r0q.json`
  exists yet, checked 2026-11-25)
- TODO: whether the zip flashes BL/modem, wipes fingerprints, or
  touches recovery; the 3.2.1 source firmware confirmation; the
  r0q porter manifest and first porter build; the first flash
  and boot test.
