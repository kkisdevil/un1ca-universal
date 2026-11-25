# Flash the custom kernel - Galaxy S22 (SM-S901E)

Flash a custom kernel on the SM-S901E. This file is for the
Galaxy S22 (Snapdragon), codename `r0q`, models SM-S901E,
SM-S901N, and SM-S9010 only. Do not use it on the Exynos Galaxy
S22 (SM-S901B, codename `r0s`) or on the Galaxy S22 Ultra
(SM-S908x, codename `b0q`).

## WARNING: no kernel build exists for this device

**No custom kernel build exists for r0q in this project, and no
kernel has ever booted on an r0q here.** There is no green build
to flash. The sections below describe the stock kernel, the
flashing procedure, and the rollback, so the file is ready when a
kernel exists. Do not flash any kernel on a phone you need
working today unless you have the previous boot image ready to
restore (prereq 3 below).

## What the kernel is

- **Stock kernel:** the r0q ships Samsung's taro kernel, **5.10**
  (for example `5.10.236-android12-9-31998796-abS901USQU8GYJ1`
  in the Android 16 stock firmware record). UN1CA 3.2.1 for r0q
  uses the stock kernel from its source firmware. There is no
  separate kernel source tree in this project for r0q.
- **No project kernel build:** no defconfig, no toolchain pin, no
  build gates, no artifact. TODO: if a custom kernel is wanted,
  pick the kernel source (Samsung open source release for the
  S901E, or an existing r0q tree), pin a toolchain, and record
  the build the way the m51 kernel build is recorded in this
  repo.
- **Kernels other people built:** the older XDA TWRP thread for
  this device links a custom kernel (afaneh92 device/kernel
  trees) and says a custom permissive kernel is needed to boot
  with read/write vendor. That kernel is old (from the 2022
  thread era) and unverified by us. An XDA development thread
  titled "Samsung Galaxy S22-S901E [ KernelSU ]" also exists.
  Neither has been read end to end or flashed by us. Do not
  treat either as a recommended kernel.

## How it was built

TODO: nothing has been built. Do not copy the m51 kernel build
record (crDroid sm7150 tree, 4.14.357-openela, proton-clang):
every value in it belongs to a different SoC and a different
kernel version.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first.
3. **Keep the old boot image on the phone before you flash the new
   one.** Extract `boot.img` from the stock AP tar (see
   [flash-stock.md](flash-stock.md)), or copy the last working
   kernel image. Without it, a bad boot has no quick way back.
4. **Battery above 50%, ideally full.**
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-S901E** (or SM-S901N or
   SM-S9010).
6. The kernel artifact, extracted to the boot image, with its
   SHA-256 checked against the build record. TODO: no artifact
   exists yet.

## Steps

1. Get the kernel artifact and extract the boot image. Check its
   SHA-256 against the build record.
2. Copy the new boot image **and** the old boot image (prereq 3)
   to the phone.
3. In TWRP: Install, **Install Image**, select the new boot image,
   flash to the **Boot** partition. (Or pack it into a `boot.tar`
   and flash it in Odin's AP slot.) Only the boot partition is
   written. Recovery is untouched.
4. Reboot.
5. Check `adb shell uname -a` shows the new kernel version and
   `adb shell cat /proc/version` matches.

## Verify

- `adb shell uname -a` shows the new kernel version string.
- `adb shell cat /proc/version` matches the build record.
- The phone boots to the home screen and stays up. Wi-Fi, calls,
  and sensors work as before the flash.
- If this is the first boot of this kernel on this phone, record
  the result (booted or not, plus `dmesg` and `logcat`) and report
  it.

## Rollback

If it does not boot, or anything regresses:

1. Reboot into TWRP (power off, hold Volume Up + Power, with USB
   connected).
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
- **Image too large for the boot partition.** TODO: the r0q boot
  partition size is unverified. Do not flash an image larger
  than the partition. Record the size here once it is measured
  from a real device or a verified partition table. Do not copy
  the m51 64 MB value: it belongs to another device.

## Sources

- Stock kernel version: SamFrew SM-S901E firmware record,
  https://samfrew.com/download/Galaxy__S22__/s53a/TMB/S901USQU8GYJ1/S901UOYN8GYJ1
  (kernel `5.10.236-android12-9-31998796-abS901USQU8GYJ1`,
  chipset Qualcomm taro, codename `r0q`)
- Custom kernel note and KernelSU thread existence: XDA TWRP
  thread,
  https://xdaforums.com/t/closed-recovery-unofficial-twrp-for-galaxy-s22-snapdragon.4453811/
  and XDA Galaxy S22 forum index, https://xdaforums.com/f/12511/
- TODO: kernel source choice, toolchain, defconfig, build gates,
  artifact, boot partition size, and the first boot test. None
  of these exists for r0q yet.
