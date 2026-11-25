# Flash HyperOS (GSI) - Galaxy A52s 5G (SM-A528B)

Flash HyperOS on the SM-A528B as a GSI. This file is for the
SM-A528B only. Do not use it on any other model.

## What a GSI is

HyperOS on the A52s is a **GSI**: a generic system image from the
community (MysticGSI), flashed over the A52s's own stock vendor.
There is no device-specific HyperOS port for the A52s, and the
only automated HyperOS porter (XMAPort) is Xiaomi to Xiaomi only:
it needs an official HyperOS base ROM for the target, and the
A52s has none. The GSI is the route to try. The A52s vendor is
frozen at Android 14 (One UI 6.1, stock kernel 5.4.254), so the
system-to-vendor gap is smaller than on older-vendor devices, but
it is still a gap: the GSI is Android 15 or 16, the vendor is
Android 14.

## Honest status

HyperOS has **not** booted on an A52s in front of us yet. The DSU
trial has not started. An XDA forum question asks whether anyone
has tried the HyperOS GSI from Mystic on the A52s, and no answer
was found in this research. Everything below is the procedure to
run, not a report of a working install. Do not present any GSI
step below as proven on this device.

## The GSI builds

The builds below are the MysticGSI HyperOS builds. They are the
same files used for other Samsung devices: the file hashes below
are from the m51-hyperos repo's verification of the same files,
not from a download made for the A52s in this session. TODO:
re-download and re-verify size and MD5 for the A52s before
flashing, and record the result here.

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
build, and the A52s is a Qualcomm device (Snapdragon 778G,
sm7325), so the smallest system-to-vendor gap wins. The spring
zip as verified in the m51 repo is exactly 3,122,721,686 B, MD5
`3e6337d1dd850ae2d0f7d067f8dd191c`, and its `system.img` is
6,232,481,792 B of **ext4**. The DSU filesystem gate is cleared
for that file. TODO: confirm the same file still downloads with
the same hash; MysticGSI may have re-issued it since.

Super-partition fit: the A52s super partition is 10,643,046,400 B
(upstream `target/a52sxq/config.sh` line 24), with the QTI dynamic
partitions area 10,638,852,096 B (line 26). That is about 9.9 GiB.
The spring `system.img` is about 6.2 GB, so it fits in principle
once `product` and `system_ext` are deleted (Part 2), but the
actual A52s super layout has **not** been measured in this
session. TODO: read the live super layout from the phone
(`adb shell` / fastbootd partition listing) and record whether
the image fits before attempting Part 2.

## Prereqs

1. **Unlocked bootloader** ([unlock-bootloader.md](unlock-bootloader.md)).
   The unlock wipes once, but the DSU trial itself wipes nothing.
   Back up first anyway.
2. **Back up everything.** A full flash needs a Format Data.
   Back up EFS in TWRP first.
3. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A528B**. The UN1CA target
   firmware is the BTU region build; check your own CSC.
5. For the full flash: TWRP installed ([flash-twrp.md](flash-twrp.md)),
   a PC with Android platform-tools (`adb`, `fastboot`), about
   10 GB free disk, and the GSI itself (about 3 to 4 GB).
6. For the DSU trial: several GB free on the phone for the second
   system image, plus DSU Sideloader and Shizuku (below).
7. Stock firmware should be the Android 14 build
   (A528BXXSBGYI3, see [flash-stock.md](flash-stock.md)) before
   either part. The UN1CA thread requires an Android 14
   bootloader, and the same base is the sane starting point for
   a GSI trial.

## Part 1: try it first (DSU trial boot, no wipe, no flash)

DSU (Dynamic System Updates) boots the GSI once as a second,
temporary system. Your installed system and data are untouched,
and a reboot takes you back. If the GSI bootloops, you lose
nothing but time. **Do this before the full flash.**

1. Unlocked bootloader (prereq 1 above). Back up first anyway.
2. Get the GSI on the phone (download the zip, or the extracted
   `system.img`, and copy it to the phone). DSU needs several GB
   free on the phone for the second system image.
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
   fingerprint** (upstream config line 61:
   `google_touch_display_optical,settings=3`) and to the 120 Hz
   display: neither is proven by a boot alone.
7. **Getting back: reboot.** That is it. For a long test with many
   reboots, sticky mode keeps booting the dynamic system:
   `adb shell gsi_tool enable` (disable with `disable`).

**If it does not boot:** DSU installs but the phone will not boot
into it: AVB is blocking the unsigned image. Flash
`vbmeta_disabled.tar` via Odin and try again (see
[flash-twrp.md](flash-twrp.md), step 3, for the slot question).
Install fails: free space (GSI plus userdata image). Black screen
or bootloop in the GSI: the Android 14 vendor vs Android 15/16
system gap is the prime suspect. Try the other build (HyperOS 2
first; HyperOS 1 / Android 14 has the smallest vendor gap).
Capture a boot log over adb: `adb logcat` while it tries.

**What a DSU boot proves:** the GSI boots on the A52s vendor. It
does **not** prove the full flash works the same way (that path
also depends on TWRP/fastbootd and the super-partition size), and
it does **not** prove SIM, camera, or fingerprint work. Those are
separate tests.

## Part 2: full flash (TWRP + fastbootd)

Only after a successful trial boot.

1. Do the prereqs: unlock, TWRP, Format Data. Download the GSI
   and extract `system.img` from the zip
   (`unzip Hyperos-spring-....zip`). The extracted file must be a
   `system.img`. If the archive has none at the top level, stop.
2. In TWRP: Install, flash **Permissiver v5** (SELinux-permissive
   zip the Samsung GSI guides use; verified in the m51 repo as
   1,251,096 B, MD5 `73f68347929e484351d2ca1f72360381`).
   Enforcing SELinux otherwise blocks the GSI from booting.
   TODO: re-verify the Permissiver download for the A52s in this
   session; the size and MD5 above are from the m51 verification
   record, not an A52s download.
3. In TWRP: Reboot, **Fastboot**. The phone boots into fastbootd
   (Samsung has no native fastboot). This is the route the twrp.me
   A52s page itself states: to flash individual partitions on
   this dynamic-partition device, boot into fastbootd.
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
TODO: confirm the A52s super layout (which logical partitions
exist and their sizes) from the phone before running these
commands; the delete list above is the standard Samsung GSI
shape, not a measured A52s layout.
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
- Check fingerprint (in-display optical), camera, SIM, and
  brightness separately. None of them is proven by a boot alone.
- Check the refresh rate: the phone is a 120 Hz device (upstream
  config lines 67 and 77: default 120, supported 60,120). A GSI
  that locks it to 60 Hz is a regression to record, not a pass.

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
  force it. Record the A52s super layout first (see Part 2,
  step 4 TODO).
- **Setup wizard dead on first GSI boot.** Finish setup over adb
  (Part 2, step 6).
- **No SIM, no calls, no data.** Expected on this vendor until
  proven otherwise. The RIL gap is the number one daily-driver
  blocker. Upstream config line 87 records
  `TARGET_RIL_FEATURES="onebinary"` and line 89 a single-SIM tray
  (`MULTISIM_TRAYCOUNT="1"`). Record exactly what fails (SIM
  detected? signal? calls? data?) and report it.
- **Fingerprint does not work in the GSI.** Expected until proven
  otherwise: the sensor is an in-display optical sensor
  (upstream config line 61), and GSI fingerprint support for it
  is unproven on this device.

## Sources

- Upstream `target/a52sxq/config.sh` lines 24-26 (super
  partition sizes), 61 (in-display optical fingerprint), 67 and
  77 (120 Hz default and supported rates), 87 and 89 (RIL
  onebinary, single SIM):
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/a52sxq/config.sh
- Official TWRP device page (Dynamic Partitions, fastbootd
  route): https://twrp.me/samsung/samsunggalaxya52s5G.html
- MysticGSI HyperOS downloads:
  https://sourceforge.net/projects/mystic-gsi-updates/files/HyperOS/
- DSU Sideloader: https://github.com/VegaBobo/DSU-Sideloader/releases
- XDA A52s forum index (HyperOS/Mystic GSI question, no answer
  found): https://xdaforums.com/tags/a52s/
- GSI file hashes and Permissiver size/MD5: m51-hyperos repo
  verification record (same MysticGSI files, verified for the
  m51, not re-verified for the A52s in this session).
- TODO: re-verify spring zip size/MD5 and Permissiver MD5 for
  the A52s. TODO: measure the A52s super layout and confirm the
  delete list. TODO: run the DSU trial and record the result.
