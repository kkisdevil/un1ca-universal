# Flash HyperOS (GSI) - Galaxy S21 5G (SM-G991B)

Flash HyperOS on the SM-G991B as a GSI. This file is for the
SM-G991B only. Do not use it on any other model.

## What a GSI is

HyperOS on the o1s is a **GSI**: a generic system image from the
community (MysticGSI), flashed over the o1s's own stock vendor.
There is no device-specific HyperOS port for the o1s, and the only
automated HyperOS porter (XMAPort) is Xiaomi to Xiaomi only: it
needs an official HyperOS base ROM for the target, and the o1s has
none. The GSI is the route to try.

One difference from the m51 matters here: the o1s stock vendor is
**Android 15** (SDK 35, One UI 7.0), not Android 12. The vendor
gap to a HyperOS 2 / Android 15 GSI is therefore much smaller
than on the m51. That is a reason to expect a better result, not
a promise of one.

## Honest status

HyperOS has **not** booted on an o1s in front of us yet. The DSU
trial has not started. Everything below is the procedure to run,
not a report of a working install. Sibling evidence exists but is
not proof for this device:

- A Galaxy S21+ (t2s, same Exynos 2100 family) was shown booting
  HyperOS 3 from a MysticGSI build, flashed via TWRP fastbootd
  (Instagram demo, 2026-03-23, creator confirms MysticGSI source
  and that it is not stable for daily use).
- A One UI 7 port for the S21+ (MonsterROM 2.0) installs by
  booting TWRP, running multidisabler, rebooting to fastbootd,
  erasing super and flashing a super.img. That shows the
  TWRP-to-fastbootd path works on the Exynos 2100 S21 family.

Neither report is an o1s boot. Do not present the GSI as working
on o1s until one is recorded.

## The GSI builds

These are the same MysticGSI builds documented for the m51: the
GSI file itself is device-independent, and the sizes and hashes
below are the verified file facts from the m51 verification
record. Which build suits o1s best is TODO: the spring default
below is chosen because it matches the o1s vendor (Android 15),
not because it has booted here.

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
build, and it matches the o1s Android 15 vendor, so the smallest
system to vendor gap wins. Verified file facts for spring: the
zip is exactly 3,122,721,686 B, MD5
`3e6337d1dd850ae2d0f7d067f8dd191c`, and its `system.img` is
6,232,481,792 B of **ext4**.

**Super size check:** the o1s super partition is 11,429,478,400 B
(group basic size 11,425,284,096 B) per the upstream config. The
6.2 GB spring system.img fits that size in principle, but the
actual o1s super layout (which logical partitions exist, and
whether `product` and `system_ext` can be deleted to make room)
is TODO: verify with `fastboot getvar all` in fastbootd before
deleting anything.

## Prereqs

1. **Unlocked bootloader** ([unlock-bootloader.md](unlock-bootloader.md)).
   The unlock wipes once, but the DSU trial itself wipes nothing.
   Back up first anyway.
2. **Back up everything.** A full flash needs a Format Data.
   Back up EFS in TWRP first.
3. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G991B** and the service
   provider software version must show **AUT**.
5. For the full flash: TWRP installed ([flash-twrp.md](flash-twrp.md)),
   a PC with Android platform-tools (`adb`, `fastboot`), about
   10 GB free disk, and the GSI itself (about 3 to 4 GB).
6. For the DSU trial: several GB free on the phone for the second
   system image, plus DSU Sideloader and Shizuku (below).
7. The S21 has **no SD card slot**. Move the GSI by internal
   storage, USB OTG, or adb push.

## Part 1: try it first (DSU trial boot, no wipe, no flash)

DSU (Dynamic System Updates) boots the GSI once as a second,
temporary system. Your installed system and data are untouched,
and a reboot takes you back. If the GSI bootloops, you lose
nothing but time. **Do this before the full flash.** TODO: DSU
on Samsung hides the DSU Loader from Developer options, and DSU
on One UI 7 / Android 15 on o1s is unverified. The steps below
are the standard DSU Sideloader flow; confirm each one works on
this device and record the result.

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
GSI: the vendor gap is the prime suspect, though on o1s the
vendor is Android 15, so also suspect the Exynos RIL and the
ultrasonic fingerprint HAL. Try the other build (HyperOS 2 first;
HyperOS 1 / Android 14 has a different vendor gap). Capture a
boot log over adb: `adb logcat` while it tries.

**What a DSU boot proves:** the GSI boots on the o1s vendor. It
does **not** prove the full flash works the same way (that path
also depends on TWRP/fastbootd and the super-partition layout),
and it does **not** prove SIM, camera, or fingerprint work. Those
are separate tests. The o1s fingerprint is ultrasonic
under-display (per the upstream config); TODO: check whether it
works under any GSI at all.

## Part 2: full flash (TWRP + fastbootd)

Only after a successful trial boot. TODO: these steps are adapted
from the generic Samsung HyperOS 2 GSI guide and the S21+
fastbootd evidence. They have **not** been verified on o1s.
Do not run them blindly: verify the super layout first (see the
super size check above), and stop and report any size error.

Samsung has no native fastboot. fastbootd is reached through TWRP.

1. Do the prereqs: unlock, TWRP, Format Data. Download the GSI
   and extract `system.img` from the zip
   (`unzip Hyperos-spring-....zip`). The extracted file must be a
   `system.img`. If the archive has none at the top level, stop.
2. In TWRP: Install, flash **Permissiver v5** (SELinux-permissive
   zip the Samsung GSI guides use; verified direct URL in the m51
   verification record: 1,251,096 B, MD5
   `73f68347929e484351d2ca1f72360381`). Enforcing SELinux
   otherwise blocks the GSI from booting. TODO: confirm
   Permissiver v5 applies cleanly on the o1s Android 15 vendor.
3. In TWRP: Reboot, **Fastboot**. The phone boots into fastbootd.
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
Deleting them frees room for the 3 to 4 GB system image. TODO:
confirm both partitions exist on o1s before deleting them. If
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

Known GSI bugs reported for Samsung HyperOS 2 GSIs in general
(DroidWin guide, not o1s-specific): camera not installed (use
GCam), SIM card not working for some, no 120 Hz in settings,
brightness bug, setup dead. The 120 Hz one matters here: the o1s
panel is 120 Hz by default (per the upstream config), so if the
GSI offers no 120 Hz, try over adb:

```sh
adb shell settings put system peak_refresh_rate 120
adb shell settings put secure miui_refresh_rate 120
adb shell settings put secure user_refresh_rate 120
```

TODO: verify whether these settings work on the o1s GSI.

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

- GSI builds, spring file size and MD5, Permissiver v5 size and
  MD5, DSU and fastbootd steps: m51 docs
  (`../m51/flash-gsi.md` and its verification record); the GSI
  file facts are device-independent, the o1s steps are adapted
  and marked TODO above.
- Generic Samsung HyperOS 2 GSI steps and bug list (camera, SIM,
  120 Hz, brightness, dead setup) and the 120 Hz adb commands:
  DroidWin, "How to Flash HyperOS 2 Android 15 GSI on Samsung",
  https://droidwin.com/how-to-flash-hyperos-2-android-15-gsi-on-samsung/
- S21+ HyperOS 3 GSI boot via TWRP fastbootd (MysticGSI source,
  not daily stable): Instagram demo 2026-03-23,
  https://www.instagram.com/reel/DWN1n-iDFgY/
- S21+ fastbootd route (TWRP, multidisabler, reboot to fastbootd,
  erase super, flash super.img): XDA MonsterROM 2.0 thread,
  https://xdaforums.com/t/shared-monsterrom-2-0-port-oneui-7-beta-4-15-galaxy-s24-port-for-galaxy-s21.4720177/
- Super partition sizes (11,429,478,400 B total, 11,425,284,096 B
  group), SDK 35 vendor, ultrasonic fingerprint, 120 Hz default:
  upstream `salvogiangri/UN1CA` branch `sixteen`,
  `target/o1s/config.sh`, read live 2026-11-25.
- No device-specific HyperOS port for o1s found in search
  2026-11-25; XMAPort Xiaomi-only per the m51 docs.
