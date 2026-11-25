# Flash UN1CA - Galaxy S22+ (Snapdragon) (SM-S906E)

Flash the UN1CA One UI port on the Snapdragon Galaxy S22+ (g0q).
This file is for **SM-S906E, SM-S906N, SM-S9060** only. Do not use
it on any other model. SM-S906B is the Exynos model (g0s) and
nothing here applies to it.

## What UN1CA is

UN1CA is a One UI port: Samsung's flagship firmware rebuilt for
the target device. A UN1CA target exists for g0q in the upstream
repo: https://github.com/salvogiangri/UN1CA, branch `sixteen`,
target `target/g0q/`, UN1CA **3.2.1**. The build for g0q is based
on the Galaxy S22 (Snapdragon) One UI 8.0 source firmware (see
"How the build is made" below), applied to the g0q target
firmware.

## Build status (honest)

**No build has been produced by our porter yet.** There is no
build number, no run id, no artifact, no size, and no SHA-256 to
record. Nothing has been flashed or tested on a g0q phone. The
sections below describe the upstream target as it stands, so the
build can be made and the file can be completed once it exists.

## What the target is (from upstream, verified live)

- Target config:
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/g0q/config.sh
  - Device: Galaxy S22+ (Snapdragon), codename `g0q`, platform
    `sm8450` (lines 5, 7, 9, 11).
  - Target firmware: `SM-S906E/TUR/350037921234561` (line 13).
  - Platform SDK 36, shipping API 31 (lines 17, 19).
  - Super partition 12,058,624,000 B; QTI dynamic partitions
    12,054,429,696 B (lines 24, 26).
  - DVFS policy file `dvfs_policy_sm8450_xx`; SSRM policy file
    `siop_g0q_sm8450` (lines 57, 59).
  - Fingerprint sensor `google_touch_display_ultrasonic`
    (line 61).
  - Display: default refresh rate 120, supported rates
    24,10,30,48,60,96,120 (lines 67, 71).
- Target files in
  https://github.com/salvogiangri/UN1CA/tree/sixteen/target/g0q:
  `config.sh`, `debloat.sh`, `dvfs/siop_model.xml`,
  `installer/assertions.edify`, and an `overlay/` directory.
- Debloat list (`debloat.sh`): removes
  `system/app/WifiRROverlayAppLls` and
  `overlay/SoftapOverlayQC`.

## Bootloader assertion (from the installer, verified live)

`target/g0q/installer/assertions.edify` requires Android 15
firmware, with these minimum bootloaders per model:

| Model prefix | Minimum bootloader |
|---|---|
| `S9060ZC` | `S9060ZCU9FYDA` |
| `S9060ZH` | `S9060ZHU9FYD9` |
| `S906EXX` | `S906EXXUCFYDA` |
| `S906NKS` | `S906NKSU7FYD9` |

There is **no assertion for S906U** (US models). US models cannot
unlock the bootloader anyway (see
[unlock-bootloader.md](unlock-bootloader.md)). For SM-S906E, the
phone must already be on bootloader `S906EXXUCFYDA` or newer,
which is the Android 15 build from April 2025. Any phone on the
current Android 16 builds (for example GZH4, bootloader binary E
(14)) is past that minimum.

## What the zip does

TODO. Only the assertions file was read. Whether the zip flashes
bootloader or modem firmware, wipes fingerprint enrolments or
dalvik-cache, or touches recovery has not been verified from the
upstream installer script. Do not assume any of it. Verify from
the installer before writing this section.

## The fix pack

TODO. No lag analysis has been done for g0q and no fix pack
exists for this device. Do not copy another device's fix pack
(thermal caps, blur, zram, swappiness) here.

## How the build is made

- Source firmware (donor): `SM-S901E/TUR` (Galaxy S22
  Snapdragon, One UI 8.0), from
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/unica/configs/qssi.sh
  line 10 (`SOURCE_FIRMWARE="SM-S901E/TUR/350999641234561"`),
  SDK 36.
- Target: upstream `salvogiangri/UN1CA` branch `sixteen`,
  `target/g0q/`, UN1CA 3.2.1.
- TODO: the porter workflow for g0q in this repo (firmware
  download tool and version, target pin commit, signing keys,
  OTA system). No g0q workflow exists in un1ca-universal yet.
  Do not assume the m51 workflow applies unchanged.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
   **Blocked today**: no working TWRP exists for g0q.
2. **Back up everything** and back up EFS in TWRP first. A Format
   Data is needed when coming from stock or another ROM.
3. **Battery above 50%, ideally full.**
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-S906E** (or SM-S906N, or
   SM-S9060).
5. The phone must already be on the minimum bootloader in the
   table above (for SM-S906E: `S906EXXUCFYDA` or newer).
6. The UN1CA zip on the phone or an SD card, and its SHA-256
   checked against the build record. TODO: no zip exists yet.

## Steps

Blocked until a build and a working TWRP exist. The steps, once
both are available:

1. TWRP installed (prereq 1), backup taken (prereq 2). The phone
   must already be on the minimum bootloader.
2. Copy the UN1CA zip to the phone (or an SD card).
3. In TWRP: Wipe, Format Data, type `YES` if coming from stock or
   another ROM (encryption differs). If updating from an older
   UN1CA, a dirty flash is usually fine.
4. Install, select the UN1CA zip, flash it. Wait.
5. Reboot, System. First boot takes several minutes. Set up, then
   leave the phone idle about 30 min for dexopt before judging
   speed.
6. Check the version in Settings (UN1CA 3.2.1) and the device
   name Galaxy S22+.

## Verify

- Settings shows the UN1CA version (3.2.1) and the device name
  Galaxy S22+.
- TODO: device-specific checks once a build exists (refresh rate
  behaviour, fingerprint enrolments, thermal behaviour). No
  fix-pack values exist to check yet.

## Troubleshooting

- **Installer refuses with a bootloader assertion.** The phone is
  below the minimum in the table above. Flash the stock firmware
  first ([flash-stock.md](flash-stock.md)), which is bootloader
  binary E (14) on the current build, then retry.
- **Bootloop after flashing.** Boot into TWRP, Format Data, and
  re-flash the zip. If it still bootloops, capture a log
  (`adb logcat -d`) before wiping, and report it.
- **Fingerprint enrolments are gone after flashing.** TODO:
  verify whether the g0q zip wipes them. Do not assume it does.

## Going back to stock

Flash the [flash-stock.md](flash-stock.md) firmware with Odin
(AP/BL/CP/CSC), then Format Data in stock recovery. Knox stays
tripped. That cannot be undone.

## Sources

- Target config (device, codename, platform, target firmware,
  SDK, super sizes, DVFS filenames, fingerprint sensor, display
  rates):
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/g0q/config.sh
- Target file list:
  https://github.com/salvogiangri/UN1CA/tree/sixteen/target/g0q
- Debloat list:
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/g0q/debloat.sh
- Bootloader assertions:
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/g0q/installer/assertions.edify
- Source firmware SM-S901E/TUR, One UI 8.0, SDK 36:
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/unica/configs/qssi.sh
  lines 8, 10, 14.
- UN1CA 3.2.1 on branch sixteen and the g0q family mapping:
  `devices/soc-families.json` in this repo (sm8450 family).
- Current stock bootloader binary E (14) for SM-S906E:
  [flash-stock.md](flash-stock.md).

## TODO

- Produce the first g0q build in the porter and record its build
  number, run id, artifact name, size, SHA-256, retention, and
  signing keys.
- Read the upstream installer script and fill in "What the zip
  does" (BL/modem flash, fingerprint wipe, recovery behaviour).
- Flash and test the build on a g0q phone.
- Decide whether g0q needs a fix pack at all, and if so, what it
  changes.
- Record the porter workflow (firmware download tool, target pin,
  OTA system) for g0q.
