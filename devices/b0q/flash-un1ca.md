# Flash UN1CA - Galaxy S22 Ultra (SM-S908E)

Flash the UN1CA One UI port on the Galaxy S22 Ultra (Snapdragon),
codename `b0q`. This file is for the SM-S908E, SM-S908N, and
SM-S9080 only. Do not use it on any other model.

## What UN1CA is on this device

A UN1CA target **exists** for this device: `target/b0q/` on the
`sixteen` branch of https://github.com/salvogiangri/UN1CA, UN1CA
version 3.2.1. The target is the Galaxy S22 Ultra (Snapdragon),
platform `sm8450`, SDK 36 (Android 16), shipping API level 31.
The donor firmware named in the target is `SM-S908E/TUR` (the
upstream config string carries a device serial after the
model/region; that suffix is part of the upstream string, not a
value to reuse).

The target's own files:

- `config.sh`: super partition 12,058,624,000 B; QTI dynamic
  partitions 12,054,429,696 B; DVFS policy file
  `dvfs_policy_sm8450_xx` and SSRM policy file `siop_b0q_sm8450`;
  fingerprint sensor `google_touch_display_ultrasonic`; display
  default refresh rate 120 Hz, supported rates
  24,10,60,48,30,96,120.
- `debloat.sh`: removes `system/app/WifiRROverlayAppLls` and
  `overlay/SoftapOverlayQC`.
- `installer/assertions.edify`: the installer refuses the package
  unless the phone is on Android 15 firmware. For the S908E it
  requires bootloader at least `S908EXXUCFYDA` (other supported
  bootloader prefixes: S9080ZC, S9080ZH, S908NKS, SC52C, SCG14).
- `dvfs/`, `overlay/`, `patches/`: present in the target. TODO:
  the patches directory listing could not be retrieved during
  research (GitHub API returned 403), so the patch list is not
  recorded here yet.

UN1CA itself is a One UI port: Samsung's flagship firmware rebuilt
for the target, with Galaxy AI, DeX, KnoxPatch, Play Integrity
Fix, and its own OTA app (the standard UN1CA feature set; the
b0q-specific feature list is TODO until a build is inspected).

## Build status (honest)

**No UN1CA build has been run for the b0q in this porter repo
yet, and nothing has been flashed or tested on a b0q.** The
b0q family is `listed` in `../soc-families.json` (mapping verified
from the upstream `target/` table, family defaults not yet used
in a build). There is no build number, run id, artifact, size, or
SHA-256 to record. The sections below are the procedure to run
once a build exists; the build record fields are TODO until then.

- Latest build: TODO (none).
- Artifact: TODO (none).
- Signing keys: TODO (test keys or real keys is an open decision
  for this project; nothing is decided for the b0q).
- Flashed or tested on device: no.

## What the zip does (read before flashing)

TODO: verify each item against the built zip's installer script
once a build exists. Do not assume.

- TODO: does the zip flash bootloader or modem firmware for this
  device? Which versions?
- TODO: does it wipe fingerprint enrolments or dalvik-cache?
- Bootloader assertion: the phone must already be on Android 15
  firmware, with bootloader at least `S908EXXUCFYDA` for the
  S908E (from `installer/assertions.edify`). Flash the stock
  firmware first ([flash-stock.md](flash-stock.md)) if the phone
  is below that.
- TODO: does it touch recovery? (It must not. Verify from the
  installer script, do not assume.)

## The fix pack (none exists for this device)

There is no b0q fix pack. Nothing is known yet about what lags
on this device under UN1CA, because no build has been flashed.
TODO: record the lag causes and the fix pack changes (thermal
caps, blur, zram, swappiness, daemon overrides) only after a
build is tested on the phone. Do not copy the m51 fix pack: the
m51 lags for m51 reasons (730G, 60 Hz panel, Android 12 vendor)
that do not apply to this phone.

## How the build is made

The porter repo builds from the SoC family, not from a hardcoded
target: `scripts/resolve-device.py` reads the device's JSON,
finds its SoC family in `../soc-families.json`, and the workflow
builds from that family's primary upstream. For the b0q the family
is `sm8450`, primary upstream `salvogiangri/UN1CA` branch
`sixteen`, UN1CA 3.2.1. TODO: record the firmware download tool
and version, the target pin (repo, branch, commit), and the OTA
system for the b0q once the first build runs. The family note in
`soc-families.json` says to read the source firmware from
`unica/configs/qssi.sh` (or `essi.sh`) of
`salvogiangri/UN1CA@sixteen` before using this family in a build.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first. A Format
   Data is needed when coming from stock or another ROM.
3. **Battery above 50%, ideally full.**
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-S908E**, **SM-S908N**, or
   **SM-S9080**.
5. The phone must already be on Android 15 firmware with
   bootloader at least `S908EXXUCFYDA` (S908E).
6. The UN1CA zip on the phone or an SD card, and its SHA-256
   checked against the build record. TODO: no zip exists yet.

## Steps

1. TWRP installed (prereq 1), backup taken (prereq 2). The phone
   must already meet the bootloader assertion (prereq 5).
2. Copy the UN1CA zip to the phone (or an SD card).
3. In TWRP: Wipe, Format Data, type `YES` if coming from stock or
   another ROM (encryption differs). If updating from an older
   UN1CA, a dirty flash is usually fine.
4. Install, select the UN1CA zip, flash it. Wait.
5. Reboot, System. First boot takes several minutes. Set up, then
   leave the phone idle about 30 min for dexopt before judging
   lag.
6. Check the fix pack landed (see "Verify" below) once a fix pack
   exists.

## Verify

- Settings shows the UN1CA version (3.2.1) and the device name
  Galaxy S22 Ultra.
- The display runs at 120 Hz by default (upstream config:
  `TARGET_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE="120"`).
- TODO: the checks that prove a fix pack landed on this device,
  once a fix pack exists (effective swappiness value, refresh
  rate, thermal behaviour).

## Troubleshooting

- **Installer refuses with a bootloader assertion.** The phone is
  below the required firmware. Flash the stock firmware first
  ([flash-stock.md](flash-stock.md)): the current INS build
  `S908EXXSEGZH4` is Android 16 with bootloader E (14), which is
  above the `S908EXXUCFYDA` minimum. Then retry.
- **Bootloop after flashing.** Boot into TWRP, Format Data, and
  re-flash the zip. If it still bootloops, capture a log
  (`adb logcat -d`) before wiping, and report it.
- **Fix values wrong at runtime.** TODO: no fix pack exists yet,
  so there is no daemon to name.
- **Fingerprint enrolments gone after flashing.** TODO: confirm
  whether the zip wipes them; re-enrol if so.

## Going back to stock

Flash the [flash-stock.md](flash-stock.md) firmware with Odin
(AP/BL/CP/CSC), then Format Data in stock recovery. Knox stays
tripped. That cannot be undone.

## Sources

- Target identity, platform, SDK, super sizes, DVFS filenames,
  fingerprint sensor, refresh rates:
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/b0q/config.sh
- Debloat list:
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/b0q/debloat.sh
- Bootloader assertion (S908EXXUCFYDA minimum, Android 15
  firmware required):
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/b0q/installer/assertions.edify
- Target directory listing (config.sh, debloat.sh, dvfs/,
  installer/, overlay/, patches/):
  GitHub Contents API for `target/b0q` on branch `sixteen`,
  read 2026-11-25.
- Family mapping (sm8450, primary upstream sixteen, UN1CA
  3.2.1, status listed): `../soc-families.json`.
- Build record, zip behaviour, fix pack, OTA system: TODO, no
  build has run yet.
- Patches directory listing: TODO, GitHub API returned 403
  during research.
