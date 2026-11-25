# Flash the custom kernel - Galaxy S21 5G (SM-G991B)

Flash a custom kernel on the SM-G991B. This file is for the
SM-G991B only. Do not use it on any other model.

## WARNING: no kernel build exists for this device

**There is no custom kernel build for o1s in this repo, and no
boot test has been done. There is nothing to flash yet.** Do not
treat UN1CA flashing as kernel flashing: UN1CA ships its own
kernel as part of the ROM (see below). Everything after this
warning is the verified background plus the TODO list for a
future kernel build. A green build is not a booting kernel, and
right now there is not even a build.

## What the kernel is

- **UN1CA ships its own kernel path for this device.** The kernel
  comes from the UN1CA build: the XDA UN1CA thread links the
  upstreamed kernel source required by the XDA GPL policy as
  https://github.com/xfwdrev/android_kernel_samsung_ex2100
  (Exynos 2100 kernel source). The UN1CA installer flashes the
  firmware; the kernel arrives with the ROM. See
  [flash-un1ca.md](flash-un1ca.md).
- **Stock kernel (verified):** the AUT HZA6 stock firmware runs
  kernel `5.4.242-30958140-abG991BXXSJHZA6` (SamFrew record).
  The Exynos 2100 stock kernel is a 5.4 series kernel.
- TODO: kernel source (repo, branch, version) for our own build,
  defconfig name, EROFS support, SELinux mode.
- TODO: latest build number, run id, artifact name, size,
  SHA-256, retention.
- TODO: which build gates exist for this device and which passed.

## How it was built

TODO: nothing has been built yet. When a build exists, record
the toolchain (name, commit, version), the defconfig handling,
the patches applied, and the bugs fixed along the way. Do not
copy another tree's build scripts blindly if they carry the same
bugs.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)). Note the
   warning there about afaneh92's TWRP and UN1CA.
2. **Back up everything** and back up EFS in TWRP first.
3. **Keep the old boot image on the phone before you flash the new
   one.** Extract `boot.img` from the stock AP tar (see
   [flash-stock.md](flash-stock.md)), or copy the last working
   kernel image. Without it, a bad boot has no quick way back.
4. **Battery above 50%, ideally full.**
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G991B**.
6. The kernel artifact from the run page, extracted to the boot
   image, with its SHA-256 checked against the build record.
   TODO: no artifact exists yet.

## Steps

TODO: exact steps once a kernel build exists. The expected shape,
from the Samsung-standard flow, is: in TWRP, Install, **Install
Image**, select the new boot image, flash to the **Boot**
partition (or pack it into a `boot.tar` and flash it in Odin's AP
slot). Only the boot partition is written. Recovery is untouched.
Do not run these steps until the build, the image size, and the
boot partition size are all verified for this device.

TODO: state the boot partition size for this device before anyone
flashes. Do not copy the m51 64 MB figure: it is a different
device and the size is unverified here.

## Verify

- `adb shell uname -a` and `adb shell cat /proc/version` must
  match the build record. TODO: record the expected version
  string once a build exists.
- The phone boots to the home screen and stays up. Wi-Fi, calls,
  and sensors work as before the flash.
- If this is the first boot of this kernel on this phone, record
  the result (booted or not, plus `dmesg` and `logcat`) and report
  it. That record is the boot test.

## Rollback

If it does not boot, or anything regresses:

1. Reboot into TWRP (power off, connect USB, hold Volume Up +
   Power).
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
  TODO: record the boot partition size here first.

## Sources

- UN1CA kernel source link (xfwdrev ex2100 tree) and UN1CA as
  the kernel path: XDA UN1CA thread,
  https://xdaforums.com/t/rom-16-g991b-un1ca-3-0-6-one-ui-8-0-for-galaxy-s21-5g-exynos-03-02-2026.4773332/
- Stock kernel version 5.4.242-30958140-abG991BXXSJHZA6: SamFrew
  AUT HZA6 record,
  https://samfrew.com/download/Galaxy__S21__5G__/dlnl/AUT/G991BXXSJHZA6/G991BOXMJHZA6
- Steps and rollback shape: m51 docs
  (`../m51/flash-kernel.md`); device values are TODO for o1s.
