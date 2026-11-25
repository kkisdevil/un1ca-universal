# Root - Galaxy M52 5G (SM-M526B / SM-M526BR)

Root the SM-M526B / SM-M526BR. This file is for the SM-M526B and
SM-M526BR only. Do not use it on any other model.

## What root is

Root is administrator access to the phone's own system. You can
read and change anything, install modules, and run root apps.

## What root costs

- Knox is already tripped by the unlock, so root adds no new
  permanent loss.
- Banking apps and Play Integrity can fail on a rooted phone.
- System OTA updates will remove root. Do not take them.
- You must **never relock the bootloader** with root installed.
  That bricks the phone.
- To unroot: flash the stock boot or AP ([flash-stock.md](flash-stock.md)),
  or in Magisk go to Uninstall, Restore Images, then flash stock
  boot.

## Prereqs

1. **Unlocked bootloader** ([unlock-bootloader.md](unlock-bootloader.md)).
   For Methods B and C you also need TWRP
   ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything.** Rooting itself does not wipe data, but
   a wrong flash can. Back up EFS in TWRP first.
3. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself for the Odin steps.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-M526B** or **SM-M526BR**
   and the service provider software version must show the CSC
   for your region.
5. Know which stock build the phone runs (Settings, About phone,
   Software information, build number). Method A patches the AP
   tar of that exact build. The latest builds are
   `M526BXXS7CYD2` (SM-M526B, INS) and `M526BRXXS7CYE1`
   (SM-M526BR, BTU); see [flash-stock.md](flash-stock.md).

## Method A: Magisk, patch the AP (Samsung standard, no TWRP needed)

This is the standard Magisk method for Samsung phones.

1. Download the **Magisk APK** (latest release) from
   https://github.com/topjohnwu/Magisk/releases and install it on
   the phone.
2. Copy the stock **AP tar** (for example
   `AP_M526BXXS7CYD2_...tar.md5` for SM-M526B, or
   `AP_M526BRXXS7CYE1_...tar.md5` for SM-M526BR, from the
   [flash-stock.md](flash-stock.md) firmware) to the phone's
   internal storage.
3. Open Magisk, **Install**, **Select and Patch a File**, pick the
   AP tar. Magisk patches it (takes minutes: the AP is huge) and
   writes `magisk_patched-*.tar` to the Download folder.
4. Copy the patched tar back to the PC.
5. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
6. Open Odin **as administrator**. Load the **patched tar in the
   AP slot**. If the phone is already on this exact stock build,
   AP-only is enough. Otherwise load BL, CP, and CSC from the
   same firmware package as well. Leave Re-Partition unticked.
   Click Start and wait for PASS.
7. Reboot. Open Magisk. It shows **Installed**.

TODO: the Odin version and SHA-256 to use here are not yet pinned
for this device; see [flash-twrp.md](flash-twrp.md).

## Method B: Magisk, patch the boot image (needs TWRP)

1. Extract `boot.img` from the stock AP tar. The AP tar is a plain
   tar: `tar -xf AP_...tar.md5 boot.img`.
2. Copy `boot.img` to the phone. In the Magisk app: Install,
   Select and Patch a File, pick `boot.img`. You get
   `magisk_patched-*.img` in Download.
3. Copy the patched image back to the phone. In TWRP: Install,
   **Install Image**, select the patched image, flash to the
   **Boot** partition. Reboot.
4. Verify as below.

The boot partition on this device is 100,663,296 bytes (96 MiB),
per the TWRP device tree BoardConfig. A patched boot image must
fit in it; the stock boot image does.

## Method C: Magisk zip in TWRP

1. Rename the Magisk APK to `Magisk-vXX.zip` and copy it to the
   phone (or an SD card).
2. In TWRP: Install, select the zip, flash it, reboot.
3. Verify as below. The Magisk app can also do a Direct Install
   once the phone is already booted with a patched boot.

## Verify

- Open the Magisk app. It shows **Installed** with a version
  number.
- From a PC: `adb shell su -c id` prints `uid=0(root)`.
- If the app shows "Installed: N/A" or `su` is denied, the patch
  did not take. Re-do the method from step 1 and check you patched
  the AP or boot image of the build that is actually on the phone.

## Other root methods

- **KernelSU: available on this device, via a custom kernel.**
  The KernelSU v0.8.1 thread for the M52 (BlackMesa123) is EOL
  and tells users to move to Ascendia Kernel. Ascendia Kernel
  with KernelSU v0.9.3 is the named successor. Eureka with
  KernelSU-Next v1.0.7 also exists for the M526B/BR, but its
  thread is marked [CLOSED]. All three are kernel-based root: the
  kernel itself carries the root support, so you flash the
  kernel's flashable zip in TWRP (the KernelSU thread says to
  download the KernelSU flashable zip in its post #2 and pick the
  version matching the installed ROM), then use the KernelSU
  Manager app. See [flash-kernel.md](flash-kernel.md) for the
  kernel side. None of these has been run end-to-end by us on
  this device.
- **APatch: no evidence for this device.** No APatch method for
  the m52xq was found during research. Do not assume the Magisk
  steps transfer to APatch. TODO: only add APatch here if a
  device-specific APatch report for the m52xq is found.
- **No optimizer warning for this device.** There is no fix pack
  for the m52xq (unlike the m51, which has a lag fix pack that a
  nightly optimizer would fight), so there is no equivalent
  do-not-install module to name here. TODO: revisit if a fix pack
  is ever added for this device.

## After root

- Modules install from the Magisk app (or the KernelSU Manager
  app, for KernelSU).
- If a banking app fails, that is Play Integrity, not a broken
  root. UN1CA ships a Play Integrity Fix (see
  [flash-un1ca.md](flash-un1ca.md)). On stock, PIF and Shamiko
  style modules exist but are **not verified by us** on this
  phone, so they are named here, not recommended.
- Do not take system OTA updates on a rooted phone. They remove
  root and can fail mid-install.
- Do not write to the bootloader partitions (`aboot` / `xbl` /
  `sbl`) from root. That bricks the phone.

## Troubleshooting

- **Magisk shows "Installed: N/A".** You patched the wrong build.
  Check the build number on the phone and patch the AP or boot
  image from that exact build.
- **`su` is denied.** Root did not stick. Reboot into TWRP and
  check the Boot partition holds the patched image (Method B), or
  re-flash the patched AP tar (Method A).
- **Bootloop after flashing a patched image.** Reboot into TWRP
  and flash the stock `boot.img` from the AP tar to the Boot
  partition (Install Image, Boot). The phone is back to unrooted
  stock boot. Then re-do the method.
- **Banking app fails after root.** Play Integrity. See "After
  root" above. This is expected, not a broken root.

## Sources

- Magisk releases, https://github.com/topjohnwu/Magisk/releases
  (Method A, B, C are the standard Magisk for Samsung flow; the
  AP filename patterns use the firmware from
  [flash-stock.md](flash-stock.md)).
- Boot partition size 100,663,296 bytes: TWRP device tree
  BoardConfig.mk, line 92,
  https://github.com/paulowesll/android_device_samsung_m52xq-twrp/blob/twrp-12.1/BoardConfig.mk
- XDA, "[CLOSED][KERNEL][M526B/BR] KernelSU v0.8.1 for Galaxy M52
  5G", https://xdaforums.com/t/kernel-m526b-br-kernelsu-v0-7-5-for-galaxy-m52-5g.4603295/
  (EOL, move to Ascendia Kernel; built from A528BXXU5FWK4 kernel
  source, Linux 5.4.233, Clang 11.0.2; supported variants
  SM-M526B m52xqins, SM-M526B m52xqser, SM-M526BR m52xqxx;
  install via the KernelSU flashable zip in post #2). Read via
  search results 2026-11-25.
- XDA forum listing for the M52 5G,
  https://xdaforums.com/f/samsung-galaxy-m52-5g.12703/ (Eureka
  with KernelSU-Next v1.0.7 thread marked [CLOSED]; Ascendia
  Kernel with KernelSU v0.9.3 named in the LineageOS 21 thread).
  Read via search results 2026-11-25.
- UN1CA upstream README (Play Integrity Fix integrated),
  https://github.com/salvogiangri/UN1CA/blob/sixteen/README.md
