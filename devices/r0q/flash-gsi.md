# Flash HyperOS (GSI) - Galaxy S22 (SM-S901E)

Flash HyperOS on the SM-S901E as a GSI. This file is for the
Galaxy S22 (Snapdragon), codename `r0q`, models SM-S901E,
SM-S901N, and SM-S9010 only. Do not use it on the Exynos Galaxy
S22 (SM-S901B, codename `r0s`) or on the Galaxy S22 Ultra
(SM-S908x, codename `b0q`).

## What a GSI is

HyperOS on the r0q is a **GSI**: a generic system image from the
community, flashed over the r0q's own stock vendor. There is no
device-specific HyperOS port for the r0q, and the only automated
HyperOS porter (XMAPort) is Xiaomi to Xiaomi only: it needs an
official HyperOS base ROM for the target, and the r0q has none.
The GSI is the only route.

One difference from older Samsung GSI targets matters here: the
r0q's stock vendor is current (Android 16, One UI 8.0, kernel
5.10), not frozen years behind. That narrows the system to vendor
gap, but it does not remove it. The vendor is still Samsung's,
and the GSI is still generic.

## Honest status

HyperOS has **not** booted on an r0q in front of us yet. The DSU
trial has not started. Everything below is the procedure to run,
not a report of a working install.

## The GSI builds

TODO: pick and verify the default build for this device before
any flash. The candidate source is the MysticGSI HyperOS builds
at https://sourceforge.net/projects/mystic-gsi-updates/files/HyperOS/
(the same source the m51 guide uses). Because the r0q vendor is
Android 16, the candidate is an Android 16 HyperOS GSI, not the
Android 15 build that fits older vendors. Record here, before
flashing: the exact file name, its size in bytes, its MD5, the
`system.img` size and filesystem, and why it was chosen. Do not
copy the m51 build table: those builds were chosen and verified
against the m51's Android 12 vendor, which is a different gap.

The r0q super partition is 12,058,624,000 B (about 12.06 GB) with
12,054,429,696 B of dynamic partitions, per the upstream
`target/r0q/config.sh`. A 3 to 4 GB system image fits in principle
once the other logical partitions are trimmed, but the actual
super layout on this device is unverified. See Part 2.

## Prereqs

1. **Unlocked bootloader** ([unlock-bootloader.md](unlock-bootloader.md)).
   The unlock wipes once, but the DSU trial itself wipes nothing.
   Back up first anyway.
2. **Back up everything.** A full flash needs a Format Data.
   Back up EFS in TWRP first.
3. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-S901E** (or SM-S901N or
   SM-S9010).
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
2. Get the GSI on the phone (download it, then copy the zip, or
   the extracted `system.img`, to the phone). DSU needs several
   GB free on the phone for the second system image.
3. Install **DSU Sideloader** by VegaBobo, from
   [F-Droid](https://f-droid.org/) or
   https://github.com/VegaBobo/DSU-Sideloader/releases, and
   **Shizuku** (Play Store) for the easiest mode if the phone is
   not rooted. Root also works. Plain ADB mode works too but needs
   a PC command.
4. Open DSU Sideloader, give it read/write permission to a folder
   you create (it stores temporary files such as the extracted
   GSI), select the GSI (`.gz`, `.xz`, `.img`, or `.zip`: if the app
   rejects the zip, extract `system.img` first and select the
   `.img`). Do not change the GSI file size; let the app handle
   it. Optionally set the userdata size for the dynamic system.
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
`vbmeta_disabled.tar` via Odin (see
[flash-twrp.md](flash-twrp.md)) and try again. Install fails: free
space (GSI plus userdata image). Black screen or bootloop in the
GSI: the system to vendor gap is the prime suspect. Try another
build (an Android 16 build first, to match this vendor). Capture
a boot log over adb: `adb logcat` while it tries.

**What a DSU boot proves:** the GSI boots on the r0q vendor. It
does **not** prove the full flash works the same way (that path
also depends on TWRP/fastbootd and the super-partition layout),
and it does **not** prove SIM, camera, or fingerprint work. Those
are separate tests. The r0q fingerprint sensor is an ultrasonic
in-display sensor (`google_touch_display_ultrasonic` in the
upstream config): do not expect it to work under a GSI until
proven.

## Part 2: full flash (TWRP + fastbootd)

Only after a successful trial boot.

1. Do the prereqs: unlock, TWRP, Format Data. Download the GSI
   and extract `system.img` from the zip. The extracted file must
   be a `system.img`. If the archive has none at the top level,
   stop.
2. In TWRP: Install, flash a SELinux-permissive zip (the Samsung
   GSI guides use Permissiver). TODO: verify the Permissiver
   version, URL, size, and MD5 for this device before flashing
   one. Do not copy another device's verified Permissiver values:
   they were verified for that device's build, not this one.
   Enforcing SELinux otherwise blocks the GSI from booting.
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

TODO: confirm the r0q super layout before running the
`delete-logical-partition` commands. `product` and `system_ext`
are the usual logical partitions to delete on Samsung dynamic
partition devices, but the actual partition list on this device
has not been checked. If `fastboot flash system` fails with a size
error, the image does not fit super as laid out. Stop and report
it. Do not force it.
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

A newer alternative recovery exists for this exact model: the
March 2026 XDA how-to "[RECOVERY] [SM-S901E] FastbootD for GSI
ROMS and Root" by AlexisGSM, a FastbootD custom recovery for the
SM-S901E meant to streamline GSI installs and Magisk setup. We
have not read the full thread or used it. If TWRP fastbootd gives
trouble, read that thread in the XDA Galaxy S22 forum
(https://xdaforums.com/f/12511/) before switching recoveries.

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
  suspect. Try another build. Capture a boot log before wiping.
- **`fastboot flash system` fails with a size error.** The image
  does not fit super as laid out. Stop and report it. Do not
  force it. Check the super layout first (Part 2, step 4 TODO).
- **Setup wizard dead on first GSI boot.** Finish setup over adb
  (Part 2, step 6).
- **No SIM, no calls, no data.** Expected on this vendor until
  proven otherwise. The RIL gap is the number one daily-driver
  blocker. Record exactly what fails (SIM detected? signal?
  calls? data?) and report it.

## Sources

- Super partition sizes: `target/r0q/config.sh` lines 24-26
  (`TARGET_SUPER_PARTITION_SIZE=12058624000`,
  `TARGET_QTI_DYNAMIC_PARTITIONS_SIZE=12054429696`), in
  https://github.com/salvogiangri/UN1CA/tree/sixteen/target/r0q
- Fingerprint sensor type: `target/r0q/config.sh` line 61
  (`TARGET_FINGERPRINT_CONFIG_SENSOR="google_touch_display_ultrasonic"`)
- Stock vendor version (Android 16, kernel 5.10): SamFrew
  SM-S901E firmware records, e.g.
  https://samfrew.com/download/Galaxy__S22__/s53a/TMB/S901USQU8GYJ1/S901UOYN8GYJ1
  (kernel `5.10.236-android12-9-31998796-abS901USQU8GYJ1`)
- FastbootD recovery thread for SM-S901E: XDA Galaxy S22 forum
  index, https://xdaforums.com/f/12511/ ("[RECOVERY] [SM-S901E]
  FastbootD for GSI ROMS and Root", AlexisGSM, Mar 22, 2026;
  thread title only, contents not read)
- DSU Sideloader: https://github.com/VegaBobo/DSU-Sideloader/releases
- MysticGSI source:
  https://sourceforge.net/projects/mystic-gsi-updates/files/HyperOS/
- TODO: the default GSI build for r0q (file, size, MD5,
  `system.img` size and filesystem) is not chosen or verified.
  The Permissiver version for this device is not verified. The
  r0q super layout (which logical partitions exist) is not
  checked. No DSU trial has run.
