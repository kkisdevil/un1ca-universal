# Flash HyperOS (GSI) - Galaxy S21+ 5G (SM-G996B)

Flash HyperOS on the SM-G996B as a GSI. This file is for the
SM-G996B only. Do not use it on any other model.

## What a GSI is

HyperOS on the t2s is a **GSI**: a generic system image from the
community (MysticGSI), flashed over the t2s's own stock vendor.
There is no device-specific HyperOS port for the t2s found so far,
and the only automated HyperOS porter (XMAPort) is Xiaomi to
Xiaomi only: it needs an official HyperOS base ROM for the target,
and the t2s has none. The GSI is the candidate route, not a proven
one for this device.

One difference from the m51 matters here. The m51 vendor is frozen
at Android 12, so a HyperOS 2 (Android 15) GSI sits three Android
versions above its vendor. The t2s stock firmware is Android 15 /
One UI 7, so a HyperOS 2 (Android 15) GSI would sit on an Android
15 vendor. That smaller vendor gap is a reason to expect fewer
vendor-mismatch failures, but it proves nothing: no HyperOS boot
on t2s has been reported in any source found so far.

## Honest status

HyperOS has **not** booted on a t2s in front of us. The DSU trial
has not started. No t2s HyperOS boot report (Telegram or forum)
was found in search on 2026-11-25. Everything below is the
procedure to run, not a report of a working install. The DSU
trial in Part 1 is the first thing to do; do not skip it for a
full flash.

## The GSI builds

The GSI file, sizes, and hashes below are device-independent:
they are the same MysticGSI builds used for the m51, verified
there. They are reused here only because a GSI is generic by
definition; the t2s-specific question (does it boot on the
Exynos 2100 vendor?) is still open.

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
build. The spring zip is exactly 3,122,721,686 B, MD5
`3e6337d1dd850ae2d0f7d067f8dd191c`, and its `system.img` is
6,232,481,792 B of **ext4**. The DSU filesystem gate is cleared
on that basis. (Verified for the m51; cited from the m51 GSI
guide.)

TODO: the donor-SoC question for t2s. Spring is a Qualcomm-source
GSI and the t2s vendor is Exynos 2100. The m51 is also a
Qualcomm-vendor phone, so the spring choice was natural there.
On t2s, whether a Qualcomm-source GSI or another donor works
better on an Exynos vendor is untested. Start with spring (the
default), record what fails, and only then try another build.
Do not present spring as the proven t2s choice.

## Prereqs

1. **Unlocked bootloader** ([unlock-bootloader.md](unlock-bootloader.md)).
   The unlock wipes once, but the DSU trial itself wipes nothing.
   Back up first anyway.
2. **Back up everything.** A full flash needs a Format Data.
   Back up EFS in TWRP first.
3. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G996B** (or SM-G996B/DS).
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

TODO: DSU has not been tried on t2s in this repo. The steps below
are the device-independent DSU procedure from the m51 guide.
Exynos-specific DSU behaviour (AVB, vbmeta, dynamic-partition
handling on this device) is unverified. If a step fails on t2s,
stop, record the exact failure, and do not force it.

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
into it: AVB is blocking the unsigned image. On t2s the vbmeta
step is the one in flash-twrp.md (the XDA thread's
`vbmeta_disabled_R.tar`, with the conflict note there), but
whether that is what DSU needs on this device is TODO. Install
fails: free space (GSI plus userdata image). Black screen or
bootloop in the GSI: the vendor gap is the prime suspect even on
an Android 15 vendor, because the vendor is Exynos and the GSI
donor is Qualcomm. Try the other build (HyperOS 2 first; HyperOS
1 / Android 14 has the smallest vendor gap on paper, but no
HyperOS 1 MysticGSI build is listed in the table above, so TODO:
find one before trying that route). Capture a boot log over adb:
`adb logcat` while it tries.

**What a DSU boot proves:** the GSI boots on the t2s vendor. It
does **not** prove the full flash works the same way (that path
also depends on TWRP/fastbootd and the super-partition size), and
it does **not** prove SIM, camera, or fingerprint work. Those are
separate tests. Fingerprint on t2s is ultrasonic under-display
(google_touch_display_ultrasonic in the UN1CA config); it is the
least likely thing to work out of the box on a GSI, and it is
TODO to test.

## Part 2: full flash (TWRP + fastbootd)

Only after a successful trial boot.

TODO: Part 2 has not been run on t2s. Samsung phones have no
native fastboot, so the fastbootd route through TWRP is the
candidate, as on m51. Every step below is copied from the m51
procedure and marked to verify on t2s; do not run it blindly.

1. Do the prereqs: unlock, TWRP, Format Data. Download the GSI
   (`scripts/fetch-gsi.sh`) and extract `system.img` from the zip
   (`unzip Hyperos-spring-....zip`). The extracted file must be a
   `system.img`. If the archive has none at the top level, stop.
2. In TWRP: Install, flash **Permissiver v5** (SELinux-permissive
   zip the Samsung GSI guides use; verified direct URL in the
   m51 GSI verification record: 1,251,096 B, MD5
   `73f68347929e484351d2ca1f72360381`). Enforcing SELinux
   otherwise blocks the GSI from booting. TODO: confirm
   Permissiver v5 is the right SELinux step for t2s on Android
   15; it is verified only for the m51 procedure.
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
verify the super layout on t2s before running this. The UN1CA
config gives TARGET_SUPER_PARTITION_SIZE 11429478400 and
TARGET_GROUP_BASIC_SIZE 11425284096, and the spring
`system.img` is 6,232,481,792 B, so the image fits numerically
inside super, but whether `product` and `system_ext` exist as
deletable logical partitions on this device, and what happens
to the rest of super if they are deleted, is unverified. If
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
  None of them is proven by a boot alone. On t2s, fingerprint is
  ultrasonic under-display and eSIM is present (UN1CA config:
  eSIM true, dual-SIM tray count 2); both are TODO to test on
  the GSI.

## Going back to stock

Flash the [flash-stock.md](flash-stock.md) firmware with Odin
(AP/BL/CP/CSC), then Format Data in stock recovery. That is the
full rollback. It also restores the stock vbmeta. (Knox stays
tripped. That cannot be undone.)

## Troubleshooting

- **DSU installs but will not boot into the GSI.** AVB is
  blocking the unsigned image. See the vbmeta note in Part 1.
- **DSU install fails.** Free space. The GSI plus a userdata
  image needs several GB free on the phone.
- **GSI black screen or bootloop.** Vendor gap is the prime
  suspect (Exynos vendor, Qualcomm-source GSI). Try the other
  build (HyperOS 2 first). Capture a boot log before wiping.
- **`fastboot flash system` fails with a size error.** The image
  does not fit super as laid out. Stop and report it. Do not
  force it.
- **Setup wizard dead on first GSI boot.** Finish setup over adb
  (Part 2, step 6).
- **No SIM, no calls, no data.** Expected on this vendor until
  proven otherwise. The RIL gap is the number one daily-driver
  blocker. The UN1CA config lists the t2s RIL as
  "onebinary embms_expway satellite_carrier"; whether any of that
  survives under a GSI is TODO. Record exactly what fails (SIM
  detected? signal? calls? data?) and report it.

## Sources

- GSI builds, spring zip size and MD5, spring `system.img` size,
  Permissiver v5 size and MD5, DSU Sideloader and Shizuku steps,
  fastbootd commands, and guide structure:
  [../m51/flash-gsi.md](../m51/flash-gsi.md) (device-independent
  GSI facts verified for the m51; t2s-specific steps are TODO).
- MysticGSI download listing:
  https://sourceforge.net/projects/mystic-gsi-updates/files/HyperOS/
- DSU Sideloader releases:
  https://github.com/VegaBobo/DSU-Sideloader/releases
- Upstream UN1CA `target/t2s/config.sh` (salvogiangri/UN1CA,
  branch sixteen, UN1CA 3.2.1): super partition sizes,
  fingerprint google_touch_display_ultrasonic, eSIM true,
  dual-SIM tray count 2, RIL "onebinary embms_expway
  satellite_carrier". Read live 2026-11-25.
- No t2s HyperOS boot report found in web search on 2026-11-25;
  that absence is the basis for "Honest status".

## TODO

- Run the DSU trial on t2s and record the result.
- Confirm the DSU vbmeta/AVB step for t2s.
- Verify the super layout (`product`, `system_ext`) on t2s
  before Part 2.
- Confirm Permissiver v5 is the right SELinux step for t2s.
- Decide whether spring (Qualcomm-source) is the right donor
  for an Exynos vendor, or whether another donor works better.
- Test fingerprint (ultrasonic), eSIM, SIM, calls, data, camera,
  and brightness on the GSI.
- Find a HyperOS 1 / Android 14 MysticGSI build if the
  smallest-gap route is needed.
