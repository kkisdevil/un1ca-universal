# Flash UN1CA - Galaxy S20 FE (Snapdragon) (SM-G780G)

Flash the UN1CA One UI port on the SM-G780G. This file is for the
SM-G780G only. Do not use it on any other model, including the
Exynos S20 FE (SM-G780F).

## What UN1CA is

UN1CA is a One UI port: Samsung's flagship firmware (Galaxy S22
base, One UI 8.0 / Android 16) rebuilt for the r8q, with Galaxy AI,
DeX, KnoxPatch, Play Integrity Fix, and its own OTA app. Upstream
is https://github.com/salvogiangri/UN1CA, branch `sixteen`, UN1CA
3.2.1. Our porter repo is
https://github.com/kkisdevil/un1ca-universal. The r8q target lives
at
https://github.com/salvogiangri/UN1CA/tree/sixteen/target/r8q.

UN1CA 3.x is the final major release of the project: it stays on
Android 16 / One UI 8.0 and receives only security patches, bug
fixes and smaller improvements. No further Android or One UI
version jumps are planned.

The build for this phone is based on two firmwares: the Galaxy S22
source firmware (the One UI 8 system) and the SM-G780G target
firmware, `SM-G780G/BTU` (the stock vendor, bootloader and modem
side). The target runs on an Android 13 vendor: the target config
sets `TARGET_PLATFORM_SDK_VERSION=33`, shipping API level 29 and
board API level 30.

## Build status (honest)

**No porter build exists yet.** The porter workflow
(`.github/workflows/build.yml`) builds m51 only; there is no r8q
entry anywhere in the porter repo. No r8q artifact, size, hash or
run id exists to check against. **Nothing has been flashed or
tested on an r8q by us.**

Upstream does publish r8q zips: each UN1CA release on
https://github.com/salvogiangri/UN1CA/releases lists a Galaxy S20
FE (Snapdragon) (r8q) download (gofile.io / drive.google.com)
with an MD5 and SHA1 printed per device. At research time
(2026-11-25) the releases page listed MD5
`c7182fe8d6e1d532a7c1ef58ed9ce9e1` and SHA1
`8e7792342b970017adeeeca4d79cb21677230d17` for the r8q entry of the
latest release shown there. Re-check those values on the releases
page before using them; do not trust this file's copy.

TODO: run a first porter build for r8q, record its run id,
artifact name, size, SHA-256 and retention here, and verify the
artifact before anyone flashes it.

## What the zip does (read before flashing)

Verified from the r8q target files in upstream:

- It asserts the bootloader is **at least G780GXXU3DVK5** (Android
  13 firmware) for G780G, and refuses with E3003 otherwise
  (`target/r8q/installer/assertions.edify`, lines 2 to 3). The
  same file covers the 5G siblings G7810, G781B and G781N; this
  guide is G780G only.
- It checks the recovery is a v2 recovery.fstab build
  (`assertions.edify`, line 0). Flash it from TWRP, not from stock
  recovery.
- It replaces the kernel with the UN1CA sm8250 kernel: the kernel
  patch downloads `boot.img` and `dtbo.img` from the latest
  release of https://github.com/UN1CA/kernel_samsung_sm8250
  (`target/r8q/patches/kernel/customize.sh`, lines 0 and 18 to
  20). See [flash-kernel.md](flash-kernel.md).
- It debloats a short list: two Wi-Fi RRO overlays,
  `system/bin/mafpc_write`, `GameDriver-SM8450`, and the Qualcomm
  location pieces in system_ext (`target/r8q/debloat.sh`).
- It enables the extra brightness floating feature
  (`target/r8q/sff.sh`, line 10).
- Its install-end step only patches one TUR carrier file
  (`target/r8q/installer/install-end.edify`).
- Its patch set covers blobs, camera, DVFS, edge lighting,
  emulated storage, FBE, FCM, kernel, NFC, RIL, screenlock,
  single-SIM, stock props and VoIP
  (`target/r8q/patches/`).
- DVFS uses `dvfs_policy_sdm8250_xx` and `siop_r8q_sm8250`
  (`target/r8q/config.sh`, lines 83 to 85).
- The display runs 120 Hz by default with 120 and 60 Hz supported
  (`target/r8q/config.sh`, lines 93 to 99).

TODO (not verified from the installer sources read so far): does
the zip flash bootloader or modem firmware, and which versions?
Does it wipe fingerprint enrolments or dalvik-cache? Does it touch
recovery? Do not assume the m51 answers apply here; check the
built zip's installer script before flashing.

## The fix pack

There is **no fix pack for the r8q**. The m51 performance fix pack
(thermal caps, blur, zram, swappiness, daemon overrides) is
m51-specific and does not apply here. No lag analysis has been done
for the r8q, so nothing is claimed about its thermal behaviour,
refresh rate at runtime, or memory tuning. TODO: measure the r8q
on UN1CA first, then decide whether a fix pack is needed at all.

## How the build is made

The upstream build system automatically builds the required tools,
downloads and extracts firmware components, applies the required
patches and generates a flashable zip for the target device
(UN1CA README). Firmware download uses samloader against
Samsung's servers; the porter repo pins samloader-rs
(`scripts/fetch-samloader-rs.sh`) and downloads firmware with
`scripts/fetch-firmware.sh`. The porter workflow has no r8q build
yet, so no r8q target pin or OTA setup exists in our repo. TODO:
add the r8q build to the porter workflow and record the target pin
here.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first. A Format
   Data is needed when coming from stock or another ROM.
3. **Battery above 50%, ideally full.**
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G780G**. The donor region
   for this phone is **BTU**.
5. The phone must already be on Android 13 firmware with
   bootloader **at least G780GXXU3DVK5**. In practice, flash the
   latest stock firmware first ([flash-stock.md](flash-stock.md),
   bootloader H (17)), which is well above the minimum.
6. The UN1CA zip on the phone or an SD card, with its MD5/SHA1
   checked against the upstream releases page. TODO: no porter
   zip or hash exists yet; use an upstream zip and check its
   printed hashes.

## Steps

1. TWRP installed (prereq 1), backup taken (prereq 2). The phone
   must already be on Android 13 firmware, bootloader at least
   G780GXXU3DVK5.
2. Copy the UN1CA zip to the phone (or an SD card).
3. In TWRP: Wipe, Format Data, type `YES` if coming from stock or
   another ROM (encryption differs). If updating from an older
   UN1CA, a dirty flash is usually fine. TODO: confirm the dirty
   flash rule for r8q from a real update; it is not verified.
4. Install, select the UN1CA zip, flash it. Wait. It is a
   multi-GB zip.
5. Reboot, System. First boot takes several minutes. Set up, then
   leave the phone idle about 30 min for dexopt before judging
   speed.
6. Check the install landed (see "Verify" below).

## Verify

- Settings, About phone, Software information: One UI version
  **8.0**, Android version **16**, UN1CA version **3.2.1**.
- The phone boots to the home screen and stays up. Wi-Fi, calls,
  and sensors work as before the flash.
- TODO: record the first real r8q flash result (booted or not,
  plus `dmesg` and `logcat`) and the measured refresh rate,
  swappiness and thermal behaviour. None of these has been
  measured on an r8q yet.

## Troubleshooting

- **Installer refuses with a bootloader assertion (E3003).** The
  phone is below G780GXXU3DVK5, that is, not on Android 13
  firmware. Flash the stock firmware first
  ([flash-stock.md](flash-stock.md)), which is bootloader H (17),
  then retry.
- **Installer refuses with E3000.** The recovery is not a v2
  recovery.fstab build. Flash the TWRP from
  [flash-twrp.md](flash-twrp.md) and retry.
- **Bootloop after flashing.** Boot into TWRP, Format Data, and
  re-flash the zip. If it still bootloops, capture a log (`adb
  logcat -d`) before wiping, and report it.
- **Fingerprint enrolments are gone after flashing.** TODO: not
  verified whether the r8q zip wipes them. If they are gone,
  re-enrol and report it so this line can be confirmed.
- **Lag or heat after 30 min idle.** Record the numbers
  (swappiness, thermal zones, frequencies) and report them with a
  log bundle. Do not judge speed before dexopt finishes.

## Going back to stock

Flash the [flash-stock.md](flash-stock.md) firmware with Odin
(AP/BL/CP/CSC), then Format Data in stock recovery. Knox stays
tripped. That cannot be undone.

## Sources

- UN1CA README (build system, Galaxy S22 base, Galaxy AI, DeX,
  KnoxPatch, Play Integrity Fix, OTA app):
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/README.md
- r8q target:
  https://github.com/salvogiangri/UN1CA/tree/sixteen/target/r8q
- r8q config (donor firmware SM-G780G/BTU, SDK 33, DVFS names,
  120 Hz): https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/r8q/config.sh
- Bootloader assertion and recovery check:
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/r8q/installer/assertions.edify
- Kernel patch (UN1CA sm8250 kernel releases):
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/r8q/patches/kernel/customize.sh
- Debloat list:
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/r8q/debloat.sh
- Extra brightness flag:
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/r8q/sff.sh
- Install-end step:
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/r8q/installer/install-end.edify
- UN1CA releases (r8q downloads, MD5/SHA1):
  https://github.com/salvogiangri/UN1CA/releases
- UN1CA 3.x stays on Android 16 / One UI 8.0:
  https://github.com/salvogiangri/UN1CA/discussions/629
- Porter repo has no r8q build (workflow builds m51 only; no r8q
  references in the repo): checked 2026-11-25 in
  `~/workspace/un1ca-universal/`
