# Flash HyperOS (GSI) - Galaxy M52 5G (SM-M526B / SM-M526BR)

Flash HyperOS on the SM-M526B / SM-M526BR as a GSI. This file is
for the SM-M526B and SM-M526BR only. Do not use it on any other
model.

## What a GSI is

HyperOS on the m52xq is a **GSI**: a generic system image from the
community (MysticGSI), flashed over the m52xq's own stock vendor.
There is no device-specific HyperOS port for the m52xq, and the
only automated HyperOS porter (XMAPort) is Xiaomi to Xiaomi only:
it needs an official HyperOS base ROM for the target, and the
m52xq has none. The GSI is the proven route in principle: the
sister device A71 boots HyperOS 2 this way.

## Honest status

HyperOS has **not** booted on an m52xq in front of us yet. The DSU
trial has not started. Everything below is the procedure to run,
not a report of a working install.

## The GSI builds

The GSI files are device-independent: the same MysticGSI builds
are used for every Samsung GSI install. The sizes and hashes below
were verified in the m51-hyperos project's verification record
(see Sources). The m52xq-specific check is the super partition
fit, done below from the m52xq's own config.

| Build | File | Size | System |
|---|---|---|---|
| `spring` (**default: HyperOS 2**) | `Hyperos-spring-15-OS2.0.204.0.VOUMIXM-AB-20251206-MysticGSI.zip` | 3.1 GB (zip 3,122,721,686 B; `system.img` 6,232,481,792 B, ext4) | Android 15 / HyperOS 2, Qualcomm (Snapdragon 6s Gen 3) |
| `gold` | `Hyperos-gold-15-OS3.0.1.0.VNQCNXM-AB-20251228-MysticGSI.zip` | 3.6 GB | Android 15 / HyperOS 3.0.1.0, MediaTek (Dimensity 6080) |
| `pudding` (experimental) | `Hyperos-pudding-16-OS3.0.50.2.W-AB-20260122-MysticGSI.zip` | 4.0 GB | Android 16 / HyperOS 3, Qualcomm (Snapdragon 8 Elite Gen 5) |

Get one from
https://sourceforge.net/projects/mystic-gsi-updates/files/HyperOS/.

**Why spring, not gold:** gold is HyperOS 3.0.1.0 on Android 15
from a MediaTek device. A MediaTek-source GSI drags in MTK
telephony and camera jars and forces the MTK RIL shim chain.
Spring is the actual HyperOS 2 / Android 15 / Qualcomm-source
build. The spring zip's MD5 is
`3e6337d1dd850ae2d0f7d067f8dd191c` (verified in the m51-hyperos
record; re-check the hash of your own download before flashing).

**Does it fit this phone?** The m52xq super partition is
10,328,473,600 bytes (upstream config.sh, line 14; the TWRP
device tree BoardConfig agrees, line 101). The spring
`system.img` is 6,232,481,792 bytes. It fits after the
`product` and `system_ext` logical partitions are deleted (Part
2, step 4), the same as on other Samsung GSI installs. If
`fastboot flash system` fails with a size error anyway, stop and
report it. Do not force it.

**Vendor gap:** the m52xq vendor is Android 13
(TARGET_PLATFORM_SDK_VERSION 33, shipping API level 30, per
upstream config.sh lines 10-11). That is one Android version
closer to the Android 15 GSI than the m51's Android 12 vendor,
so the system-to-vendor gap is smaller here, but it is still a
gap: SIM, camera, and fingerprint are unproven until tested.

## Prereqs

1. **Unlocked bootloader** ([unlock-bootloader.md](unlock-bootloader.md)).
   The unlock wipes once, but the DSU trial itself wipes nothing.
   Back up first anyway.
2. **Back up everything.** A full flash needs a Format Data.
   Back up EFS in TWRP first.
3. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-M526B** or **SM-M526BR**
   and the service provider software version must show the CSC
   for your region.
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
2. Get the GSI on the phone (download the zip, or the extracted
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
GSI: the Android 13 vendor vs Android 15/16 system gap is the
prime suspect. Try the other build (HyperOS 2 first; HyperOS 1 /
Android 14 has the smallest vendor gap). Capture a boot log over
adb: `adb logcat` while it tries.

**What a DSU boot proves:** the GSI boots on the m52xq vendor. It
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
   zip the Samsung GSI guides use; verified in the m51-hyperos
   record: 1,251,096 B, MD5
   `73f68347929e484351d2ca1f72360381`). Enforcing SELinux otherwise
   blocks the GSI from booting. TODO: re-verify the Permissiver
   v5 download URL and hash from its own source before flashing
   on this device; the record cited is the m51 project's, and the
   zip itself is device-independent.
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
Deleting them frees room for the 3 to 4 GB system image. The
m52xq super partition is 10,328,473,600 bytes, so the spring
`system.img` (6,232,481,792 bytes) fits after the deletions. If
`fastboot flash system` fails with a size error, the image does
not fit super as laid out. Stop and report it. Do not force it.
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
  None of them is proven by a boot alone. Note the fingerprint
  sensor on this phone is side-mounted (power button), per the
  upstream config (`google_touch_side`, config.sh line 32). Its
  exact on-screen position values are TODO: they were not
  retrieved from the upstream sidefp patch, and the m51 values
  must not be copied (different phone, different sensor
  position).

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
  calls? data?) and report it. Note the upstream UN1CA target
  carries RIL patches (`patches/ril`) and a single-SIM patch
  (`patches/singlesim`, which hex-patches `secril_config_svc`
  to set the SIM count to 1); those are UN1CA patches, not GSI
  fixes, and do not prove the GSI RIL works.

## Sources

- Upstream target config,
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/m52xq/config.sh
  (super partition size 10,328,473,600, line 14; platform SDK 33
  and shipping API level 30, lines 10-11; side fingerprint
  `google_touch_side`, line 32; HFR 60/120, lines 35, 40).
- MysticGSI spring build sizes and MD5, and Permissiver v5 size
  and MD5: verified in the m51-hyperos project record
  (`docs/gsi-verification.md` in
  https://github.com/kkisdevil/m51-hyperos). The GSI and
  Permissiver files are device-independent; the m52xq-specific
  fit check (super size above) was done from this device's own
  config. Re-check the hashes of your own downloads.
- MysticGSI downloads,
  https://sourceforge.net/projects/mystic-gsi-updates/files/HyperOS/
- DSU Sideloader, https://github.com/VegaBobo/DSU-Sideloader/releases
- TWRP device tree BoardConfig (super size agrees),
  https://github.com/paulowesll/android_device_samsung_m52xq-twrp/blob/twrp-12.1/BoardConfig.mk
  (line 101).
- Upstream RIL and single-SIM patches,
  https://github.com/salvogiangri/UN1CA/tree/sixteen/target/m52xq/patches/ril
  and
  https://github.com/salvogiangri/UN1CA/tree/sixteen/target/m52xq/patches/singlesim
