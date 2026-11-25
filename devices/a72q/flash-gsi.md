# Flash HyperOS (GSI) - Galaxy A72 (SM-A725F)

Flash HyperOS on the SM-A725F as a GSI. This file is for the
SM-A725F only. Do not use it on any other model.

## What a GSI is

HyperOS on the a72q is a **GSI**: a generic system image from the
community (MysticGSI), flashed over the A72's own stock vendor.
There is no device-specific HyperOS port for the A72, and the only
automated HyperOS porter (XMAPort) is Xiaomi to Xiaomi only: it
needs an official HyperOS base ROM for the target, and the A72 has
none. The GSI is the route. The sibling device A71 boots HyperOS 2
this way, and the m51 guide in this porter records the same GSI
route with the same builds.

## Honest status

HyperOS has **not** booted on an A72 in front of us yet. The DSU
trial has not started. Everything below is the procedure to run,
not a report of a working install. The A72 has two things in its
favour versus the m51: its vendor is Android 14 (SDK 34,
`target/a72q/config.sh` line 10), not Android 12, so the system to
vendor gap to a HyperOS 2 / Android 15 GSI is one release, not
three; and its stock kernel is 4.14.190, the same generation the
GSI expects. Neither fact proves a boot. Run the DSU trial first.

## The GSI builds

These are the same shared MysticGSI builds used for the m51. A GSI
is device independent, so the same file applies here. Sizes and
MD5s below are from the m51 verification record, not re-verified
for the A72.

| Build | File | Size | System |
|---|---|---|---|
| `spring` (**default: HyperOS 2**) | `Hyperos-spring-15-OS2.0.204.0.VOUMIXM-AB-20251206-MysticGSI.zip` | 3.1 GB | Android 15 / HyperOS 2, Qualcomm (Snapdragon 6s Gen 3) |
| `gold` | `Hyperos-gold-15-OS3.0.1.0.VNQCNXM-AB-20251228-MysticGSI.zip` | 3.6 GB | Android 15 / HyperOS 3.0.1.0, MediaTek (Dimensity 6080) |
| `pudding` (experimental) | `Hyperos-pudding-16-OS3.0.50.2.W-AB-20260122-MysticGSI.zip` | 4.0 GB | Android 16 / HyperOS 3, Qualcomm (Snapdragon 8 Elite Gen 5) |

Get one from
https://sourceforge.net/projects/mystic-gsi-updates/files/HyperOS/.

**Why spring, not gold:** gold is HyperOS 3.0.1.0 on Android 15
from a MediaTek device. A MediaTek-source GSI drags in MTK
telephony and camera jars and forces the MTK RIL shim chain.
Spring is the actual HyperOS 2 / Android 15 / Qualcomm-source
build, and the A72 is a Qualcomm device (Snapdragon 720G, sm7125),
so the smallest system to vendor gap wins. Verified for the m51:
the spring zip is exactly 3,122,721,686 B, MD5
`3e6337d1dd850ae2d0f7d067f8dd191c`, and its `system.img` is
6,232,481,792 B of **ext4**. The DSU filesystem gate is cleared
for that file.

TODO: check the spring `system.img` (6,232,481,792 B) against the
A72 super layout before the full flash. The A72 super partition is
10,292,822,016 B (`target/a72q/config.sh` line 13) with a QTI
dynamic partitions size of 10,288,627,712 B (line 14). The GSI
plus vendor, product, system_ext and odm must fit inside that.
TODO: measure the A72's actual logical partition sizes in TWRP
and confirm the fit, or the full flash will fail with a size
error.

## Prereqs

1. **Unlocked bootloader** ([unlock-bootloader.md](unlock-bootloader.md)).
   The unlock wipes once, but the DSU trial itself wipes nothing.
   Back up first anyway.
2. **Back up everything.** A full flash needs a Format Data.
   Back up EFS in TWRP first.
3. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A725F**. The upstream target
   firmware is BTU (`target/a72q/config.sh` line 8).
5. For the full flash: TWRP installed ([flash-twrp.md](flash-twrp.md)),
   a PC with Android platform-tools (`adb`, `fastboot`), about
   10 GB free disk, and the GSI itself (about 3 to 4 GB).
6. For the DSU trial: several GB free on the phone for the second
   system image, plus DSU Sideloader and Shizuku (below).

## Part 1: try it first (DSU trial boot, no wipe, no flash)

DSU (Dynamic System Updates) boots the GSI once as a second,
temporary system. Your installed system and data are untouched,
and a reboot takes you back. If the GSI bootloops, you lose
nothing but time. **Do this before the full flash.**

1. Unlocked bootloader (prereq 1 above). Back up first anyway.
2. Get the GSI on the phone (copy the zip, or the extracted
   `system.img`, to the phone). DSU needs several GB free on the
   phone for the second system image.
3. Install **DSU Sideloader** by VegaBobo, from
   [F-Droid](https://f-droid.org/) or
   https://github.com/VegaBobo/DSU-Sideloader/releases, and
   **Shizuku** (Play Store) for the easiest mode if the phone is
   not rooted. Root also works. Plain ADB mode works too but needs
   a PC command.
4. Open DSU Sideloader, give it read/write permission to a folder
   you create (it stores temporary files such as the extracted
   GSI), select the GSI (`.gz`, `.xz`, `.img`, or `.zip`: if the app
   rejects the Mystic zip, extract `system.img` first and select
   the `.img`). Do not change the GSI file size; let the app
   handle it. Optionally set the userdata size for the dynamic
   system.
5. Tap **Install** and wait. When it finishes: root mode needs no
   extra step; Shizuku/root mode shows the DSU screen asking you
   to confirm (check notifications); ADB mode prompts you to run
   a command in adb. Run it, and the DSU screen appears.
6. Boot the dynamic system from the notification (or the app).
   Test: home screen? Wi-Fi? Calls? Write down what works and
   what does not. That is the test report this project needs.
   Pay special attention to the **in-display optical
   fingerprint**: the A72 sensor is
   `google_touch_display_optical,settings=3`
   (`target/a72q/config.sh` line 31). A GSI fingerprint working
   on a side-mounted sensor device proves nothing about this one.
7. **Getting back: reboot.** That is it. For a long test with many
   reboots, sticky mode keeps booting the dynamic system:
   `adb shell gsi_tool enable` (disable with `disable`).

**If it does not boot:** DSU installs but the phone will not boot
into it: AVB is blocking the unsigned image. Flash
`vbmeta_disabled.tar` via Odin and try again. Install fails: free
space (GSI plus userdata image). Black screen or bootloop in the
GSI: the vendor to system gap is the prime suspect. Try the other
build (HyperOS 2 first; HyperOS 1 / Android 14 has the smallest
vendor gap against this Android 14 vendor). Capture a boot log
over adb: `adb logcat` while it tries.

**What a DSU boot proves:** the GSI boots on the A72 vendor. It
does **not** prove the full flash works the same way (that path
also depends on TWRP/fastbootd and the super-partition size), and
it does **not** prove SIM, camera, or fingerprint work. Those are
separate checks, and the in-display fingerprint is the one most
likely to fail.

## Part 2: full flash (TWRP + fastbootd)

Samsung phones have no native fastboot. The fastbootd route
through TWRP applies: boot TWRP, enter its fastbootd mode, and
flash the logical partitions from the PC.

TODO: this part has not been run on an A72. The steps below are
the standard dynamic-partition GSI flash, adapted to the A72
super size. Confirm each command against a live TWRP fastbootd
session before treating it as verified.

1. TWRP installed ([flash-twrp.md](flash-twrp.md)). Back up EFS
   first.
2. Boot into TWRP, enter fastbootd mode (TWRP menu: Reboot,
   Fastboot, or `adb reboot fastboot` from TWRP).
3. From the PC, check the device is seen: `fastboot devices`.
4. Delete the logical partitions that the GSI replaces, so the
   system image fits in super. The exact set depends on the
   A72's logical partition layout. TODO: list the A72 logical
   partitions from a live `fastboot getvar all` or TWRP session
   and record the delete commands here. The shape is:
   `fastboot delete-logical-partition product`,
   `fastboot delete-logical-partition system_ext`, and the same
   for the other non-system logical partitions the layout holds.
   Do not delete `vendor`: the GSI runs on the stock vendor.
5. Flash the GSI: `fastboot flash system system.img`.
   TODO: confirm the spring `system.img` (6,232,481,792 B) fits
   the A72 super layout (10,292,822,016 B total, 10,288,627,712 B
   QTI dynamic) after the deletes in step 4.
6. TODO: Permissiver version for this device, or the SELinux step
   this device needs. The GSI needs a permissive SELinux or a
   permissive patch to boot on a Samsung vendor. No a72q
   Permissiver build has been verified by us. Record the exact
   file, URL, size and MD5 here once one is checked.
7. Back in TWRP: Wipe, Format Data, type `YES`.
8. Reboot, System. First boot takes several minutes.
9. Setup wizard behaviour on this device: TODO, unknown. If the
   wizard is dead, skip setup with the standard commands
   (`adb shell settings put global setup_wizard_has_run 1` and
   `adb shell settings put secure user_setup_complete 1`, then
   reboot) and record whether they worked here.
10. Capture a boot log over adb (`adb logcat`) if anything fails,
    before wiping again.

## Verify

- Home screen comes up and stays up.
- Wi-Fi connects, calls work, mobile data works.
- **In-display fingerprint enrols and unlocks.** This is the
  A72-specific check. A boot alone proves none of these except
  the boot itself.
- Camera opens and takes a photo. Brightness slider works
  (the target enables an extra brightness feature:
  `target/a72q/sff.sh` sets
  `SEC_FLOATING_FEATURE_LCD_SUPPORT_EXTRA_BRIGHTNESS=TRUE`).
- The display runs at 90 Hz: the panel supports 60 and 90
  (`target/a72q/config.sh` lines 34 to 36), default 90.

## Going back to stock

Flash [flash-stock.md](flash-stock.md) with Odin (AP/BL/CP/CSC),
then Format Data in stock recovery. That restores the stock
system, vendor and recovery. Knox stays tripped. That cannot be
undone.

## Troubleshooting

- **DSU installs but will not boot.** AVB is blocking the
  unsigned image. Flash `vbmeta_disabled.tar` via Odin and try
  again.
- **DSU install fails.** Free space on the phone. The GSI plus
  the userdata image need several GB free.
- **GSI black screen or bootloop.** Vendor to system gap, or the
  SELinux step (Part 2 step 6) is missing. Try the HyperOS 2
  build first, then an Android 14 based GSI.
- **`fastboot flash system` size error.** The GSI does not fit
  the super layout. Delete more logical partitions (Part 2
  step 4) or use a smaller GSI build. Record the actual logical
  partition sizes first.
- **Setup wizard dead.** Use the setup-skip commands in Part 2
  step 9 and record whether they worked.
- **No SIM, no calls, no data.** The RIL is the likely gap. The
  A72 RIL is `onebinary` with a single SIM tray
  (`target/a72q/config.sh` lines 38 to 39). Record the exact
  failure (no SIM detected vs SIM detected but no service) with
  a logcat, and report it.

## Sources

- Upstream target config:
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/a72q/config.sh
  lines 10 (SDK 34), 13 (super 10,292,822,016), 14 (QTI dynamic
  10,288,627,712), 31 (in-display optical fingerprint), 34 to 36
  (60/90 Hz), 38 to 39 (RIL onebinary, single SIM tray).
- Upstream floating feature:
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/a72q/sff.sh
  (extra brightness enabled).
- GSI builds and verification: this porter's m51 guide
  (`../m51/flash-gsi.md`) and its verification record; the spring
  zip (3,122,721,686 B, MD5
  `3e6337d1dd850ae2d0f7d067f8dd191c`) was verified there, not
  re-verified for the A72.
- GSI source:
  https://sourceforge.net/projects/mystic-gsi-updates/files/HyperOS/
- DSU Sideloader: https://github.com/VegaBobo/DSU-Sideloader/releases
- No A72 HyperOS boot, DSU trial, or full flash has been done in
  front of us. The TODOs above are the work.
