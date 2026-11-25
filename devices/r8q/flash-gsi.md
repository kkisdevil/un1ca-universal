# Flash HyperOS (GSI) - Galaxy S20 FE (Snapdragon) (SM-G780G)

Flash HyperOS on the SM-G780G as a GSI. This file is for the
SM-G780G only. Do not use it on any other model, including the
Exynos S20 FE (SM-G780F).

## What a GSI is

HyperOS on the r8q is a **GSI**: a generic system image from the
community (MysticGSI), flashed over the r8q's own stock vendor.
There is no device-specific HyperOS port for the r8q, and the only
automated HyperOS porter (XMAPort) is Xiaomi to Xiaomi only: it
needs an official HyperOS base ROM for the target, and the r8q has
none. The GSI is the proven route in general: the XDA thread
"Tested GSIs on Snapdragon" reports months of GSI testing on the
Snapdragon S20 FE 4G (SM-G780G). LineageOS also officially supports
r8q (maintainer ata-kaner, Android 13 stock firmware required
first), which is a separate, non-HyperOS option.

## Honest status

HyperOS has **not** booted on an r8q in front of us yet. The DSU
trial has not started. Everything below is the procedure to run,
not a report of a working install. GSIs in general boot on this
phone (see the XDA testing thread above); HyperOS specifically is
unproven here.

## The GSI builds

| Build | File | Size | System |
|---|---|---|---|
| `spring` (**default: HyperOS 2**) | `Hyperos-spring-15-OS2.0.204.0.VOUMIXM-AB-20251206-MysticGSI.zip` | 3.1 GB | Android 15 / HyperOS 2, Qualcomm (Snapdragon 6s Gen 3) |
| `gold` | `Hyperos-gold-15-OS3.0.1.0.VNQCNXM-AB-20251228-MysticGSI.zip` | 3.6 GB | Android 15 / HyperOS 3.0.1.0, MediaTek (Dimensity 6080) |
| `pudding` (experimental) | `Hyperos-pudding-16-OS3.0.50.2.W-AB-20260122-MysticGSI.zip` | 4.0 GB | Android 16 / HyperOS 3, Qualcomm (Snapdragon 8 Elite Gen 5) |

Get one from
https://sourceforge.net/projects/mystic-gsi-updates/files/HyperOS/.

TODO: verify the sizes and MD5s from the SourceForge listing at
download time and record them here. The file names above are the
MysticGSI files; the files themselves are device-independent, so
the same downloads serve every device. For reference, the spring
zip was verified in our m51 GSI record as exactly 3,122,721,686 B,
MD5 `3e6337d1dd850ae2d0f7d067f8dd191c`, with a `system.img` of
6,232,481,792 B of ext4. Re-check the hash on download; do not
trust the numbers here blindly.

**Why spring, not gold:** gold is HyperOS 3.0.1.0 on Android 15
from a MediaTek device. A MediaTek-source GSI drags in MTK
telephony and camera jars and forces the MTK RIL shim chain.
Spring is the actual HyperOS 2 / Android 15 / Qualcomm-source
build, and the r8q's vendor is Android 13, so the smallest system
to vendor gap wins.

Fit check: the r8q super partition is 10,292,822,016 B
(`TARGET_SUPER_PARTITION_SIZE` in
`target/r8q/config.sh`, line 35), and the spring `system.img` is
about 6.2 GB, so it fits once `product` and `system_ext` are
deleted in Part 2 below. TODO: confirm the fit on a real flash;
the numbers say yes, the flash itself is unproven.

## Prereqs

1. **Unlocked bootloader** ([unlock-bootloader.md](unlock-bootloader.md)).
   The unlock wipes once, but the DSU trial itself wipes nothing.
   Back up first anyway.
2. **Back up everything.** A full flash needs a Format Data.
   Back up EFS in TWRP first.
3. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G780G**. The UN1CA donor
   region for this phone is **BTU**.
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
7. **Getting back: reboot.** That is it. For a long test with many
   reboots, sticky mode keeps booting the dynamic system:
   `adb shell gsi_tool enable` (disable with `disable`).

**If it does not boot:** DSU installs but the phone will not boot
into it: AVB is blocking the unsigned image. Flash
`vbmeta_disabled.tar` via Odin and try again. Install fails: free
space (GSI plus userdata image). Black screen or bootloop in the
GSI: the Android 13 vendor vs Android 15/16 system gap is the prime
suspect. Try the other build (HyperOS 2 first; HyperOS 1 / Android
14 has the smallest vendor gap). Capture a boot log over adb:
`adb logcat` while it tries.

**What a DSU boot proves:** the GSI boots on the r8q vendor. It
does **not** prove the full flash works the same way (that path
also depends on TWRP/fastbootd and the super-partition size), and
it does **not** prove SIM, camera, or fingerprint work. Those are
separate tests. The fingerprint sensor here is an in-display
optical sensor (`TARGET_FINGERPRINT_CONFIG_SENSOR` in
`target/r8q/config.sh`, line 87), which GSIs rarely drive
correctly: expect it not to work until proven otherwise.

## Part 2: full flash (TWRP + fastbootd)

Only after a successful trial boot.

1. Do the prereqs: unlock, TWRP, Format Data. Download the GSI
   and extract `system.img` from the zip
   (`unzip Hyperos-spring-....zip`). The extracted file must be a
   `system.img`. If the archive has none at the top level, stop.
2. In TWRP: Install, flash **Permissiver v5** (SELinux-permissive
   zip the Samsung GSI guides use). TODO: verify the Permissiver
   v5 URL, size and MD5 for this guide before flashing. For
   reference, the file verified in our m51 GSI record is
   1,251,096 B, MD5 `73f68347929e484351d2ca1f72360381`; re-check it
   on download. Enforcing SELinux otherwise blocks the GSI from
   booting.
3. In TWRP: Reboot, **Fastboot**. The phone boots into fastbootd
   (Samsung has no native fastboot).
4. Copy `system.img` into your platform-tools folder. From the PC:

```sh
fastboot erase system
fastboot delete-logical-partition product
fastboot delete-logical-partition system_ext
fastboot flash system system.img
fastboot -w
fastboot reboot recovery
```

`product` and `system_ext` are logical partitions inside super.
Deleting them frees room for the 3 to 4 GB system image. If
`fastboot flash system` fails with a size error, the image does not
fit super as laid out. Stop and report it. Do not force it.
5. In TWRP: Wipe, Format Data, type `YES`. Reboot, System.
6. First boot takes several minutes. The **setup wizard may be
   dead** (reported on other Samsung HyperOS GSIs). If it is,
   finish setup over adb (standard AOSP setup-skip commands,
   unproven on this build):

```sh
adb shell settings put secure user_setup_complete 1
adb shell settings put global device_provisioned 1
adb reboot
```

7. If it bootloops or black-screens, capture a log before wiping:
   `adb logcat -d > boot_log.txt` while the phone is up.

## Verify

- DSU trial: the GSI reaches the home screen. Record Wi-Fi,
  calls, and data: what works and what does not.
- Full flash: the phone boots into HyperOS, setup completes (over
  adb if the wizard is dead), and the build number matches the GSI
  you flashed.
- Check fingerprint, camera, SIM, and brightness separately.
  None of them is proven by a boot alone.

## Going back to stock

Flash the [flash-stock.md](flash-stock.md) firmware with Odin
(AP/BL/CP/CSC), then Format Data in stock recovery. That is the
full rollback. It also restores the stock vbmeta. (Knox stays
tripped. That cannot be undone.)

## Troubleshooting

- **DSU installs but will not boot into the GSI.** AVB is
  blocking the unsigned image. Flash `vbmeta_disabled.tar` via
  Odin and retry.
- **DSU install fails.** Free space. The GSI plus a userdata
  image needs several GB free on the phone.
- **GSI black screen or bootloop.** Vendor gap is the prime
  suspect. Try the other build (HyperOS 2 first, then HyperOS 1).
  Capture a boot log before wiping.
- **`fastboot flash system` fails with a size error.** The image
  does not fit super as laid out. Stop and report it. Do not
  force it.
- **Setup wizard dead on first GSI boot.** Finish setup over adb
  (Part 2, step 6).
- **No SIM, no calls, no data.** Expected on this vendor until
  proven otherwise. The RIL gap is the number one daily-driver
  blocker. Record exactly what fails (SIM detected? signal?
  calls? data?) and report it.

## Sources

- GSI testing on the Snapdragon S20 FE 4G (XDA, "Tested GSIs on
  Snapdragon"): https://xdaforums.com/tags/sm-g780g/
- MysticGSI HyperOS builds:
  https://sourceforge.net/projects/mystic-gsi-updates/files/HyperOS/
- Super partition size 10,292,822,016 B, dynamic partitions,
  fingerprint sensor, 120 Hz display:
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/r8q/config.sh
  (lines 33 to 39, 87, 93 to 99)
- LineageOS officially supports r8q (maintainer ata-kaner,
  Android 13 stock firmware required first):
  https://thecustomrom.com/devices/samsung/r8q
- DSU Sideloader: https://github.com/VegaBobo/DSU-Sideloader/releases
