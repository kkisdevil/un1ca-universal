# Flash HyperOS (GSI) - Galaxy A71 (SM-A715F)

Flash HyperOS on the SM-A715F as a GSI. This file is for the
SM-A715F only. Do not use it on any other model. Do not use it
on the Galaxy A71 5G (SM-A716, codename a71xq): that is a
different phone.

## What a GSI is on this device

A GSI (Generic System Image) is a system image built for any
Treble phone, not for one device. It runs on top of the phone's
own vendor partition. HyperOS has no device-specific port for
the A71: there is no Xiaomi device source for this phone, and
XMAPort needs an official HyperOS base ROM for the target, which
the A71 does not have. The GSI is the only route.

**The proven route is a GSI, and it has booted on this exact
model.** An XDA thread by seelenchik, "[GSI] HyperOS 2
(xiaomi.eu) port for Samsung Galaxy A71 SM-A715F" (June 29,
2025), boots HyperOS 2 on the A71 via a GSI. It credits FoxetGSI
for the GSI, Legofan for the vendor, the xiaomi.eu team, and
salvo_giangri for UN1CA for A71. Two warnings from that thread:
the FoxetGSI image link is **dead (404)**, and the thread says
"THIS ROM WILL NOT BE UPDATED ANYMORE DUE TO IT BEING HARD TO
FLASH AND UNSTABLE". So the proof exists, but the exact image
from that thread is gone. The downloadable route is MysticGSI
(see the table below).

**The A71 has a known GSI problem.** An XDA thread, "[ROM FIX]
[GSI FIX] Fix for the widespread A71 problem of not being able
to flash GSI / GSI won't boot / after flashing GSI, boots into
Fastboot mode" (https://xdaforums.com/t/rom-fix-gsi-fix-fix-for-the-widespread-a71-problem-of-not-being-able-to-flash-gsi-gsi-wont-boot-after-flashing-gsi-boots-into-fastboot-mode.4513209/),
documents that GSIs often refuse to boot on this phone at all.
Its Method 1 is: flash a specific boot.img in TWRP, re-flash
twrp-3.6.2 via Odin, run multidisabler, then flash the GSI as
the system image. Read that thread before you start. The DSU
trial in Part 1 is the safe way to find out whether the GSI
boots on your phone without risking the stock system.

## Honest status

- **HyperOS has NOT booted on an A71 in front of us.** The
  seelenchik thread proves it booted for someone else in June
  2025. Nobody on this project has booted it.
- **The DSU trial has NOT started.** Nothing in this file has
  been run end-to-end on an A71 by us.
- MysticGSI spring is the default build below because it is the
  only one with a live download and a verified hash (see the
  m51 record; the file is the same file for every device).

## The GSI builds

| Build | File | Size | System | Donor |
|---|---|---|---|---|
| **spring (default)** | Hyperos-spring-15-OS2.0.204.0.VOUMIXM-AB-20251206-MysticGSI.zip | 3,122,721,686 B | HyperOS 2 / Android 15 | Redmi 15 5G (Snapdragon 6s Gen 3, Qualcomm) |
| gold | Hyperos-gold-15-OS3.0.1.0.VNQCNXM-AB-20251228-MysticGSI.zip | 3,554,104,547 B | HyperOS 3.0.1.0 / Android 15 | Redmi Note 13 5G (MediaTek) |
| pudding | Hyperos-pudding-16-OS3.0.50.2.VNACNXM-AB-20251229-MysticGSI.zip | 3,994,747,809 B | HyperOS 3.0.50.2 / Android 16 | Xiaomi 17 (Snapdragon 8 Elite Gen 5) |

MD5s (verified from the SourceForge listing, same files as the
m51 record):

- spring: `3e6337d1dd850ae2d0f7d067f8dd191c`
- gold: `edb87b9e088f0e1eaa5e8bf1c0ba6113`
- pudding: `9eb03ec3f211365aecbaa346be9516b5`

**Spring is the default** because the A71 vendor is Qualcomm
(SM7150) and spring is the Qualcomm-source build. Gold comes
from a MediaTek donor; pudding is Android 16, which the A71
vendor (FCM 6, VNDK 31, kernel 4.14) is not ready for. The
seelenchik A71 thread used a FoxetGSI image, not MysticGSI; that
image is dead, so spring is the closest live equivalent.

**Permissiver v5** (SELinux permissive zip, flashed in TWRP
before the GSI): direct URL
https://sourceforge.net/projects/sgsi137/files/Permissiver%20v5.zip/download
(HTTP 200, 1,251,096 B, MD5
`73f68347929e484351d2ca1f72360381`).

## Prereqs

1. **Unlocked bootloader.** Do
   [unlock-bootloader.md](unlock-bootloader.md) first.
2. **TWRP installed.** Do
   [flash-twrp.md](flash-twrp.md) first. The full flash needs
   it. The DSU trial does not.
3. **Back up everything** (and back up EFS in TWRP). The full
   flash wipes data. The DSU trial does not.
4. **Battery above 50%, ideally full.** A good USB data cable
   and a USB port on the PC itself.
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A715F**.
6. A PC with platform-tools (`adb`, `fastboot`), and at least
   10 GB free disk (the GSI zip is 3.1 GB; the extracted
   `system.img` is about 6.2 GB).
7. For the DSU trial: at least **8 GB free on the phone**
   (the GSI system image is about 6.2 GB).

## Part 1: DSU trial boot (no risk to stock)

DSU (Dynamic System Updates) boots the GSI alongside stock.
Rebooting returns to stock. Nothing on the phone is wiped.

1. Install **DSU Sideloader** (F-Droid, or
   https://github.com/VegaBobo/DSU-Sideloader/releases) and
   **Shizuku**. Or use ADB mode.
2. Copy the spring GSI zip onto the phone. Extract it first:
   the DSU Sideloader needs the `system.img`, not the zip.
3. In DSU Sideloader, grant the permissions, select the
   `system.img`, install, confirm, and boot.
4. If the phone offers a "sticky" mode, enable it: `adb shell
   gsi_tool enable` keeps the GSI across reboots until you
   disable it.
5. Watch the boot. If it boots to the HyperOS home screen, the
   trial worked. If it bootloops, the phone falls back to stock
   on its own after a few minutes. Check `adb shell gsi_tool
   status` from the PC.

**What a DSU boot proves and does not prove.** It proves the
GSI boots on this phone and that the display, touch, and
brightness work. It does not prove calls, data, Wi-Fi,
fingerprint, or camera work. Those need the full flash and a
real test.

**DSU failure modes.**

- **AVB block.** The GSI is not signed by a key the phone
  trusts. On an unlocked bootloader with `vbmeta_disabled.tar`
  flashed (see [flash-twrp.md](flash-twrp.md)), DSU should
  accept it. If DSU refuses, flash `vbmeta_disabled.tar` in
  Odin first.
- **Not enough free space.** Free 8 GB on the phone.
- **Bootloop, then back to stock.** The GSI did not boot. That
  is the A71 GSI problem (see the XDA fix thread above). Try
  the full flash in Part 2, or the boot.img from the fix thread.
- **TODO: no DSU trial has been run on an A71 by us.** The
  steps above are the standard DSU flow; whether the A71 GSI
  problem affects DSU too is unproven.

## Part 2: full flash (TWRP + fastbootd)

Samsung phones have **no native fastboot**. The fastbootd route
goes through TWRP.

1. Boot into TWRP. Flash **Permissiver v5** (Install, choose the
   zip). This sets SELinux permissive so the GSI can boot.
2. In TWRP, Reboot, Bootloader (or `adb reboot fastboot`).
   TWRP's fastbootd opens.
3. From the PC, flash the GSI as the system image:

```text
fastboot flash system system.img
```

4. If the flash fails with a size error, the super partition is
   full. The A71 super partition is 8,053,063,680 B (QTI dynamic
   partitions 8,048,869,376 B) and the extracted `system.img`
   is about 6.2 GB. The standard TrebleDroid fix is to delete a
   logical partition you do not need (usually `product`) before
   flashing:

```text
fastboot delete-logical-partition product
fastboot flash system system.img
```

**TODO: the exact delete list for the A71 super layout has not
been verified by us.** Confirm it from a real a71 super dump
(`lpunpack` / `lpdump`) before relying on it. Do not delete
`vendor` or `odm`: the GSI runs on top of them.
5. Back in TWRP, **Format Data** (Wipe, Format Data, type
   `yes`). This is a format, not a wipe. It removes encryption
   so the GSI can use /data.
6. Reboot to System. First boot takes a few minutes.
7. **Setup wizard is dead on the spring GSI** (same file as the
   m51 record). Skip it from adb:

```text
adb shell settings put global device_provisioned 1
adb shell settings put secure user_setup_complete 1
adb shell pm disable com.android.provision
```

8. Capture the boot log. The live watcher is in the m51-hyperos
   repo:
   https://github.com/kkisdevil/m51-hyperos/tree/main/tools/m51-logger
   (`watch-logs.sh` on the PC, or `watch-logs-termux.sh`
   on-device). If adb never comes up, the only record is
   `/sys/fs/pstore/console-ramoops`, readable after falling
   back to stock or from TWRP.

**Seelenchik's recipe (his GSI ports, not MysticGSI).** His
threads flash a `dtbo.img` and a `boot.img` (Prime Kernel by
pascua28) and a GSI_Patches.zip in TWRP before the GSI. That
recipe belongs to his ports. Do not mix it into the MysticGSI
flash unless the MysticGSI image fails to boot and you are
following his thread.

## Verify

- The phone reaches the HyperOS home screen.
- Wi-Fi connects.
- Calls work, mobile data works.
- The in-display optical fingerprint enrols (sensor at
  540|2105|90, type udfps_optical). **Unproven on a GSI.**
- Camera opens (GCam, not the Xiaomi camera).
- Brightness changes.

A boot alone proves none of these except the boot itself.

## Going back to stock

Flash the stock firmware: [flash-stock.md](flash-stock.md).
That restores the system, vendor, boot, and recovery. Knox stays
tripped. The GSI is gone.

## Troubleshooting

- **DSU installs but will not boot.** The A71 GSI problem. Try
  the full flash in Part 2, or the boot.img from the XDA fix
  thread.
- **DSU install fails.** Not enough free space, or AVB refused
  the image. Free 8 GB, flash `vbmeta_disabled.tar` in Odin.
- **GSI black screen or bootloop.** The A71 GSI problem. Read
  the XDA fix thread (4513209) and try its Method 1. Capture
  the boot log (watcher or pstore) before wiping anything.
- **`fastboot flash system` size error.** Delete the `product`
  logical partition (step 4) and try again. Do not delete
  `vendor` or `odm`.
- **Setup wizard dead.** Use the adb setup-skip commands in
  step 7.
- **No SIM, no calls, no data.** The RIL/IMS bridge is the
  number one gap on this device (same as m51). The GSI's
  telephony stack talks to the Samsung vendor RIL through the
  TrebleDroid IMS path. If calls fail, the fix is in the
  HyperOS port work, not in this guide. TODO: unproven on a71.

## Sources

- HyperOS 2 boots on the A71 via GSI: XDA thread by seelenchik,
  "[GSI] HyperOS 2 (xiaomi.eu) port for Samsung Galaxy A71
  SM-A715F" (June 29, 2025). Credits FoxetGSI (GSI, link dead),
  Legofan (vendor), xiaomi.eu, salvo_giangri (UN1CA for A71).
  Thread note: "THIS ROM WILL NOT BE UPDATED ANYMORE DUE TO IT
  BEING HARD TO FLASH AND UNSTABLE".
- A71 GSI problem and Method 1 (boot.img in TWRP, re-flash
  twrp-3.6.2 via Odin, multidisabler, flash GSI as system
  image): XDA thread "[ROM FIX] [GSI FIX] Fix for the
  widespread A71 problem of not being able to flash GSI",
  https://xdaforums.com/t/rom-fix-gsi-fix-fix-for-the-widespread-a71-problem-of-not-being-able-to-flash-gsi-gsi-wont-boot-after-flashing-gsi-boots-into-fastboot-mode.4513209/
- Super partition 8,053,063,680 B, QTI dynamic 8,048,869,376 B:
  Arnav3078/UN1CA-SM7150@seventeen, `target/a71/config.sh:18-21`
  (identical in mehedihjoy0/UN1CA-SM7150@sixteen).
- Fingerprint sensor 540|2105|90, type udfps_optical:
  a71-devs/android_device_samsung_a71@lineage-22.2,
  `vendor.prop`; max enrollments 4, force_calibrate=true:
  a71-devs/android_device_samsung_a71-common@lineage-22.2,
  `vendor.prop`.
- GSI builds, sizes, MD5s, Permissiver v5 URL/size/MD5: the m51
  record (same files for every device; verified from the
  SourceForge listings). DSU Sideloader:
  https://github.com/VegaBobo/DSU-Sideloader/releases.
- Seelenchik's recipe (dtbo.img, Prime Kernel boot.img by
  pascua28, GSI_Patches.zip): his XDA GSI threads for a71
  (searched 2026-11-25). Prime Kernel is pascua28's kernel for
  the A71 4G.
- Setup wizard dead on spring, boot log capture via the m51
  logger: the m51 record (same GSI file).
