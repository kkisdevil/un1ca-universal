# Flash the custom kernel - Galaxy M52 5G (SM-M526B / SM-M526BR)

Flash a custom kernel on the SM-M526B / SM-M526BR. This file is
for the SM-M526B and SM-M526BR only. Do not use it on any other
model.

## WARNING: no project kernel build exists for this device

**There is no custom kernel built by this project for the m52xq,
and no kernel has ever been boot-tested on this phone by us.**
The kernels named below are community builds from XDA. Treat
every one of them as untested by us until it has booted on the
phone in front of us. Flash one only if you accept that risk and
you have the previous boot image ready to restore (step 3 below).
Do not flash a custom kernel on a phone you need working today.

## What the kernels are

No kernel source, defconfig, toolchain, build workflow, build
number, artifact, or build gates exist for this device in this
project. TODO: all of those, if a project kernel build for the
m52xq is ever started. What exists today is community work:

- **Eureka with KernelSU-Next v1.0.7** for the M526B/BR. Its XDA
  thread is marked [CLOSED].
- **Ascendia Kernel with KernelSU v0.9.3** for the M52 5G. This is
  the named successor to the KernelSU v0.8.1 build below.
- **KernelSU v0.8.1** for the M526B/BR (BlackMesa123). This
  project is EOL: the thread says "This project is EOL, please
  move to Ascendia Kernel." What it was: built from
  A528BXXU5FWK4 kernel source code, Linux 5.4.233, based on
  LA.UM.9.14.r1-22000-LAHAINA.QSSI12.0, built with Clang 11.0.2
  (r383902b1). Supported variants: SM-M526B (m52xqins), SM-M526B
  (m52xqser), SM-M526BR (m52xqxx). Kernel source:
  https://github.com/BlackMesa123/android_kernel_samsung_sm7325/tree/sep-15/ksu
- **Mesa's Custom Kernel R6** for the M526B/BR (Android 12/13).
  TODO: version, features, and install steps; only the thread
  title was found during research.

The stock kernel on the latest firmware is 5.4.233 (Android 13 /
One UI 5.1, patch May 2025). UN1CA 3.2.1 ships kernel 5.4.302
for the M52. Any kernel you flash must match the ROM it is built
for: the KernelSU thread ships separate One UI/GSI and AOSP
builds, and tells you to download the version matching the
installed ROM.

## Partition sizes (verified)

From the TWRP device tree BoardConfig.mk
(`paulowesll/android_device_samsung_m52xq-twrp`, branch
`twrp-12.1`):

- Boot partition: **100,663,296 bytes (96 MiB)**, line 92.
- Recovery partition: 81,788,928 bytes, line 95.
- Vendor boot partition: 100,663,296 bytes, line 94.

A boot image larger than 96 MiB does not fit the boot partition.
Do not flash it.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first.
3. **Keep the old boot image on the phone before you flash the new
   one.** Extract `boot.img` from the stock AP tar (see
   [flash-stock.md](flash-stock.md)), or copy the last working
   kernel image. Without it, a bad boot has no quick way back.
4. **Battery above 50%, ideally full.**
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-M526B** or **SM-M526BR**.
6. The kernel artifact (a flashable zip for the KernelSU kernels,
   or a boot image for an image flash), with its hash checked
   against the thread it came from. TODO: record the exact
   filename, size, and hash of whichever kernel is chosen; none
   is recorded here yet.

## Steps

For a KernelSU kernel (Eureka, Ascendia, or the EOL KernelSU
v0.8.1 build), the thread's own install route is a flashable zip
in TWRP:

1. Get the kernel's flashable zip from its XDA thread (the
   KernelSU v0.8.1 thread says to download the KernelSU flashable
   zip in its post #2, and to pick the version matching the
   installed ROM: One UI/GSI or AOSP). Check its hash if the
   thread gives one.
2. Copy the zip **and** the old boot image (prereq 3) to the
   phone.
3. In TWRP: Install, select the kernel zip, flash it. Reboot.
4. Check `adb shell uname -a` and `adb shell cat /proc/version`
   against the kernel the thread claims (for example 5.4.233 for
   the KernelSU v0.8.1 build).

For a raw boot image instead (if a kernel is distributed as one):

1. Get the boot image and check its hash. It must be under
   96 MiB (see "Partition sizes").
2. Copy the new boot image **and** the old boot image (prereq 3)
   to the phone.
3. In TWRP: Install, **Install Image**, select the new boot image,
   flash to the **Boot** partition. (Or pack it into a `boot.tar`
   and flash it in Odin's AP slot.) Only the boot partition is
   written. Recovery is untouched.
4. Reboot.
5. Check `adb shell uname -a` shows the expected kernel version
   and `adb shell cat /proc/version` matches.

## Verify

- `adb shell uname -a` shows the kernel version the thread claims.
- `adb shell cat /proc/version` matches.
- The phone boots to the home screen and stays up. Wi-Fi, calls,
  and sensors work as before the flash.
- If this is the first boot of this kernel on this phone, record
  the result (booted or not, plus `dmesg` and `logcat`) and report
  it. That record is the boot test, and it has not been done for
  any kernel on this device yet.

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
  image. Check the artifact name and hash, then re-flash the
  right one.
- **Phone boots but Wi-Fi or sensors broke.** The kernel and the
  vendor blobs disagree. Roll back, and report which function
  broke with a `dmesg` capture.
- **`Image.gz-dtb` or `boot.img` is 96 MiB or larger.** Do not
  flash it. The boot partition is 96 MiB (100,663,296 bytes).

## Sources

- XDA, "[CLOSED][KERNEL][M526B/BR] KernelSU v0.8.1 for Galaxy M52
  5G", https://xdaforums.com/t/kernel-m526b-br-kernelsu-v0-7-5-for-galaxy-m52-5g.4603295/
  (EOL, move to Ascendia Kernel; built from A528BXXU5FWK4 kernel
  source, Linux 5.4.233, LA.UM.9.14.r1-22000-LAHAINA.QSSI12.0,
  Clang 11.0.2; supported variants SM-M526B m52xqins, SM-M526B
  m52xqser, SM-M526BR m52xqxx; install via the KernelSU flashable
  zip in post #2, One UI/GSI or AOSP build to match the ROM).
  Read via search results 2026-11-25.
- XDA forum listing for the M52 5G,
  https://xdaforums.com/f/samsung-galaxy-m52-5g.12703/ (Eureka
  with KernelSU-Next v1.0.7 thread marked [CLOSED]; Mesa's Custom
  Kernel R6 for Android 12/13; Ascendia Kernel with KernelSU
  v0.9.3 named in the LineageOS 21 thread). Read via search
  results 2026-11-25.
- Boot partition size 100,663,296 bytes, recovery 81,788,928
  bytes: TWRP device tree BoardConfig.mk, lines 92, 95,
  https://github.com/paulowesll/android_device_samsung_m52xq-twrp/blob/twrp-12.1/BoardConfig.mk
- Stock kernel 5.4.233 on Android 13 / One UI 5.1, patch May 2025:
  deviceinfo.app Galaxy M52 5G page,
  https://www.deviceinfo.app/devices/samsung/galaxy-m52-5g/
- UN1CA 3.2.1 ships kernel 5.4.302 for the M52: upstream release
  3.2.1,
  https://github.com/salvogiangri/UN1CA/releases/tag/3.2.1
