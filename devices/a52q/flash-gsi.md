# Flash HyperOS (GSI) - Galaxy A52 (SM-A525F)

Flash HyperOS on the SM-A525F as a GSI. This file is for the
SM-A525F only. Do not use it on any other model.

## What a GSI is

HyperOS on the a52q is a **GSI**: a generic system image from the
community (MysticGSI), flashed over the a52q's own stock vendor.
There is no device-specific HyperOS port for the a52q, and the only
automated HyperOS porter (XMAPort) is Xiaomi to Xiaomi only: it
needs an official HyperOS base ROM for the target, and the a52q
has none. The GSI is the route. Sibling evidence: the A52 5G
(a52xq, a different model) has an XDA tutorial for installing any
treble GSI with a custom vbmeta and a fastboot recovery, and
reports of Pixel Experience and Flyme GSIs booting on it. That is
sibling evidence for the family method, not proof for the a52q.

One advantage over the m51: the a52q stock firmware is Android 14
(SDK 34), so the vendor-to-system gap to an Android 15 GSI is
smaller than the m51's Android 12 vendor gap. That is a reason to
expect fewer vendor-mismatch failures, not a guarantee.

## Honest status

HyperOS has **not** booted on an a52q in front of us yet. The DSU
trial has not started. No a52q-specific HyperOS boot report was
found while writing this guide. Everything below is the procedure
to run, not a report of a working install.

## The GSI builds

The GSI files are device-independent: the same files the m51
project verified are the files for the a52q. Sizes and hashes
below are from that verification record.

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
build. Verified in the m51 record: the spring zip is exactly
3,122,721,686 B, MD5
`3e6337d1dd850ae2d0f7d067f8dd191c`, and its `system.img` is
6,232,481,792 B of **ext4**.

**Super partition fit check (unresolved):** the UN1CA target
config for the a52q gives `TARGET_SUPER_PARTITION_SIZE` of
10,385,096,704 bytes (about 9.67 GiB), while the TWRP device tree
for the a52q lists a super partition size of 7,730,906,700 bytes.
The two sources disagree. TODO: read the real super size from the
device (`adb shell` / TWRP partition listing) before the full
flash, and record which value is right. The 6,232,481,792 byte
system image fits either size after `product` and `system_ext`
are deleted, but only the on-device check settles it. If
`fastboot flash system` fails with a size error, stop and report
it. Do not force it.

## Prereqs

1. **Unlocked bootloader** ([unlock-bootloader.md](unlock-bootloader.md)).
   The unlock wipes once, but the DSU trial itself wipes nothing.
   Back up first anyway.
2. **Back up everything.** A full flash needs a Format Data.
   Back up EFS in TWRP first.
3. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A525F** and the service
   provider software version must show **EUX**. Also confirm
   Treble support on the phone itself:
   `adb shell getprop ro.treble.enabled` should print `true`.
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
GSI: the Android 14 vendor vs Android 15 system gap is the prime
suspect. Try the other build (HyperOS 2 first; HyperOS 1 / Android
14 has the smallest vendor gap). Capture a boot log over adb:
`adb logcat` while it tries.

**What a DSU boot proves:** the GSI boots on the a52q vendor. It
does **not** prove the full flash works the same way (that path
also depends on TWRP/fastbootd and the super-partition size), and
it does **not** prove SIM, camera, or fingerprint work. Those are
separate tests. The fingerprint sensor on this device is an
in-display optical sensor, which is a known GSI risk: test it
separately and do not assume it works because the GSI booted.

## Part 2: full flash (TWRP + fastbootd)

Only after a successful trial boot.

1. Do the prereqs: unlock, TWRP, Format Data. Download the GSI
   and extract `system.img` from the zip
   (`unzip Hyperos-spring-....zip`). The extracted file must be a
   `system.img`. If the archive has none at the top level, stop.
2. In TWRP: Install, flash **Permissiver v5** (SELinux-permissive
   zip the Samsung GSI guides use; verified values from the m51
   record: 1,251,096 B, MD5 `73f68347929e484351d2ca1f72360381`).
   Enforcing SELinux otherwise blocks the GSI from booting.
   TODO: Permissiver has not been confirmed on the a52q itself.
   If the GSI boots without it, record that here.
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
fit super as laid out. Stop and report it. Do not force it. (See
the super size discrepancy in "The GSI builds" above.)
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
  None of them is proven by a boot alone. The in-display optical
  fingerprint is the highest-risk item on this device.

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
  force it. Record the real super size from the device first (see
  "The GSI builds").
- **Setup wizard dead on first GSI boot.** Finish setup over adb
  (Part 2, step 6).
- **No SIM, no calls, no data.** Expected on this vendor until
  proven otherwise. The RIL gap is the number one daily-driver
  blocker. Record exactly what fails (SIM detected? signal?
  calls? data?) and report it.
- **Fingerprint does not work on the GSI.** Expected risk on this
  device: the sensor is in-display optical. Record it as a
  separate test result, not as a failed boot.

## Sources

- UN1CA target config, `target/a52q/config.sh` in
  salvogiangri/UN1CA branch `sixteen`: line 10 (SDK 34, Android
  14), line 13 (super partition 10,385,096,704 bytes), line 31
  (in-display optical fingerprint
  `google_touch_display_optical,settings=3`):
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/a52q/config.sh
- TWRP device tree super partition size 7,730,906,700 bytes:
  `BoardConfig.mk` in
  https://github.com/TeamWin/android_device_samsung_a52q
  (branch android-12.1). Disagrees with the UN1CA config value
  above: flagged TODO, verify on the device.
- GSI builds, sizes, and hashes (device-independent files,
  verified in the m51 record) and Permissiver v5 values:
  https://github.com/kkisdevil/m51-hyperos/blob/main/docs/gsi-verification.md
  (m51 project record; the GSI files themselves are the same
  files for any device).
- MysticGSI downloads:
  https://sourceforge.net/projects/mystic-gsi-updates/files/HyperOS/
- Sibling-device GSI method (A52 5G, a52xq, not a52q): XDA
  tutorial for installing any treble GSI on the Galaxy A52 5G,
  https://xdaforums.com/t/tutorial-how-to-directly-install-any-custom-treble-gsi-on-galaxy-a52-5g-whit-even-lastest-oneui-5-1.4616913/
- DSU Sideloader: https://github.com/VegaBobo/DSU-Sideloader/releases
- TODO: HyperOS boot on an a52q (DSU trial not started); real
  super partition size on the device; Permissiver need on the
  a52q; fingerprint, camera, and RIL results on the GSI.
