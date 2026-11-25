# Flash HyperOS (GSI) - Galaxy S22+ (Snapdragon) (SM-S906E)

Flash HyperOS on the Snapdragon Galaxy S22+ (g0q) as a GSI. This
file is for **SM-S906E, SM-S906N, SM-S9060** only. Do not use it
on any other model. SM-S906B is the Exynos model (g0s) and nothing
here applies to it.

## What a GSI is

HyperOS on g0q is a **GSI**: a generic system image from the
community (MysticGSI), flashed over the g0q's own stock vendor.
There is no device-specific HyperOS port for g0q, and the only
automated HyperOS porter (XMAPort) is Xiaomi to Xiaomi only: it
needs an official HyperOS base ROM for the target, and g0q has
none. The GSI is the route to try.

One difference from older Samsung phones matters here: g0q's
vendor is new. The stock firmware is Android 16 / One UI 8.0
(SDK 36, shipping API 31), so the vendor gap to a HyperOS 2 /
Android 15 GSI is much smaller than on a phone whose vendor is
frozen at Android 12. That is a reason to expect the trial to go
further, not a proof that it boots.

## Honest status

HyperOS has **not** booted on a g0q in front of us. The DSU trial
has not started. No g0q-specific HyperOS boot report was found in
search. Everything below is the procedure to run, not a report of
a working install.

## The GSI builds

These are the same MysticGSI files used for other devices in this
project, so the file facts below are cited to the verification
record where they were checked, not re-measured for g0q.

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
build. Verified file facts for spring: the zip is exactly
3,122,721,686 B, MD5
`3e6337d1dd850ae2d0f7d067f8dd191c`, and its `system.img` is
6,232,481,792 B of **ext4**.

**Fit check for g0q:** the upstream target config gives the super
partition as 12,058,624,000 B and the QTI dynamic partitions group
as 12,054,429,696 B. A 6,232,481,792 B system image fits inside
that super layout on paper, after the logical partitions below are
deleted. TODO: confirm the live super layout on a g0q phone before
flashing, because the config numbers are the UN1CA target values,
not a measurement from a device.

## Prereqs

1. **Unlocked bootloader** ([unlock-bootloader.md](unlock-bootloader.md)).
   The unlock wipes once, but the DSU trial itself wipes nothing.
   Back up first anyway. US models (SM-S906U, SM-S906U1,
   SM-S906W) cannot unlock and cannot use this file.
2. **Back up everything.** A full flash needs a Format Data.
   Back up EFS in TWRP first if TWRP is installed.
3. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-S906E** (or SM-S906N, or
   SM-S9060).
5. For the full flash: TWRP installed ([flash-twrp.md](flash-twrp.md)),
   a PC with Android platform-tools (`adb`, `fastboot`), about
   10 GB free disk, and the GSI itself (about 3 to 4 GB).
   **The full flash is blocked today**: no working TWRP exists
   for g0q (see [flash-twrp.md](flash-twrp.md)). The DSU trial
   below does not need TWRP.
6. For the DSU trial: several GB free on the phone for the second
   system image, plus DSU Sideloader and Shizuku (below).

## Part 1: try it first (DSU trial boot, no wipe, no flash)

DSU (Dynamic System Updates) boots the GSI once as a second,
temporary system. Your installed system and data are untouched,
and a reboot takes you back. If the GSI bootloops, you lose
nothing but time. **Do this before the full flash.**

1. Unlocked bootloader (prereq 1 above). Back up first anyway.
2. Get the GSI on the phone (`scripts/fetch-gsi.sh`, then copy the
   zip, or the extracted `system.img`, to the phone). DSU needs
   several GB free on the phone for the second system image.
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
GSI: the vendor to system gap is the prime suspect. Try the other
build (HyperOS 2 first; HyperOS 1 / Android 14 has the smallest
vendor gap). Capture a boot log over adb: `adb logcat` while it
tries.

**What a DSU boot proves:** the GSI boots on the g0q vendor. It
does **not** prove the full flash works the same way (that path
also depends on TWRP/fastbootd and the super-partition size), and
it does **not** prove SIM, camera, or fingerprint work. Those are
separate tests.

## Part 2: full flash (TWRP + fastbootd)

Blocked until a working TWRP exists for g0q. Do not attempt it
without TWRP. The steps, once TWRP is available:

1. Do the prereqs: unlock, TWRP, Format Data. Download the GSI
   (`scripts/fetch-gsi.sh`) and extract `system.img` from the zip
   (`unzip Hyperos-spring-....zip`). The extracted file must be a
   `system.img`. If the archive has none at the top level, stop.
2. In TWRP: Install, flash **Permissiver v5** (SELinux-permissive
   zip the Samsung GSI guides use). TODO: record the verified URL,
   size, and MD5 for the Permissiver build used on g0q before
   flashing. Enforcing SELinux otherwise blocks the GSI from
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
TODO: confirm the g0q super layout (which logical partitions
exist) from a live device before running these deletes.
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
  None of them is proven by a boot alone. Note the g0q
  fingerprint sensor is an ultrasonic in-display sensor
  (`google_touch_display_ultrasonic` in the upstream target
  config); whether it works under a GSI is unproven.

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

- No device-specific HyperOS port and no g0q boot report: web
  searches for HyperOS GSI on g0q / S906E returned no
  device-specific report (only generic Samsung DSU guides).
- XMAPort is Xiaomi to Xiaomi only: recorded in the project's
  m51 GSI guide,
  https://github.com/kkisdevil/m51-hyperos/blob/main/docs/devices/m51/flash-gsi.md
- GSI builds, spring as default, spring zip size and MD5 and
  system.img size: the project's GSI verification record,
  https://github.com/kkisdevil/m51-hyperos/blob/main/docs/gsi-verification.md
  (the same downloadable MysticGSI files).
- Super partition size 12,058,624,000 B and QTI dynamic
  partitions size 12,054,429,696 B; SDK 36; shipping API 31;
  fingerprint sensor `google_touch_display_ultrasonic`:
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/g0q/config.sh
  lines 17, 19, 24, 26, 61.
- DSU Sideloader and Shizuku flow, sticky mode
  `adb shell gsi_tool enable`: DSU Sideloader,
  https://github.com/VegaBobo/DSU-Sideloader/releases and
  Android DSU docs,
  https://developer.android.google.cn/topic/dsu?hl=en&authuser=3
- TWRP blocked status: [flash-twrp.md](flash-twrp.md).

## TODO

- Run the DSU trial on a g0q phone and record the result.
- Confirm the live super layout on g0q before Part 2.
- Record the verified Permissiver build (URL, size, MD5) for g0q.
- Confirm the fingerprint, camera, SIM, and brightness behaviour
  under the GSI once it boots.
