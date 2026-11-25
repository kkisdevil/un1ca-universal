# Flash the custom kernel - Galaxy S22 Ultra (SM-S908E)

Flash a custom kernel on the Galaxy S22 Ultra (Snapdragon),
codename `b0q`. This file is for the SM-S908E, SM-S908N, and
SM-S9080 only. Do not use it on any other model.

## WARNING: no custom kernel build exists for this device yet

**No custom kernel has been built for the b0q in this project,
and no kernel has ever booted on a b0q from us.** There is no
build number, no run id, no artifact, and no Gate 8 boot test.
Everything below is the procedure to use once a build exists,
plus the stock-kernel facts you need for rollback. Do not flash
any kernel file on this phone until a b0q build record exists
with a verified SHA-256.

## What the kernel is

- Stock kernel on the current INS firmware: Linux **5.10.236**
  (`5.10.236-android12-9-31998796-abS908EXXSCGZA2`, from the
  SamFrew record for build `S908EXXSCGZA2`). The kernel is the
  Android 12-based 5.10 branch even though the system is Android
  16 / One UI 8.0.
- Custom kernel source: TODO. No source repo, branch, defconfig,
  or toolchain has been chosen for the b0q. The m51 kernel
  (crDroid sm7150 tree, 4.14.357-openela) does not apply here:
  different SoC (sm8450), different kernel branch (5.10), different
  defconfig.
- Boot partition size: TODO. Do not flash an image until the
  boot partition size for this device is recorded and the build
  gate checks the image against it.
- EROFS support and SELinux mode for a custom build: TODO.

## How it was built

TODO: no build exists. Once one does, record the toolchain
(name, commit, version), the defconfig handling (merged or
reviewed savedefconfig, how many CONFIG lines), the patches
applied, and the bugs fixed along the way. Do not copy another
tree's build scripts blindly if they carry the same bugs.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first.
3. **Keep the old boot image on the phone before you flash the new
   one.** Extract `boot.img` from the stock AP tar (see
   [flash-stock.md](flash-stock.md)): the AP tar is a plain tar,
   `tar -xf AP_...tar.md5 boot.img`. Without it, a bad boot has
   no quick way back.
4. **Battery above 50%, ideally full.**
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-S908E**, **SM-S908N**, or
   **SM-S9080**.
6. The kernel artifact from the run page, extracted to the boot
   image, with its SHA-256 checked against the build record.
   TODO: no artifact exists yet.

## Steps

1. Get the kernel artifact from the run page and extract the boot
   image. Check its SHA-256 against the build record above.
   TODO: no artifact exists yet.
2. Copy the new boot image **and** the old boot image (prereq 3)
   to the phone.
3. In TWRP: Install, **Install Image**, select the new boot image,
   flash to the **Boot** partition. (Or pack it into a `boot.tar`
   and flash it in Odin's AP slot.) Only the boot partition is
   written. Recovery is untouched.
4. Reboot.
5. Check `adb shell uname -a` shows the expected version string
   and `adb shell cat /proc/version` matches the build record.

Note: the b0q XDA TWRP thread also flashes a custom permissive
kernel in TWRP as part of the TWRP install itself (see
[flash-twrp.md](flash-twrp.md)). That kernel is the TWRP
maintainer's permissive kernel, not this project's custom kernel.
Do not confuse the two.

## Verify

- `adb shell uname -a` shows the expected version string.
  TODO: record the expected string once a build exists.
- `adb shell cat /proc/version` matches the build record.
- The phone boots to the home screen and stays up. Wi-Fi, calls,
  and sensors work as before the flash.
- If this is the first boot of this kernel on this phone, record
  the result (booted or not, plus `dmesg` and `logcat`) and report
  it. That record is Gate 8.

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
- **Image too large for the boot partition.** Do not flash it.
  TODO: record the boot partition size for this device so this
  check can be done.

## Sources

- Stock kernel version (`5.10.236-android12-9`):
  https://samfrew.com/download/Galaxy__S22__Ultra__/45va/INS/S908EXXSCGZA2/S908EOXMCGZA2
- TWRP-thread permissive kernel note:
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-s22-ultra-snapdragon.4453235/
- Custom kernel source, defconfig, toolchain, artifact, boot
  partition size, build gates: TODO, no build exists for the b0q
  in this project.
