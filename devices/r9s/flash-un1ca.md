# Flash UN1CA - Galaxy S21 FE 5G (SM-G990E)

Flash the UN1CA One UI port on the SM-G990E. This file is for the
SM-G990E only (Exynos S21 FE 5G, codename r9s). Do not use it on
the Snapdragon FE (SM-G990B, SM-G990B2, SM-G990U) or any other
model. The XDA thread is explicit: SM-G990E only, not G990B.

## What UN1CA is

UN1CA is a One UI port: Samsung's flagship firmware rebuilt for
the r9s, with Galaxy AI, DeX, KnoxPatch, Play Integrity Fix, and
its own OTA app. Upstream is
https://github.com/salvogiangri/UN1CA, branch `sixteen`, UN1CA
3.2.1. The r9s target lives at `target/r9s/` in that repo
(`config.sh`, `debloat.sh`, `dvfs`, `installer`, `overlay`,
`patches`, `sff.sh`).

Per the XDA release thread, the build is Android 16 (One UI 8.0),
based on the latest stable Galaxy S22 firmware, with November
security patches (01/11/2025), Galaxy S25 wallpapers and sounds,
native/live blur, adaptive refresh rate, extra brightness, DeX,
camera privacy toggle, extra CSC features (call recording, Hiya,
network speed in status bar, AltZLife), and an integrated OTA
updates app. Full feature list and install thread:
"[ROM][16][G990E] UN1CA 3.1.0 (One UI 8.0) for Galaxy S21 FE 5G
(Exynos)",
https://xdaforums.com/t/rom-16-g990e-un1ca-3-0-6-one-ui-8-0-for-galaxy-s21-fe-5g-exynos-03-02-2026.4773337/
(The thread title shows 3.1.0 as of its last edit; upstream branch
`sixteen` is at 3.2.1 as read live 2026-11-25.)

Verified r9s facts from upstream `target/r9s/config.sh` (read live
2026-11-25):

- `TARGET_FIRMWARE="SM-G990E/THL/355798871234563"`,
  `TARGET_PLATFORM_SDK_VERSION=36`
- Super partition 11,429,478,400 B; group basic size
  11,425,284,096 B
- DVFS policy `dvfs_policy_exynos2100_xx`; SIOP
  `siop_r9s_exynos2100`
- Fingerprint: optical under-display
  (`google_touch_display_optical,settings=3`), not ultrasonic like
  the other S21 models
- HFR default 120, mode 2, rates 60 and 120 only
- eSIM false; single-SIM tray count 1; 6GHz WiFi false; MIMO
  false; MDNIE_HW false; MASS_APP_FLAVOR true; RECORDALIVE 07020;
  ESE NXP JCOP5.3T; RIL "onebinary satellite_carrier"
- `target/r9s/patches/` contains `hfr`, `raw_camera`, `vendor`
  (no camera dir, no vintf dir)

## Build status (honest)

**No UN1CA build for the r9s has been made in our repo yet.**
There is no build number, run id, duration, artifact name, size,
SHA-256, retention, or download-by date to list here. TODO: build
it in the porter and record those values here when a build exists.

Upstream releases do exist: UN1CA 3.0.5 listed a Galaxy S21 FE 5G
(Exynos) (r9s) download, and the XDA thread above posts 3.1.0
builds. Those are upstream builds, not ours, and none has been
downloaded or verified by us. TODO: download an upstream zip,
verify its hash against its release page, and record the result
here before recommending it.

Signing keys: TODO. No our-build exists, so there is nothing to
say about test keys vs real keys yet.

**Not yet flashed or tested on the r9s by us.** The flash itself
needs a phone in hand, and the bootloader base (GYI3) needs to be
in place first.

## What the zip does (read before flashing)

- The installer flashes firmware (verified from the upstream
  installer path for this device). TODO: record exactly which
  firmware images the r9s zip flashes (bootloader, modem, and
  versions) from the installer script before flashing.
- **Bootloader assertion (verbatim from
  `target/r9s/installer/assertions.edify`):** afaneh92's TWRP is
  NOT supported (the installer aborts with E3000 if it is
  installed); the bootloader must satisfy `verify_no_downgrade`
  against **G990EXXSIGYI3**, with `ro.boot.rp == "18"` exempted
  from the abort. In plain terms: the phone must already be on
  the GYI3 bootloader (level 18) or newer, and you must use
  OrangeFox (or another supported recovery), not afaneh92's TWRP.
- The XDA thread adds: **last Android 15 bootloader is required**
  to avoid issues/bugs. Install GYI3 first if the phone is not
  already on it (see [flash-stock.md](flash-stock.md)).
- TODO: does the zip wipe fingerprint enrolments or dalvik-cache
  on this device? The m51 zip does; do not assume the r9s zip
  does until the r9s installer script is read.
- TODO: does it touch recovery? Verify from the installer script;
  do not assume. (The m51 installer deletes `recovery.img` from
  the zip. That is the m51 behaviour, not a verified r9s fact.)
- The kernel comes from the UN1CA build itself (upstream kernel
  source linked in the XDA thread:
  https://github.com/xfwdrev/android_kernel_samsung_ex2100).
  See [flash-kernel.md](flash-kernel.md).

## The fix pack

TODO: no fix pack exists for the r9s. No lag analysis has been done
on this device, and no thermal, blur, zram or swappiness values
have been measured. Do not copy the m51 fix pack: it was built for
a Snapdragon 730G phone with a different vendor and different
thermal behaviour. If the r9s lags after flashing, measure first
(thermal zones, frequencies, swappiness, refresh rate) and write
the fix pack from those numbers.

## How the build is made

TODO: record the porter build for the r9s when it exists:
firmware download tool and version, target pin (repo, branch,
commit), and the OTA system for this device. Upstream builds with
its own build system (downloads and extracts firmware components,
applies patches, generates a flashable zip); the porter equivalent
for the r9s is not written yet.

## Prereqs

1. **A supported custom recovery installed**
   ([flash-twrp.md](flash-twrp.md)). Use OrangeFox, not afaneh92's
   TWRP: the installer aborts with E3000 on afaneh92's TWRP.
2. **Back up everything** and back up EFS in the recovery first.
   A Format Data is needed when coming from stock or another ROM.
   The XDA thread also advises backing up Boot, DTBO, Vendor
   Boot, and Super if you want to restore your current ROM.
3. **Battery above 50%, ideally full.**
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G990E** and the service
   provider software version must show your region (for example
   THL or INS).
5. The phone must already be on bootloader **G990EXXSIGYI3**
   (level 18, the last Android 15 bootloader). Flash it first if
   needed ([flash-stock.md](flash-stock.md)).
6. The UN1CA zip on the phone or an SD card, and its SHA-256
   checked against the build record. TODO: no zip or hash exists
   yet; do not flash a zip whose hash you have not checked.

## Steps

1. Recovery installed (prereq 1), backup taken (prereq 2). The
   phone must already be on bootloader GYI3.
2. Copy the UN1CA zip to the phone (or an SD card).
3. In the recovery: Wipe, Format Data, type `YES` if coming from
   stock or another ROM (encryption differs). If updating from an
   older UN1CA, a dirty flash is usually fine. TODO: confirm the
   dirty-flash rule for the r9s build when one exists.
4. Install, select the UN1CA zip, flash it. Wait. It is a large
   zip and it also flashes firmware.
5. Reboot, System. First boot takes several minutes. Set up, then
   leave the phone idle about 30 min for dexopt before judging
   lag or battery.
6. Check the install landed (see "Verify" below).

Recovery key combo for this device: power off, connect the USB
cable, hold Volume Up + Power (per the XDA thread).

## Verify

- Settings shows the UN1CA version (3.2.1 for the current
  upstream) and the device name Galaxy S21 FE 5G.
- The display runs at 120 Hz by default (config.sh: HFR default
  120, rates 60 and 120 only). TODO: confirm the exact check on
  the device (`dumpsys SurfaceFlinger` or the display settings).
- Fingerprint: re-enrol and test the optical under-display sensor
  separately. TODO: confirm whether the zip wipes enrolments on
  this device.
- TODO: record the first flashed build's version, settings
  strings, and any missing features here once a flash has
  happened.

## Troubleshooting

- **Installer refuses with a bootloader assertion (E3000 or a
  downgrade error).** Either afaneh92's TWRP is installed (switch
  to OrangeFox), or the phone is below GYI3. Flash the stock GYI3
  firmware first ([flash-stock.md](flash-stock.md)), then retry.
  If the phone is already on an Android 16 bootloader, you cannot
  go back to GYI3 (anti-rollback): TODO, no downgrade path was
  found in this pass.
- **Bootloop after flashing.** Boot into the recovery, Format
  Data, and re-flash the zip. If it still bootloops, capture a log
  (`adb logcat -d`) before wiping, and report it.
- **Fingerprint enrolments are gone after flashing.** TODO:
  confirm whether the r9s zip wipes them. If it does, re-enrol;
  that is expected, not a bug.
- **Lag after 30 min idle.** Record the numbers (swappiness,
  thermal zones, frequencies) and report them with a log bundle.
  Do not judge speed before dexopt finishes. There is no r9s fix
  pack yet (see above).

## Going back to stock

Flash the [flash-stock.md](flash-stock.md) firmware with Odin
(AP/BL/CP/CSC), then Format Data in stock recovery. Knox stays
tripped. That cannot be undone. Note: going back to the GYI3
Android 15 base is only possible if the phone was never taken to
a newer bootloader; an Android 16 bootloader cannot be downgraded.

## Sources

- Upstream target facts and installer assertions:
  `salvogiangri/UN1CA`, branch `sixteen`, UN1CA 3.2.1,
  `target/r9s/config.sh` and
  `target/r9s/installer/assertions.edify` (read live 2026-11-25):
  afaneh92 TWRP not supported (E3000); `verify_no_downgrade`
  against G990EXXSIGYI3; `ro.boot.rp == "18"` exempted.
- Release thread (features, supported devices, install steps,
  last Android 15 bootloader requirement, recovery key combo,
  kernel source link): "[ROM][16][G990E] UN1CA 3.1.0 (One UI 8.0)
  for Galaxy S21 FE 5G (Exynos)",
  https://xdaforums.com/t/rom-16-g990e-un1ca-3-0-6-one-ui-8-0-for-galaxy-s21-fe-5g-exynos-03-02-2026.4773337/
- Kernel source: https://github.com/xfwdrev/android_kernel_samsung_ex2100
- GYI3 base firmware record: [flash-stock.md](flash-stock.md)
  (SamFrew MYM GYI3 page; ExtremeROM wiki Build Guide for GYI3
  as the last Android 15 bootloader).
- Procedure shape (Format Data rule, dexopt wait, verify steps):
  `../m51/flash-un1ca.md` in this repo (shape only; no m51
  values, build numbers, or fix-pack contents are copied).
