# Flash UN1CA - Galaxy S21+ 5G (SM-G996B)

Flash the UN1CA One UI port on the SM-G996B. This file is for the
SM-G996B only. Do not use it on any other model.

## What UN1CA is

UN1CA is a One UI port: Samsung's flagship firmware rebuilt for
the target device, with its own settings and OTA app. A UN1CA
target exists for this device: `target/t2s` in
https://github.com/salvogiangri/UN1CA, branch `sixteen`, UN1CA
**3.2.1**. The target firmware is
`SM-G996B/AUT/355399273736683`, platform SDK version 35
(Android 15).

Verified target facts from `target/t2s/config.sh` (read live
2026-11-25):

- Super partition 11,429,478,400 B; group basic 11,425,284,096 B.
- DVFS policy `dvfs_policy_exynos2100_xx`; SIOP
  `siop_t2s_exynos2100`.
- Fingerprint: `google_touch_display_ultrasonic` (ultrasonic
  under-display).
- HFR default 120, mode 2, rates 60, 48, 96, 120.
- eSIM true; dual-SIM tray count 2; 6GHz WiFi false; MIMO true.
- ESE NXP JCOP5.4U.
- RIL "onebinary embms_expway satellite_carrier".
- `target/t2s/` contains: camera, config.sh, debloat.sh, dvfs,
  installer, overlay, patches, sff.sh, vintf. `patches/` contains
  raw_camera and variants.

TODO: what the UN1CA build for this device is based on. The
source (donor) firmware version is not in the config facts
above; do not guess it. The upstream README describes UN1CA
generally as based on the latest stable Galaxy S22 firmware, but
the exact source firmware for the sixteen branch t2s build is
TODO until the build record or `unica/config.sh` is read.

## Build status (honest)

**No UN1CA build for t2s exists in this repo yet.** There is no
build number, run id, duration, artifact name, size, SHA-256,
retention, or download-by date to record. All of those are TODO
until the porter builds t2s for the first time.

- Signing keys: TODO. Do not assume test keys or real keys.
- **Not yet flashed or tested on a t2s.** Say so plainly. The
  flash itself needs the phone in hand, and no flash report
  exists.

Upstream does publish t2s builds: the UN1CA releases page lists
Galaxy S21+ 5G (Exynos) (t2s) downloads (goFile and Google Drive
links). TODO: check the latest upstream release for t2s, record
its version, and decide whether this repo builds its own t2s zip
or documents the upstream one. Do not link a goFile or Drive URL
here until it has been checked.

## What the zip does (read before flashing)

TODO: most of this section is unverified for t2s. Do not copy the
m51 claims (DXJ2 bootloader/modem flash, fingerprint wipe,
dalvik wipe, DXE3 assertion, recovery.img deletion). Each one
must be read from the t2s installer script first.

What is verified, from `target/t2s/installer/assertions.edify`
(verbatim, supplied with this task):

- afaneh92's TWRP is **NOT supported** and aborts with E3000.
  That means the TWRP in flash-twrp.md (afaneh92's build) is the
  one the installer rejects. TODO: find which recovery the
  installer does accept for t2s, and update flash-twrp.md when
  that is known. Until then, do not flash UN1CA with afaneh92's
  TWRP: the installer will refuse.
- SM-G996B requires bootloader **G996BXXSJHZC2** when
  `ro.boot.rp` is above 19.
- SM-G996N requires bootloader **G996NKSSCHZA9** when
  `ro.boot.rp` is above 12.

TODO: does the zip flash bootloader or modem firmware for this
device, and which versions? Read the installer script.
TODO: does it wipe fingerprint enrolments or dalvik-cache?
TODO: does it touch recovery? Verify from the installer script;
do not assume it deletes `recovery.img` the way the m51
installer does.

## The fix pack

There is **no fix pack for t2s**. Do not copy the m51 lag fix
pack (thermal caps, blur, zram, swappiness, daemon overrides):
the m51 lags because S23 firmware runs on a Snapdragon 730G,
and none of those causes or values applies to an Exynos 2100
phone with a 120 Hz display. What lags on t2s, if anything, is
TODO until a t2s build is flashed and measured. The user's rule
from the m51 work (keep all flagship features, remove blur
effects only) has not been restated for t2s; do not assume it
applies here.

## How the build is made

TODO: firmware download tool and version for t2s, target pin
(repo, branch, commit), and OTA system for t2s. The porter
itself (un1ca-universal) is the build route; no t2s build has
been run in it yet, so there is nothing to record.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)). Note the
   conflict: the UN1CA installer rejects afaneh92's TWRP (see
   above). TODO: resolve which recovery to use before flashing.
2. **Back up everything** and back up EFS in TWRP first. A Format
   Data is needed when coming from stock or another ROM.
3. **Battery above 50%, ideally full.**
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G996B** (or SM-G996B/DS).
5. The phone must already be on bootloader **G996BXXSJHZC2** if
   its rollback protection value is above 19 (see the assertion
   above). If it is below that, flash the stock HZC2 firmware
   first ([flash-stock.md](flash-stock.md)).
6. The UN1CA zip on the phone or an SD card, and its SHA-256
   checked against the build record. TODO: no zip or hash exists
   yet.

## Steps

TODO: these steps are the standard UN1CA install shape, not yet
run for t2s. Confirm each one against the first t2s build and
record the result.

1. TWRP installed (prereq 1), backup taken (prereq 2). The phone
   must already meet the bootloader assertion in prereq 5.
2. Copy the UN1CA zip to the phone (or an SD card).
3. In TWRP: Wipe, Format Data, type `YES` if coming from stock or
   another ROM (encryption differs). If updating from an older
   UN1CA, a dirty flash is usually fine. TODO: confirm whether
   the t2s zip wipes dalvik itself.
4. Install, select the UN1CA zip, flash it. Wait.
5. Reboot, System. First boot takes several minutes. Set up, then
   leave the phone idle about 30 min for dexopt before judging
   performance.
6. Check the install landed (see "Verify" below).

## Verify

- Settings shows the UN1CA version (3.2.1) and the device name
  Galaxy S21+ 5G.
- TODO: refresh rate check. The config sets HFR default 120 with
  rates 60, 48, 96, 120, so check `adb shell dumpsys
  SurfaceFlinger` for the active rate, but do not state a
  specific expected value until a real t2s build has been
  measured.
- TODO: swappiness, thermal behaviour, and any other fix-pack
  checks. There is no t2s fix pack, so there are no values to
  check yet.
- TODO: fingerprint enrolment check after flashing (whether the
  zip wipes enrolments is unverified for t2s).

## Troubleshooting

- **Installer refuses with a bootloader assertion.** The phone
  is below G996BXXSJHZC2 while its rollback protection value is
  above 19. Flash the stock HZC2 firmware first
  ([flash-stock.md](flash-stock.md)), then retry.
- **Installer aborts with E3000.** You are using afaneh92's
  TWRP, which the installer does not support. Find the recovery
  the installer accepts (TODO) and use that instead.
- **Bootloop after flashing.** Boot into TWRP, Format Data, and
  re-flash the zip. If it still bootloops, capture a log (`adb
  logcat -d`) before wiping, and report it.
- **Fingerprint enrolments are gone after flashing.** TODO:
  whether the t2s zip wipes them is unverified. If they are
  gone, re-enrol, and record that the zip does wipe them.
- **Performance is bad after 30 min idle.** Record the numbers
  (swappiness, thermal zones, frequencies, refresh rate) and
  report them with a log bundle. Do not judge speed before
  dexopt finishes.

## Going back to stock

Flash the [flash-stock.md](flash-stock.md) firmware with Odin
(AP/BL/CP/CSC), then Format Data in stock recovery. Knox stays
tripped. That cannot be undone.

## Sources

- Upstream UN1CA `target/t2s/config.sh` (salvogiangri/UN1CA,
  branch sixteen, UN1CA 3.2.1): TARGET_FIRMWARE
  SM-G996B/AUT/355399273736683, TARGET_PLATFORM_SDK_VERSION 35,
  super sizes, DVFS/SIOP, fingerprint, HFR, eSIM, dual-SIM,
  6GHz/MIMO, ESE, RIL, target folder contents. Read live
  2026-11-25.
- Upstream UN1CA `target/t2s/installer/assertions.edify`
  (verbatim, supplied with this task): afaneh92's TWRP not
  supported (E3000); SM-G996B bootloader G996BXXSJHZC2 when
  ro.boot.rp above 19; SM-G996N bootloader G996NKSSCHZA9 when
  ro.boot.rp above 12.
- Upstream UN1CA repo: https://github.com/salvogiangri/UN1CA
  (t2s listed in the releases page as Galaxy S21+ 5G (Exynos)
  (t2s)).
- Guide structure: [../m51/flash-un1ca.md](../m51/flash-un1ca.md)
  (shape only; no m51 build facts, fix-pack values, or
  assertions were copied).

## TODO

- First t2s build in this repo: build number, run id, artifact,
  size, SHA-256, retention, signing keys.
- Source (donor) firmware version for the sixteen branch t2s
  build.
- Which recovery the installer accepts (afaneh92's TWRP is
  rejected with E3000).
- Whether the zip flashes bootloader/modem, wipes fingerprints
  or dalvik, or touches recovery (read the installer script).
- Whether a t2s fix pack is needed, and what lags on t2s.
- Latest upstream t2s release version and download links.
- Verify steps and verify checks on a real flashed phone.
