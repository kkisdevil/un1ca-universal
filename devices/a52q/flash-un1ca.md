# Flash UN1CA - Galaxy A52 (SM-A525F)

Flash the UN1CA One UI port on the SM-A525F. This file is for the
SM-A525F only. Do not use it on any other model.

## What UN1CA is

UN1CA is a One UI port: Samsung's flagship firmware rebuilt for
the a52q, with Galaxy AI, DeX, KnoxPatch, Play Integrity Fix, and
its own OTA app. The target exists in the upstream repo
(https://github.com/salvogiangri/UN1CA, branch `sixteen`, target
`target/a52q/`) and in our porter
(https://github.com/kkisdevil/un1ca-universal).

The upstream README on the `sixteen` branch describes the base as
the latest stable Galaxy S22 firmware, EROFS powered, with Galaxy
AI support. The older XDA releases for this device (UN1CA 2.5.0,
One UI 6.1.1) were instead based on the Galaxy S23 firmware
`S911BXXS6CXHA`. The donor firmware for the 3.2.1 a52q build is
TODO: confirm it from the build log or the release notes before
stating it here. Do not assume the S23 donor carries over.

The upstream target for the a52q pins the target firmware to
`SM-A525F/EUX/352938771234569`, SDK 34 (Android 14), super
partition 10,385,096,704 bytes, an in-display optical fingerprint
sensor, a 90 Hz default refresh rate (60 and 90 supported), and
dual speakers.

## Build status (honest)

**No porter build exists yet for the a52q.** There is no build
number, no run id, no artifact, and no SHA-256 from our porter.
Everything below about flashing describes the upstream release
and the procedure to run, not a build of ours.

**Upstream release 3.2.1 exists** (published 2026-09-29). The
release page lists a Galaxy A52 (a52q) download:

- https://gofile.io/d/phgptdHz
- https://drive.google.com/file/d/1IvyFAw3cXxOcKSlsPNzMehQ2A0mAoRX4/view?usp=sharing
- MD5: `fbda6643423a72f7309bde4ef9c1a475`
- SHA1: `85d26c1087d779eaa7b89c34f2b2a827abd9830a`

Changelog highlights for 3.2.1: added RKP keyboxes support, fixed
Samsung Camera OCR on legacy devices, minor adjustments and fixes.
**Not yet flashed or tested on an a52q by us.** The upstream
release is a published build, not a build we verified. Check the
MD5 above before flashing, and record the flash result here.

Note: the XDA thread for UN1CA on the A52 4G and A72 4G covers
versions up to 2.5.x and is marked EOL. The 3.2.1 release above is
newer than that thread. Do not treat the XDA thread as the current
release record.

## What the zip does (read before flashing)

Verified from the upstream installer assertions
(`target/a52q/installer/assertions.edify`, read live):

- It asserts the model is **SM-A525F** and the bootloader is
  **A525FXXU6EWL3 or newer**. If the phone is below that, the
  installer aborts with `E3003: This package requires Android 14
  firmware.` (The same file asserts SM-A525M needs
  A525MUBU6EXB2 or newer, but this folder is SM-A525F only.)
- The practical requirement is therefore: **Android 14 firmware
  with bootloader A525FXXU6EWL3 or newer** before flashing. The
  stock firmware in [flash-stock.md](flash-stock.md) (FYF1,
  bootloader bit C) satisfies this. The XDA thread says the same
  thing in plain words: Android 14 bootloader is required.

TODO, not verified from the installer script: whether the 3.2.1
zip flashes bootloader or modem firmware itself; whether it wipes
fingerprint enrolments (the fingerprint sensor is in-display
optical, so re-enrolment after flashing is likely but unconfirmed);
whether it touches recovery (it must not). Verify all three from
the installer script inside the 3.2.1 zip before flashing, and
record the answers here. Do not copy the m51 answers: the m51 zip
flashed DXJ2 bootloader and modem and wiped fingerprints, but
that is a different target.

The XDA thread for the older releases advises backing up **Boot,
DTBO, and Super** before flashing, in case you want to restore
your current ROM. Do that in TWRP before installing.

## The fix pack

**None exists for the a52q.** No lag research has been done on
this device, and no thermal, blur, zram, or swappiness values have
been measured or changed. The a52q runs a 90 Hz display by default
(target config), and the user rule from the m51 project (keep all
flagship features, remove blur effects only) has not been applied
or tested here. TODO: measure the stock behaviour on the a52q
first (does it lag, does it throttle, what is the effective
swappiness), then decide whether a fix pack is needed at all.

## How the build is made

TODO: no porter build exists for the a52q, so there is no build
record yet. When the first porter build runs, record here: the
firmware download tool and version, the target pin (repo, branch,
commit), the workflow run id, the artifact name and size, the
SHA-256, and the retention and download-by date. The upstream
build system (per its README) downloads and extracts firmware
components, applies the required patches, and generates a
flashable zip. The upstream target directory for the a52q holds
`config.sh`, `sff.sh` (extra brightness feature), `installer/`
(assertions), `camera/` (camera feature flags), `dvfs/` (DVFS
policy), `overlay/`, and `vintf/` (compatibility matrix). There is
no separate patch list file in the target directory.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first. A Format
   Data is needed when coming from stock or another ROM. Back up
   Boot, DTBO, and Super too (see above).
3. **Battery above 50%, ideally full.**
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A525F** and the service
   provider software version must show **EUX**.
5. The phone must already be on Android 14 firmware with
   bootloader **A525FXXU6EWL3 or newer** (any recent stock build
   qualifies; the FYF1 stock firmware in
   [flash-stock.md](flash-stock.md) is bootloader bit C).
6. The UN1CA zip on the phone or an SD card, with its MD5 checked
   against the build record above (`fbda6643423a72f7309bde4ef9c1a475`
   for upstream 3.2.1).

## Steps

1. TWRP installed (prereq 1), backup taken (prereq 2). The phone
   must already be on bootloader A525FXXU6EWL3 or newer.
2. Copy the UN1CA zip to the phone (or an SD card).
3. In TWRP: Wipe, Format Data, type `YES` if coming from stock or
   another ROM (encryption differs). If updating from an older
   UN1CA, a dirty flash is usually fine.
4. Install, select the UN1CA zip, flash it. Wait. It is a large
   zip; do not interrupt it.
5. Reboot, System. First boot takes several minutes. Set up, then
   leave the phone idle about 30 min for dexopt before judging
   speed.
6. Check the install landed (see "Verify" below).

## Verify

- Settings shows the UN1CA version (3.2.1) and the device name
  Galaxy A52.
- `adb shell dumpsys SurfaceFlinger` should show the refresh rate
  the display is actually running at (90 Hz default per the
  target config).
- TODO: the a52q-specific checks have not been defined yet, because
  there is no fix pack. Once the first flash is done, record here
  what was checked (Wi-Fi, calls, data, camera, in-display
  fingerprint enrolment, brightness) and what the results were.

## Troubleshooting

- **Installer refuses with a bootloader assertion (E3003).** The
  phone is below A525FXXU6EWL3 or not on Android 14 firmware.
  Flash the stock Android 14 firmware first
  ([flash-stock.md](flash-stock.md)), then retry.
- **Bootloop after flashing.** Boot into TWRP, Format Data, and
  re-flash the zip. If it still bootloops, capture a log (`adb
  logcat -d`) before wiping, and report it.
- **Fingerprint enrolments are gone after flashing.** Expected
  until proven otherwise (TODO: confirm). Re-enrol. The sensor is
  in-display optical.
- **Lag after the first boot.** Do not judge speed before dexopt
  finishes (about 30 min idle). If it is still slow after that,
  record the numbers and report them with a log bundle. There is
  no a52q fix pack to check against yet.

## Going back to stock

Flash the [flash-stock.md](flash-stock.md) firmware with Odin
(AP/BL/CP/CSC), then Format Data in stock recovery. Knox stays
tripped. That cannot be undone.

## Sources

- Upstream target, `target/a52q/config.sh` in
  salvogiangri/UN1CA branch `sixteen`: lines 5-8 (name, codename,
  platform, firmware EUX), line 10 (SDK 34), line 13 (super
  10,385,096,704), line 19 (dual speaker), lines 31 and 34-36
  (in-display optical fingerprint, 90 Hz default, 60/90
  supported):
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/a52q/config.sh
- Upstream installer assertions,
  `target/a52q/installer/assertions.edify` in the same repo and
  branch (model SM-A525F, bootloader A525FXXU6EWL3 minimum,
  E3003 Android 14 message):
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/a52q/installer/assertions.edify
- Upstream target directory listing (config.sh, sff.sh, camera/,
  dvfs/, installer/, overlay/, vintf/; no separate patch list):
  https://github.com/salvogiangri/UN1CA/tree/sixteen/target/a52q
- Upstream release 3.2.1 (published 2026-09-29, a52q download
  links, MD5, SHA1, changelog): release tag `3.2.1` in
  https://github.com/salvogiangri/UN1CA
- Upstream README (`sixteen` branch): base described as the latest
  stable Galaxy S22 firmware, EROFS powered, Galaxy AI, DeX,
  KnoxPatch, Play Integrity Fix, OTA app.
- XDA thread [EOL][ROM][14][A525F/M][A725F/M][OTA] UN1CA 2.5.0
  (One UI 6.1.1) for Galaxy A52 4G and A72 4G (S23 donor firmware
  S911BXXS6CXHA, Android 14 bootloader required, backup Boot /
  DTBO / Super, recovery key combination, Ascendia kernel):
  https://xdaforums.com/t/eol-rom-14-a525f-m-a725f-m-un1ca-1-1-6-one-ui-6-for-galaxy-a52-4g-a72-4g-12-01-2024.4650551/
- TODO: donor firmware for the 3.2.1 a52q build; whether the zip
  flashes bootloader/modem; whether it wipes fingerprints; whether
  it touches recovery; porter build record (none exists yet);
  a52q fix pack (none exists yet); first-flash verification
  results.
