# Flash the custom kernel - Galaxy A73 5G (SM-A736B)

Flash a custom kernel on the SM-A736B. This file is for the
SM-A736B only. Do not use it on any other model.

## WARNING: no custom kernel build exists for this phone

**There is no custom kernel build for the a73xq in this project,
and no kernel has ever booted on this phone from a build of ours.
Do not flash anything from this file until a build exists and its
first boot is recorded.** A green build is not a booting kernel,
and here there is not even a build. The steps below are the
procedure to use once a build exists, written around the stock
boot image so the rollback is real.

## What the kernel would be

- Stock kernel on the current firmware: `5.4.289-qgki-32200428`
  (from the SamFrew record for A736BXXSCGZK3, Android 16 / One
  UI 8.0). Any custom kernel for this phone is a 5.4 kernel for
  the sm7325 (Snapdragon 778G).
- Kernel source, defconfig, EROFS support, SELinux mode: TODO.
  No source tree, branch, or defconfig has been chosen for this
  phone. The TWRP kernel tree for this phone is
  https://github.com/samsung-778/android_kernel_samsung_sm7325/tree/twrp-12.1
  (used by the unofficial TWRP 3.7.0-12 build); that is a recovery
  kernel, not a custom kernel for daily use, and it must not be
  presented as one.
- Latest build number, run id, artifact name, size, SHA-256,
  retention: TODO, none exist.
- Build gates: TODO, none exist for this phone. Any gates written
  here later must be this phone's own (boot partition size,
  kernel version string, EROFS and SELinux symbols), not copied
  from the m51 gates.

## How it would be built

- Toolchain: TODO, not chosen.
- Defconfig handling: TODO, not done. No merged or reviewed
  savedefconfig exists for this phone.
- Patches: TODO. No a73xq kernel patches have been written or
  collected. Do not copy another tree's build scripts blindly;
  the m51 notes record bugs that also exist in other trees
  (an NPU Makefile overwrite and a WLAN debug guard hiding a
  symbol), and the same caution applies here until this phone's
  tree is reviewed.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first.
3. **Keep the old boot image on the phone before you flash the new
   one.** Extract `boot.img` from the stock AP tar (see
   [flash-stock.md](flash-stock.md)): the AP tar is a plain tar,
   but on this phone the boot image inside is stored as
   `boot.img.lz4`, so decompress it first (see
   [root.md](root.md) Method B). Without the old boot image, a
   bad boot has no quick way back.
4. **Battery above 50%, ideally full.**
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A736B**.
6. The kernel artifact from the run page, extracted to the boot
   image, with its SHA-256 checked against the build record.
   No artifact exists yet.

## Steps

Once a build exists:

1. Get the kernel artifact from the run page and extract the boot
   image. Check its SHA-256 against the build record.
2. Copy the new boot image **and** the old boot image (prereq 3)
   to the phone.
3. In TWRP: Install, **Install Image**, select the new boot image,
   flash to the **Boot** partition. (Or pack it into a `boot.tar`
   and flash it in Odin's AP slot.) Only the boot partition is
   written. Recovery is untouched.
4. Reboot.
5. Check `adb shell uname -a` shows the new kernel version and
   `adb shell cat /proc/version` matches the build record.

## Verify

- `adb shell uname -a` shows the new kernel version string from
  the build record.
- `adb shell cat /proc/version` matches the build record.
- The phone boots to the home screen and stays up. Wi-Fi, calls,
  and sensors work as before the flash.
- If this is the first boot of this kernel on this phone, record
  the result (booted or not, plus `dmesg` and `logcat`) and report
  it. That record is Gate 8 for this phone.

## Rollback

If it does not boot, or anything regresses:

1. Reboot into TWRP (power off, hold Volume Up + Power while
   connected to a PC via USB).
2. Install, **Install Image**, select the **old** boot image from
   prereq 3, flash to the **Boot** partition.
3. Reboot. The phone is back on the previous kernel.
4. If you have no old boot image on the phone, flash the stock
   boot image from the [flash-stock.md](flash-stock.md) AP tar the
   same way (Install Image, Boot), or flash the full stock
   firmware with Odin.

## Troubleshooting

- **Bootloop after flashing.** Roll back (above). Do not wipe
  data first: a kernel bootloop is a boot image problem, and a
  wipe will not fix it. It will only delete your data.
- **Kernel version string is wrong.** You flashed the wrong
  image. Check the artifact name and the SHA-256, then re-flash
  the right one.
- **Phone boots but Wi-Fi or sensors broke.** The kernel and the
  vendor blobs disagree. Roll back, and report which function
  broke with a `dmesg` capture.
- **Image too large for the boot partition.** Do not flash it.
  The boot partition size for this phone is TODO: it is not
  stated in `target/a73xq/config.sh` (the config sets the super
  partition size, not the boot partition size), and it has not
  been read from a live phone or a PIT file. Find it before the
  first build, and write the build gate around it.

## Sources

- Stock kernel version: SamFrew record for A736BXXSCGZK3,
  https://samfrew.com/download/Galaxy__A73__5G__/tstz/XME/A736BXXSCGZK3/A736BOLMCGZK3
- TWRP kernel tree (recovery kernel, not a daily-use custom
  kernel):
  https://github.com/samsung-778/android_kernel_samsung_sm7325/tree/twrp-12.1
- Super partition size (for contrast with the unknown boot
  partition size): `target/a73xq/config.sh` lines 24 and 26,
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/a73xq/config.sh

## TODO

- TODO: no custom kernel build exists for this phone in this
  project. Choose a source tree, defconfig, and toolchain, build
  it, and record the run before anyone flashes.
- TODO: boot partition size for this phone is unknown. Read it
  from a live phone or a PIT file before the first build.
- TODO: EROFS support and SELinux mode for the future kernel are
  undecided.
- TODO: Gate 8 (first boot) has not been done, because there is
  no kernel to boot.
