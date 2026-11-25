# Flash UN1CA - Galaxy A73 5G (SM-A736B)

Flash the UN1CA One UI port on the SM-A736B. This file is for the
SM-A736B only. Do not use it on any other model.

## What UN1CA is

UN1CA is a One UI port: Samsung's flagship firmware rebuilt for
the a73xq, with Galaxy AI, DeX, KnoxPatch, Play Integrity Fix,
and its own OTA app. A UN1CA target **does** exist for this phone
in the primary upstream: `target/a73xq/` in
https://github.com/salvogiangri/UN1CA, branch `sixteen`, UN1CA
3.2.1. The target config is
https://github.com/salvogiangri/UN1CA/blob/sixteen/target/a73xq/config.sh

UN1CA 3.x is the final major release of the project: it stays on
Android 16 / One UI 8.0 and receives only security patches, bug
fixes, and smaller improvements, with no further Android or One
UI version jumps planned. The 3.x base is the Galaxy S22
firmware. For this phone specifically, the upstream changelog
notes "(A73) Added enhanced camera config (@ngdplnk)".

What the target config pins for this phone:

- `TARGET_NAME="Galaxy A73 5G"`, `TARGET_CODENAME="a73xq"`,
  `TARGET_PLATFORM="sm7325"` (config.sh lines 7, 9, 11).
- `TARGET_FIRMWARE="SM-A736B/XME/352828291234563"` (line 13):
  the target firmware is the XME (Malaysia) SM-A736B build.
- `TARGET_PLATFORM_SDK_VERSION=36` (line 17): Android 16.
  `TARGET_PRODUCT_SHIPPING_API_LEVEL=31` (line 19).
- No extra firmwares: `TARGET_EXTRA_FIRMWARES=()` (line 15).
- Super partition `12113149952` B, QTI dynamic partitions
  `12108955648` B (lines 24, 26).
- Dual speaker on, in-display optical fingerprint
  (`google_touch_display_optical`, line 59), default refresh rate
  120, supported rates 60,120 with seamless refresh rate mode 2
  (lines 65, 73, 75), single-SIM tray count 1 (line 87).
- The target directory also holds `camera/`, `dvfs/`,
  `installer/`, `overlay/`, `patches/`, and `sff.sh` (GitHub API
  listing of `target/a73xq/`, 2026-11-25). The `sff.sh` enables
  the HDR video brightness effect, seamless refresh rate mode 2,
  and extra brightness. One patch is named in the config itself:
  `target/a73xq/patches/hfr/customize.sh`, the seamless refresh
  rate patch (config.sh lines 67 to 71).

## Build status (honest)

**No build has been made or tested in this project.** There is no
un1ca-universal build number, run id, artifact, size, SHA-256, or
retention date for the a73xq, and nothing has been flashed or
tested on an a73xq here. Upstream does publish UN1CA 3.2.1 builds
for the a73xq (download links via gofile.io and Google Drive are
listed in the DroidWin UN1CA article), but no upstream zip has
been downloaded, hash-checked, or flashed in this project.

Signing keys for any build made here are TODO: no decision
between test keys and real keys has been recorded for this phone.

## What the zip does (read before flashing)

The points below are the standard UN1CA installer behaviour as
documented for other devices, applied to this phone only where
the target files support them. Do not treat them as verified for
the a73xq until the installer in `target/a73xq/installer/` has
been read and the zip has been inspected.

- The zip is expected to flash the donor bootloader and modem
  firmware for this phone. Which versions: TODO, read from the
  installer and the zip before flashing.
- Fingerprint enrolments: the a73xq fingerprint is in-display
  optical, and UN1CA zips for other devices wipe fingerprint
  enrolments on every flash. Assume enrolments are lost and
  re-enrol afterwards, until the a73xq installer is read.
- Bootloader assertion (minimum version): TODO, read from the
  installer script. The current stock firmware for this phone is
  bootloader C (12); do not flash a UN1CA build that asserts a
  newer bootloader than the phone has, and do not assume the
  assertion matches another device's value.
- Recovery: the installer must not touch recovery. TODO, verify
  from the a73xq installer script; do not assume.

## The fix pack

**No fix pack exists for this phone in this project.** There is
no recorded lag diagnosis for the a73xq (no thermal-cap, blur,
zram, or swappiness measurements), and no user rule about what to
keep or remove has been recorded for this phone. Do not copy the
m51 fix pack: the m51 lags because S23 firmware runs on a 730G
with a 60 Hz panel, while the a73xq runs on a Snapdragon 778G
with a 120 Hz panel and a different thermal and DVFS setup
(`dvfs_policy_sm7325_xx`, `siop_a73xq_sm7325` in config.sh lines
55 and 57). If lag is found on the a73xq, diagnose it on this
phone first and write a pack from those numbers.

## How the build is made

- The build for this family is resolved from
  `devices/soc-families.json`: sm7325, primary upstream
  salvogiangri/UN1CA, branch `sixteen`, UN1CA 3.2.1. The source
  (donor) firmware for the family is not recorded there; read it
  from `unica/configs/qssi.sh` (or `essi.sh`) of
  salvogiangri/UN1CA@sixteen before building.
- Target pin: TODO, record the exact upstream commit used for
  the first build. The config file read for this guide is from
  the `sixteen` branch as fetched on 2026-11-25.
- Firmware download tool and version: TODO, record at first
  build time.
- OTA system: TODO, none exists for this phone in this project.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first. A Format
   Data is needed when coming from stock or another ROM.
3. **Battery above 50%, ideally full.**
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A736B** and the service
   provider software version must show your region code.
5. The phone must already be on the minimum bootloader version
   the zip asserts (TODO, see above).
6. The UN1CA zip on the phone or an SD card, and its SHA-256
   checked against the build record. No build record exists yet.

## Steps

1. TWRP installed (prereq 1), backup taken (prereq 2). The phone
   must already be on the minimum bootloader version.
2. Copy the UN1CA zip to the phone (or an SD card).
3. In TWRP: Wipe, Format Data, type `YES` if coming from stock or
   another ROM (encryption differs). If updating from an older
   UN1CA, a dirty flash is usually fine. The zip wipes dalvik
   itself (standard UN1CA behaviour; confirm for this build from
   the installer).
4. Install, select the UN1CA zip, flash it. Wait. It is a large
   zip and it also flashes the BL and modem.
5. Reboot, System. First boot takes several minutes. Set up, then
   leave the phone idle about 30 min for dexopt before judging
   lag.
6. Check the refresh rate and fingerprint (see "Verify" below).

## Verify

- `adb shell dumpsys SurfaceFlinger` should show 120.00 Hz at
  the top refresh rate on this phone (the panel is 120 Hz; the
  config sets the default to 120). Do **not** expect 60 Hz: 60
  is the low end of the supported 60,120 range, not the default.
- Settings shows the UN1CA version (3.2.1) and the device name
  Galaxy A73 5G.
- Re-enrol the in-display fingerprint and check it unlocks the
  phone.
- After the 30 min idle: scrolling is smooth, apps stay in memory
  instead of being killed, and the phone does not throttle
  unusually. Record the numbers (swappiness, thermal zones,
  frequencies) rather than judging by feel.

## Troubleshooting

- **Installer refuses with a bootloader assertion.** The phone is
  below the asserted version. Flash the stock firmware first
  ([flash-stock.md](flash-stock.md)), then retry. Record the
  asserted version here when it is read from the installer.
- **Bootloop after flashing.** Boot into TWRP, Format Data, and
  re-flash the zip. If it still bootloops, capture a log (`adb
  logcat -d`) before wiping, and report it.
- **Fingerprint enrolments are gone after flashing.** Expected
  on UN1CA builds generally. Re-enrol.
- **Lag is still bad after 30 min idle.** Record the numbers
  (swappiness, thermal zones, frequencies) and report them with a
  log bundle. Do not judge speed before dexopt finishes. Do not
  apply the m51 fix pack to this phone.

## Going back to stock

Flash the [flash-stock.md](flash-stock.md) firmware with Odin
(AP/BL/CP/CSC), then Format Data in stock recovery. Knox stays
tripped. That cannot be undone.

## Sources

- Upstream target config (all config.sh line citations above):
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/a73xq/config.sh
- Upstream target directory listing (camera, dvfs, installer,
  overlay, patches, sff.sh): GitHub API,
  https://api.github.com/repos/salvogiangri/UN1CA/contents/target/a73xq?ref=sixteen
  (fetched 2026-11-25).
- `target/a73xq/sff.sh` (HDR effect, HFR mode 2, extra
  brightness):
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/a73xq/sff.sh
- UN1CA 3.2.1 / One UI 8 for the a73xq, A73 camera config note,
  download links:
  https://droidwin.com/un1ca-one-ui-8-android-16-rom-for-samsung/
- UN1CA FAQ (3.x is the final major release, stays on Android
  16 / One UI 8.0):
  https://github.com/salvogiangri/UN1CA/discussions/629
- SoC family resolution: `devices/soc-families.json`, sm7325
  entry (salvogiangri/UN1CA, `sixteen`, 3.2.1).

## TODO

- TODO: no un1ca-universal build exists for this phone; no run
  id, artifact, size, SHA-256, or retention date.
- TODO: read `target/a73xq/installer/` and record the bootloader
  assertion, the BL/modem versions the zip flashes, whether it
  wipes fingerprint enrolments and dalvik-cache, and whether it
  touches recovery.
- TODO: record the exact upstream commit pinned for the first
  build, the firmware download tool and version, and the signing
  keys decision.
- TODO: the full `target/a73xq/patches/` listing could not be
  retrieved in this session (the GitHub API request for the
  patches directory was rejected with 403). Only the hfr patch
  named in config.sh is recorded here. Re-list the directory
  before writing the patch section in full.
- TODO: no fix pack, no lag diagnosis, and no OTA system exist
  for this phone.
