# Flash HyperOS (GSI) - Galaxy S21 Ultra 5G (SM-G998B)

Flash HyperOS on the SM-G998B as a GSI. This file is for the
SM-G998B only. Do not use it on any other model.

## What a GSI is

HyperOS on the p3s is a **GSI**: a generic system image from the
community (MysticGSI), flashed over the p3s's own stock vendor.
There is no device-specific HyperOS port for the p3s, and the only
automated HyperOS porter (XMAPort) is Xiaomi to Xiaomi only: it
needs an official HyperOS base ROM for the target, and the p3s has
none. The GSI is the candidate route. It is **not proven** on this
device yet (see "Honest status" below).

One difference from the m51 matters here: the p3s stock vendor is
Android 15 (One UI 7.0, kernel 5.4.242), the same Android version
as the HyperOS 2 GSI below. The m51 vendor is frozen at Android
12, so the m51 faces a much bigger system to vendor gap. The p3s
gap is smaller in version terms, but that does not prove the GSI
boots: the Exynos vendor, RIL, camera and fingerprint stacks are
still Samsung-specific and still untested against this GSI.

## Honest status

HyperOS has **not** booted on a p3s in front of us. The DSU trial
has not started. No confirmed HyperOS boot report for the
SM-G998B was found in research on 2026-11-25. An XDA forum
listing, "[GSI] [Android 16] [G998B] Education Flash GSI Rom For
S21 Ultra", shows GSI flashing is discussed for this model, and a
video report shows an Evolution X GSI booting on an S21 Ultra via
TWRP Install Image, but neither is a confirmed HyperOS boot, so
neither is claimed as proof here. Everything below is the
procedure to run, not a report of a working install.

## The GSI builds

The builds below are the MysticGSI builds verified in the m51
guide. They are device-independent files: the same zip is used on
any Treble device. What differs per device is the vendor underneath,
not the GSI file.

| Build | File | Size | System |
|---|---|---|---|
| `spring` (**default: HyperOS 2**) | `Hyperos-spring-15-OS2.0.204.0.VOUMIXM-AB-20251206-MysticGSI.zip` | 3.1 GB | Android 15 / HyperOS 2, Qualcomm (Snapdragon 6s Gen 3) |
| `gold` | `Hyperos-gold-15-OS3.0.1.0.VNQCNXM-AB-20251228-MysticGSI.zip` | 3.6 GB | Android 15 / HyperOS 3.0.1.0, MediaTek (Dimensity 6080) |
| `pudding` (experimental) | `Hyperos-pudding-16-OS3.0.50.2.W-AB-20260122-MysticGSI.zip` | 4.0 GB | Android 16 / HyperOS 3, Qualcomm (Snapdragon 8 Elite Gen 5) |

Get one with `bash scripts/fetch-gsi.sh` (default: spring), or
download by hand from
https://sourceforge.net/projects/mystic-gsi-updates/files/HyperOS/.

**Why spring, not gold:** gold is HyperOS 3.0.1.0 on Android 15
from a MediaTek device. A MediaTek-source GSI drags in MTK
telephony and camera jars and forces the MTK RIL shim chain.
Spring is the actual HyperOS 2 / Android 15 / Qualcomm-source
build. Verified: the spring zip is exactly 3,122,721,686 B, MD5
`3e6337d1dd850ae2d0f7d067f8dd191c`, and its `system.img` is
6,232,481,792 B of **ext4**. The DSU filesystem gate is cleared.
Verification record: the m51 guide
`../m51/flash-gsi.md` and its gsi-verification record. TODO:
re-verify these hashes from a fresh download for this device's
own record before flashing.

Super partition size for this device, from the upstream UN1CA
config, is 11,744,051,200 B, with group basic 11,739,856,896 B.
The 6,232,481,792 B system image fits inside super in raw size
terms, but the logical partition layout on p3s (which logical
partitions exist inside super, and how much room freeing them
gives) is TODO: verify it from a live `fastboot` or TWRP
partition listing before attempting the full flash. Do not assume
the m51 layout applies.

## Prereqs

1. **Unlocked bootloader** ([unlock-bootloader.md](unlock-bootloader.md)).
   The unlock wipes once, but the DSU trial itself wipes nothing.
   Back up first anyway.
2. **Back up everything.** A full flash needs a Format Data.
   Back up EFS in TWRP first.
3. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G998B** and the service
   provider software version must show your region code.
5. For the full flash: TWRP installed ([flash-twrp.md](flash-twrp.md)),
   a PC with Android platform-tools (`adb`, `fastboot`), about
   10 GB free disk, and the GSI itself (about 3 to 4 GB).
6. For the DSU trial: several GB free on the phone for the second
   system image, plus DSU Sideloader and Shizuku (below).

## Part 1: try it first (DSU trial boot, no wipe, no flash)

DSU (Dynamic System Updates) boots the GSI once as a second,
temporary system. Your installed system and data are untouched,
and a reboot takes you back. If the GSI bootloops, you lose
nothing but time. **Do this before the full flash.** DSU is
device-independent: these steps are the same shape as the m51
DSU trial, and no p3s-specific DSU difference was found in
research.

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
`vbmeta_disabled_R.tar` via Odin (USERDATA slot on this device:
see [flash-twrp.md](flash-twrp.md)) and try again. Install fails:
free space (GSI plus userdata image). Black screen or bootloop in
the GSI: the vendor gap is the prime suspect. Try the other build
(HyperOS 2 first; HyperOS 1 / Android 14 has the smallest vendor
gap). Capture a boot log over adb: `adb logcat` while it tries.

**What a DSU boot proves:** the GSI boots on the p3s vendor. It
does **not** prove the full flash works the same way (that path
also depends on TWRP/fastbootd and the super-partition layout),
and it does **not** prove SIM, camera, or fingerprint work. Those
are separate tests. On this device the fingerprint is an
ultrasonic under-display sensor
(`google_touch_display_ultrasonic` in the upstream config), which
is a known hard case for GSIs: do not assume it works.

## Part 2: full flash (TWRP plus fastbootd)

Only after a successful trial boot. **TODO: this part is NOT
verified for the p3s.** The steps below are the Samsung-generic
shape, adapted from the m51 full-flash procedure and the XDA
Samsung GSI guide, with the p3s differences marked. Do not run
Part 2 until the TODO items in it are resolved.

Samsung has no native fastboot. The fastbootd route goes through
TWRP: in TWRP, Reboot, Fastboot. That part is the same shape as
m51.

1. Do the prereqs: unlock, TWRP, Format Data. Download the GSI
   and extract `system.img` from the zip
   (`unzip Hyperos-spring-....zip`). The extracted file must be a
   `system.img`. If the archive has none at the top level, stop.
2. In TWRP: Install, flash **Permissiver v5** (SELinux-permissive
   zip the Samsung GSI guides use; verified direct URL in the m51
   gsi-verification record: 1,251,096 B, MD5
   `73f68347929e484351d2ca1f72360381`). Enforcing SELinux otherwise
   blocks the GSI from booting. TODO: confirm Permissiver v5
   applies on Android 15 / One UI 7 vendor for p3s.
3. In TWRP: Reboot, **Fastboot**. The phone boots into fastbootd.
4. TODO: the exact fastboot commands for p3s. The m51 commands
   below are **NOT** copied as p3s instructions, because the p3s
   logical partition layout is unverified:

```sh
fastboot erase system
fastboot delete-logical-partition product
fastboot delete-logical-partition system_ext
fastboot flash system system.img
fastboot -w
fastboot reboot recovery
```

   Do not run these on p3s until a live partition listing
   confirms `product` and `system_ext` exist inside super on this
   device and deleting them frees enough room for the 6.2 GB
   system image. If `fastboot flash system` fails with a size
   error, the image does not fit super as laid out. Stop and
   report it. Do not force it.
5. Alternative route, from the XDA Samsung GSI guide and a video
   report of a GSI booting on an S21 Ultra: in TWRP, Install,
   **Install Image**, select the GSI `system.img`, flash to the
   **System Image** partition. TODO: verify this route on p3s
   (which TWRP build, whether a resize is needed, whether
   Permissiver is still needed first). Do not treat the video
   report as verification: it shows Evolution X, not HyperOS.
6. In TWRP: Wipe, Format Data, type `YES`. Reboot, System.
7. First boot takes several minutes. The **setup wizard may be
   dead** (reported on other Samsung HyperOS GSIs). If it is,
   finish setup over adb (standard AOSP setup-skip commands,
   unproven on this build):

```sh
adb shell settings put secure user_setup_complete 1
adb shell settings put global device_provisioned 1
adb reboot
```

8. If it bootloops or black-screens, capture a log before wiping:
   `adb logcat -d > boot_log.txt` while the phone is up.

## Verify

- DSU trial: the GSI reaches the home screen. Record Wi-Fi,
  calls, and data: what works and what does not.
- Full flash: the phone boots into HyperOS, setup completes (over
  adb if the wizard is dead), and the build number matches the GSI
  you flashed.
- Check fingerprint, camera, SIM, and brightness separately.
  None of them is proven by a boot alone. Fingerprint is the
  highest-risk item on this device (ultrasonic sensor).

## Going back to stock

Flash the [flash-stock.md](flash-stock.md) firmware with Odin
(AP/BL/CP/CSC), then Format Data in stock recovery. That is the
full rollback. It also restores the stock vbmeta. (Knox stays
tripped. That cannot be undone.)

## Troubleshooting

- **DSU installs but will not boot into the GSI.** AVB is
  blocking the unsigned image. Flash `vbmeta_disabled_R.tar` via
  Odin (USERDATA slot on this device) and retry.
- **DSU install fails.** Free space. The GSI plus a userdata
  image needs several GB free on the phone.
- **GSI black screen or bootloop.** Vendor gap is the prime
  suspect. Try the other build (HyperOS 2 first, then HyperOS 1).
  Capture a boot log before wiping.
- **`fastboot flash system` fails with a size error.** The image
  does not fit super as laid out. Stop and report it. Do not
  force it.
- **Setup wizard dead on first GSI boot.** Finish setup over adb
  (Part 2, step 7).
- **No SIM, no calls, no data.** Expected on this vendor until
  proven otherwise. The RIL gap is the number one daily-driver
  blocker. The upstream config lists RIL features
  `onebinary embms_expway satellite_carrier` and a dual-SIM tray
  count of 2, plus eSIM support: record exactly what fails (SIM
  detected? signal? calls? data? eSIM?) and report it.
- **Fingerprint does not work.** Expected until proven otherwise
  on an ultrasonic sensor. Record it and report it.

## TODO

- TODO: DSU trial on p3s. Not started.
- TODO: p3s logical partition layout inside super (live listing).
- TODO: exact fastbootd commands for p3s, verified against that
  layout.
- TODO: TWRP Install Image to System route on p3s: verify it, do
  not rely on the Evolution X video.
- TODO: Permissiver v5 on Android 15 / One UI 7 vendor for p3s.
- TODO: re-verify the spring GSI hashes from a fresh download for
  this device's own record.
- TODO: confirm whether the "[GSI] [Android 16] [G998B] Education
  Flash GSI Rom For S21 Ultra" XDA thread contains a usable p3s
  GSI procedure, and link it with its exact thread URL once found.

## Sources

- MysticGSI spring build facts (file name, 3,122,721,686 B, MD5
  `3e6337d1dd850ae2d0f7d067f8dd191c`, system.img 6,232,481,792 B
  ext4) and Permissiver v5 (1,251,096 B, MD5
  `73f68347929e484351d2ca1f72360381`): verified in
  `../m51/flash-gsi.md` and the m51 gsi-verification record.
  These two files are device-independent; the vendor underneath
  is what differs per device.
- Super partition size 11,744,051,200 B, group basic
  11,739,856,896 B; fingerprint sensor
  `google_touch_display_ultrasonic`; RIL features and dual-SIM
  tray count 2; eSIM true: salvogiangri/UN1CA branch `sixteen`,
  `target/p3s/config.sh` lines 22 to 24, 49, 55, 75 to 77.
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/p3s/config.sh
- Samsung GSI install shape (TWRP, multidisabler, Install Image
  to System): XDA, "[GUIDE] How To: Install AOSP GSI on Samsung
  Devices **NOT FOR BEGINNERS**",
  https://xdaforums.com/t/guide-how-to-install-aosp-gsi-on-samsung-devices-not-for-beginners.4533215/
- DSU Sideloader: https://github.com/VegaBobo/DSU-Sideloader/releases
- MysticGSI downloads:
  https://sourceforge.net/projects/mystic-gsi-updates/files/HyperOS/
- GSI discussion for this model (title only, no confirmed HyperOS
  boot): XDA S21 Ultra forum index,
  https://xdaforums.com/f/samsung-galaxy-s21-ultra.12091/

## Next step

Going back: [flash-stock.md](flash-stock.md). Or flash UN1CA
instead: [flash-un1ca.md](flash-un1ca.md).
