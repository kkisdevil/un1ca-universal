# Flash the custom kernel - Galaxy A53 5G (SM-A536B)

Flash a custom kernel on the SM-A536B. This file is for the
SM-A536B only. Do not use it on any other model. The A53 5G is
an Exynos phone (Exynos 1280, s5e8825): the kernels here are
Exynos 5.10 kernels, not Snapdragon ones, and the kernel that
matters most on this phone is the third-party ExynosUnbound
kernel, which is what makes a GSI usable at all.

## WARNING: no kernel of ours has booted on this device

**There is no kernel build of ours for this phone, and no boot
test has been done.** No workflow run, no artifact, no gates.
Treat every kernel below as third-party and untested by us until
it has booted on a phone in front of us. Flash only if you accept
that risk and you have the previous boot image ready to restore
(step 4 below). Do not flash a kernel on a phone you need working
today.

## What the kernels are

### Stock kernel (the baseline)

The stock kernel is Linux **5.10.237-android12-9**, from the
SamFrew record for the EUX build `A536BXXSJGZA2` (kernel string
`5.10.237-android12-9-31999025-abA536BXXSJGZA2`). The vendor base
is Android 12 even on the Android 16 builds. The boot partition
is 64 MB (`TARGET_BOOT_PARTITION_SIZE=67108864` in the upstream
config), dtbo is 8 MB, vendor_boot is 32 MB.

### ExynosUnbound (the custom kernel that exists for this phone)

ExynosUnbound is the custom kernel for the a53x, by Gabriel
(Elatee), in the XDA thread "[KERNEL] [a53x] ExynosUnbound Kernel
for Galaxy A53 5G":
https://xdaforums.com/t/kernel-a53x-exynosunbound-kernel-for-galaxy-a53-5g.4637659/
Only for s5e8825 (Exynos 1280). It boots in **enforcing** SELinux
mode only, so any ROM that requires permissive will not work
with it. Release R1.0 upstreamed the kernel to 5.10.198, used the
Mali r38 GPU driver, overclocked the GPU to 1209 MHz, set LZ4 as
the default zram algorithm, disabled Samsung securities (proca,
defex) and debug code, and included **KernelSU v0.6.9**. Later
releases are mentioned in the thread (2.5 is named by users),
and the thread was last edited 2024-10-07.

TODO: the newest ExynosUnbound release, its kernel version, and
its KernelSU version were not verified at the time of writing.
The R1.0 details above are from the thread's changelog; check
the thread's download post before flashing. Whether the current
release boots on One UI 8 / Android 16 stock is also unverified.

### UN1CA kernel source (for a future own build)

The UN1CA installer fetches its DTBO from the
`UN1CA/kernel_samsung_s5e8825` releases
(`target/a53x/installer/customize.sh` lines 171-175), so the
kernel source family for this device is `kernel_samsung_s5e8825`.
TODO: no own kernel build exists for a53x in this repo, no
defconfig has been reviewed, no toolchain has been pinned, and
no build gates have been defined for this phone. Do not copy the
m51 kernel build record: different SoC, different kernel tree,
different version.

### TWRP kernel (reference only)

The TWRP kernel lives at
https://github.com/mytja/android_kernel_samsung_a53x/tree/twrp-12.1.
It is the recovery kernel, not a kernel for daily use. Do not
flash it as the system kernel.

## How it was built

TODO: no build of ours exists, so there is no toolchain,
defconfig, patch list, or gate record to quote. For
ExynosUnbound, the source is on the author's GitHub profile
(linked from the XDA thread) and the build is the author's, not
ours. Do not present any of it as verified by us.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first.
3. **Keep the old boot image on the phone before you flash the
   new one.** Extract `boot.img` from the stock AP tar (see
   [flash-stock.md](flash-stock.md)), or copy the last working
   kernel image. The ExynosUnbound thread says the same thing:
   back up your boot and vendor_boot partitions at the first
   moment. Without them, a bad boot has no quick way back.
4. **Battery above 50%, ideally full.**
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A536B**.
6. The kernel file (ExynosUnbound zip or tar for a53x) on the
   phone or PC. Download the release file ending in `a53x.zip`
   for the TWRP route. TODO: no SHA-256 for the current release
   was verified; check the hash in the XDA thread before
   flashing.

## Steps

### TWRP zip route (recommended by the kernel thread)

1. Get the ExynosUnbound zip for a53x and copy it to the phone.
2. Reboot to TWRP.
3. Install, select the zip, flash it. Or use adb sideload from
   the PC and flash it directly.
4. If you use Magisk, reflash the Magisk zip after flashing the
   kernel (stated in the kernel thread). If you use KernelSU,
   install the KernelSU manager app instead; if you do not want
   KernelSU, do not install the manager and Magisk works as
   normal.
5. Reboot.
6. Check `adb shell uname -a` shows the expected kernel version
   and `adb shell cat /proc/version` matches the release you
   flashed.

### Odin tar route

1. Reboot the phone to Download mode.
2. Open Odin. Load the kernel tar file in the **AP slot**.
3. Load the disabled vbmeta tar in the **BL slot**.
4. Press Start.

### Own boot image route (TWRP Install Image)

If you have a raw boot image (from a future own build, not
available yet):

1. Copy the new boot image **and** the old boot image (prereq 3)
   to the phone.
2. In TWRP: Install, **Install Image**, select the new boot
   image, flash to the **Boot** partition. (Or pack it into a
   `boot.tar` and flash it in Odin's AP slot.) Only the boot
   partition is written. Recovery is untouched.
3. Reboot.
4. Check `adb shell uname -a` and `adb shell cat /proc/version`.

## Verify

- `adb shell uname -a` shows the expected kernel version for the
  release you flashed.
- `adb shell cat /proc/version` matches the build record.
- The phone boots to the home screen and stays up. Wi-Fi, calls,
  and sensors work as before the flash.
- If this is the first boot of this kernel on this phone, record
  the result (booted or not, plus `dmesg` and `logcat`) and
  report it.

## Rollback

If it does not boot, or anything regresses:

1. Reboot into TWRP (power off, hold Volume Up + Power, USB
   connected).
2. Install, **Install Image**, select the **old** boot image from
   prereq 3, flash to the **Boot** partition. Also restore
   vendor_boot if you backed it up and the new kernel touched it.
3. Reboot. The phone is back on the previous kernel.
4. If you have no old boot image on the phone, flash the stock
   boot image from the [flash-stock.md](flash-stock.md) AP tar
   the same way (Install Image, Boot), or flash the full stock
   firmware with Odin.

## Troubleshooting

- **Bootloop after flashing.** Roll back (above). Do not wipe
  data first: a kernel bootloop is a boot image problem, and a
  wipe will not fix it. It will only delete your data.
- **Kernel version string is wrong.** You flashed the wrong
  image. Check the release name (must be the a53x file) and the
  SHA-256, then re-flash the right one.
- **Phone boots but Wi-Fi or sensors broke.** The kernel and the
  vendor blobs disagree. Roll back, and report which function
  broke with a `dmesg` capture.
- **Image too large for the boot partition.** Do not flash it.
  The boot partition is 64 MB. An image at or above that size
  means the file is not a plain a53x boot image.
- **GSI still has no mobile data or bad audio after the kernel.**
  Check you flashed the a53x release (file ending `a53x.zip`),
  not another variant, and check the kernel actually booted
  (`uname -a`). See [flash-gsi.md](flash-gsi.md).

## Sources

- Stock kernel 5.10.237-android12-9: SamFrew record for EUX
  `A536BXXSJGZA2`,
  https://samfrew.com/download/Galaxy__A53__5G__/5wgv/EUX/A536BXXSJGZA2/A536BOXMJGZA2
- Boot 64 MB, dtbo 8 MB, vendor_boot 32 MB:
  `target/a53x/config.sh` lines 24-28 in salvogiangri/UN1CA
  branch `sixteen`.
- ExynosUnbound details (s5e8825 only, enforcing only, R1.0
  changelog, KernelSU, install routes, backup boot and
  vendor_boot, reflash Magisk after, KernelSU manager optional):
  XDA thread "[KERNEL] [a53x] ExynosUnbound Kernel for Galaxy
  A53 5G",
  https://xdaforums.com/t/kernel-a53x-exynosunbound-kernel-for-galaxy-a53-5g.4637659/
- UN1CA kernel source family `kernel_samsung_s5e8825`:
  `target/a53x/installer/customize.sh` lines 171-175 in
  salvogiangri/UN1CA branch `sixteen`.
- TWRP kernel source:
  https://github.com/mytja/android_kernel_samsung_a53x/tree/twrp-12.1
