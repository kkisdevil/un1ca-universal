# Flash HyperOS (GSI) - Galaxy S21 FE 5G (SM-G990E)

Flash HyperOS on the SM-G990E as a GSI. This file is for the
SM-G990E only (Exynos S21 FE 5G, codename r9s). Do not use it on
the Snapdragon FE (SM-G990B, SM-G990B2, SM-G990U) or any other
model.

## What a GSI is on this device

HyperOS on the r9s is a **GSI**: a generic system image from the
community (MysticGSI), flashed over the r9s's own stock vendor.
There is no device-specific HyperOS port for the r9s, and the only
automated HyperOS porter (XMAPort) is Xiaomi to Xiaomi only: it
needs an official HyperOS base ROM for the target, and the r9s has
none.

The GSI route itself is real on this device. An XDA guide,
"[GSI] [A13] Pixel Experience Plus for Galaxy S21 FE 5G
(Snapdragon/Exynos)",
https://xdaforums.com/t/gsi-a13-pixel-experience-plus-for-galaxy-s21-fe-5g-snapdragon-exynos.4547027/
covers GSI flashing on the S21 FE for both SoCs and notes that
OrangeFox Recovery is provided for the Exynos SoC. So GSIs do boot
on the r9s through a custom recovery. But that guide is for Pixel
Experience Plus on Android 13, not HyperOS, and no HyperOS GSI
boot on the r9s was found in this pass.

## Honest status

HyperOS has **not** booted on an r9s in front of us. The DSU trial
has not started. Everything below is the procedure to run, not a
report of a working install.

## The GSI builds

| Build | File | Size | System |
|---|---|---|---|
| `spring` (**default: HyperOS 2**) | `Hyperos-spring-15-OS2.0.204.0.VOUMIXM-AB-20251206-MysticGSI.zip` | 3,122,721,686 B | Android 15 / HyperOS 2, Qualcomm (Snapdragon 6s Gen 3) donor |
| `gold` | `Hyperos-gold-15-OS3.0.1.0.VNQCNXM-AB-20251228-MysticGSI.zip` | 3.6 GB | Android 15 / HyperOS 3.0.1.0, MediaTek (Dimensity 6080) donor |
| `pudding` (experimental) | `Hyperos-pudding-16-OS3.0.50.2.W-AB-20260122-MysticGSI.zip` | 4.0 GB | Android 16 / HyperOS 3, Qualcomm (Snapdragon 8 Elite Gen 5) donor |

Get one by hand from
https://sourceforge.net/projects/mystic-gsi-updates/files/HyperOS/.

These file facts (names, spring size and MD5, system image size
and filesystem) are device-independent and are reused from the
verified m51 record: the spring zip is exactly 3,122,721,686 B,
MD5 `3e6337d1dd850ae2d0f7d067f8dd191c`, and its `system.img` is
6,232,481,792 B of **ext4**. Verification record:
https://github.com/kkisdevil/m51-hyperos/blob/main/docs/gsi-verification.md

**Why spring, and the Exynos warning:** spring is the actual
HyperOS 2 / Android 15 build and the smallest system to vendor
gap of the three. But the r9s vendor is Exynos 2100, not
Qualcomm: a Qualcomm-source GSI over an Exynos vendor is a bigger
gap than the same GSI over the m51's Snapdragon vendor, and no
r9s boot report exists to close that gap. Spring stays the default
because it is the verified HyperOS 2 build, not because it is
proven on this device. Gold (MediaTek source) drags in MTK
telephony and camera jars and is not a better fit for Exynos
either. TODO: record the first r9s boot result for any of these
builds before recommending one over the others.

**Super fit check:** the r9s super partition is 11,429,478,400 B
with group basic size 11,425,284,096 B (upstream
`target/r9s/config.sh`). The spring `system.img` is 6,232,481,792
B, so the raw numbers leave room. But the logical partition layout
on the r9s (which logical partitions exist inside super and how
much room freeing them gains) is TODO: it was not verified in this
pass. Do not assume the m51 layout applies.

## Prereqs

1. **Unlocked bootloader** ([unlock-bootloader.md](unlock-bootloader.md)).
   The unlock wipes once, but the DSU trial itself wipes nothing.
   Back up first anyway. Remember: a phone already on One UI 8
   cannot be unlocked at all.
2. **Back up everything.** A full flash needs a Format Data.
   Back up EFS in the custom recovery first.
3. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G990E** and the service
   provider software version must show your region (for example
   THL or INS).
5. For the full flash: a custom recovery installed
   ([flash-twrp.md](flash-twrp.md)), a PC with Android
   platform-tools (`adb`, `fastboot`), about 10 GB free disk, and
   the GSI itself (about 3 to 4 GB).
6. For the DSU trial: several GB free on the phone for the second
   system image, plus DSU Sideloader and Shizuku (below).

## Part 1: try it first (DSU trial boot, no wipe, no flash)

DSU (Dynamic System Updates) boots the GSI once as a second,
temporary system. Your installed system and data are untouched,
and a reboot takes you back. If the GSI bootloops, you lose
nothing but time. **Do this before the full flash.**

1. Unlocked bootloader (prereq 1 above). Back up first anyway.
2. Get the GSI on the phone (download the zip, then copy the zip,
   or the extracted `system.img`, to the phone). DSU needs
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
`vbmeta_disabled.tar` via Odin (see [flash-twrp.md](flash-twrp.md))
and try again. Install fails: free space (GSI plus userdata
image). Black screen or bootloop in the GSI: the vendor gap is the
prime suspect (Exynos 2100 vendor under an Android 15/16 system).
Try the other build (HyperOS 2 first; HyperOS 1 / Android 14 has
the smallest vendor gap). Capture a boot log over adb:
`adb logcat` while it tries.

**What a DSU boot proves:** the GSI boots on the r9s vendor. It
does **not** prove the full flash works the same way (that path
also depends on the recovery/fastbootd route and the
super-partition layout), and it does **not** prove SIM, camera, or
fingerprint work. Those are separate tests. TODO: no DSU boot has
been attempted on the r9s yet, so even the DSU steps above are
unproven on this device, not just the full flash.

## Part 2: full flash (TODO, not verified for this device)

Only after a successful trial boot.

TODO: the full-flash steps for the r9s are NOT written here yet,
because the Exynos route could not be verified in this pass. Do
not copy the m51 fastboot commands blindly: the m51 is a
Qualcomm phone with a different recovery and a different super
layout, and its commands were verified for the m51 only. What
must be established on the r9s before Part 2 can be written:

- TODO: does the recovery for this device (afaneh92 TWRP from
  2022, or OrangeFox R11.3/R12.1) offer a fastbootd mode
  ("Reboot to Fastboot")? Samsung has no native fastboot, so the
  whole full flash depends on this. If no fastbootd exists, the
  full flash needs a different route (for example flashing the
  system image from the recovery itself), which must be found and
  verified first.
- TODO: the r9s logical partition layout inside super: which
  logical partitions exist (product, system_ext, others) and
  which must be deleted to fit the 6,232,481,792 B system image.
- TODO: Permissiver step for this device. The SELinux-permissive
  zip the Samsung GSI guides use is Permissiver v5 (1,251,096 B,
  MD5 `73f68347929e484351d2ca1f72360381`, verified in the m51
  record at
  https://github.com/kkisdevil/m51-hyperos/blob/main/docs/gsi-verification.md).
  Whether the r9s needs it, and whether it works on this vendor,
  is unproven.
- TODO: Format Data step and first boot notes for this device.
- TODO: setup wizard behaviour on this device (dead? working?)
  and the setup-skip commands if needed.
- TODO: boot log capture for this device.

## Verify

- DSU trial: the GSI reaches the home screen. Record Wi-Fi,
  calls, and data: what works and what does not.
- Full flash: the phone boots into HyperOS, setup completes (over
  adb if the wizard is dead), and the build number matches the GSI
  you flashed.
- Check fingerprint, camera, SIM, and brightness separately.
  None of them is proven by a boot alone. On this device the
  fingerprint is an **optical** under-display sensor (upstream
  config.sh: `google_touch_display_optical,settings=3`), unlike
  the ultrasonic sensor on the other S21 models, so test it
  separately and do not assume another S21's fingerprint result
  applies. There is no eSIM on this device (config.sh: eSIM
  false), so there is nothing eSIM to test.

## Going back to stock

Flash the [flash-stock.md](flash-stock.md) firmware with Odin
(AP/BL/CP/CSC), then Format Data in stock recovery. That is the
full rollback. It also restores the stock vbmeta. (Knox stays
tripped. That cannot be undone.) Note the anti-rollback rule: if
you went to an Android 16 stock build first, you cannot go back
to the GYI3 Android 15 bootloader afterwards.

## Troubleshooting

- **DSU installs but will not boot into the GSI.** AVB is
  blocking the unsigned image. Flash `vbmeta_disabled.tar` via
  Odin and retry.
- **DSU install fails.** Free space. The GSI plus a userdata
  image needs several GB free on the phone.
- **GSI black screen or bootloop.** Vendor gap is the prime
  suspect (Exynos vendor vs Android 15/16 system). Try the other
  build (HyperOS 2 first, then HyperOS 1). Capture a boot log
  before wiping.
- **`fastboot flash system` fails with a size error.** The image
  does not fit super as laid out. Stop and report it. Do not
  force it. (TODO: this step itself is unverified on the r9s;
  see Part 2.)
- **Setup wizard dead on first GSI boot.** Finish setup over adb
  (standard AOSP setup-skip commands, unproven on this build).
  TODO: confirm the exact commands work on the r9s.
- **No SIM, no calls, no data.** Expected on this vendor until
  proven otherwise. The RIL gap is the number one daily-driver
  blocker. Record exactly what fails (SIM detected? signal?
  calls? data?) and report it. Upstream config.sh records the
  r9s RIL as "onebinary satellite_carrier".

## Next step

If the GSI boots, report the result (what worked, what did not)
so Part 2 can be written. To go back: [flash-stock.md](flash-stock.md).

## Sources

- GSI route exists on the S21 FE (both SoCs), OrangeFox provided
  for Exynos: "[GSI] [A13] Pixel Experience Plus for Galaxy S21
  FE 5G (Snapdragon/Exynos)",
  https://xdaforums.com/t/gsi-a13-pixel-experience-plus-for-galaxy-s21-fe-5g-snapdragon-exynos.4547027/
- MysticGSI spring facts (file, 3,122,721,686 B, MD5
  `3e6337d1dd850ae2d0f7d067f8dd191c`, system.img 6,232,481,792 B
  ext4) and Permissiver v5 (1,251,096 B, MD5
  `73f68347929e484351d2ca1f72360381`): verified m51 record,
  https://github.com/kkisdevil/m51-hyperos/blob/main/docs/gsi-verification.md
  (device-independent values reused; r9s fit and boot unproven).
- MysticGSI downloads:
  https://sourceforge.net/projects/mystic-gsi-updates/files/HyperOS/
- DSU Sideloader: https://github.com/VegaBobo/DSU-Sideloader/releases
- r9s facts (super 11,429,478,400 B, optical fingerprint,
  eSIM false, RIL "onebinary satellite_carrier"): upstream
  `salvogiangri/UN1CA`, branch `sixteen`, `target/r9s/config.sh`,
  read live 2026-11-25.
- DSU procedure shape and troubleshooting: `../m51/flash-gsi.md`
  in this repo (procedure shape only; its fastboot commands are
  NOT copied here because they are m51-verified, not
  r9s-verified).
