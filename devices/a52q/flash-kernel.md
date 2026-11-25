# Flash the custom kernel - Galaxy A52 (SM-A525F)

Flash a custom kernel on the SM-A525F. This file is for the
SM-A525F only. Do not use it on any other model.

## WARNING: no kernel build exists yet, and no boot test has been done

**There is no kernel build for the a52q in this project, and no
kernel has ever booted on an a52q from us.** There is no build
number, no run id, no artifact, and no SHA-256 to flash. A green
build elsewhere is not a booting kernel on this phone. Do not
flash anything from this file until a build record exists below
and you have the previous boot image ready to restore. Do not
flash a kernel on a phone you need working today.

## What the kernel is

The kernel named for this device is the **Ascendia kernel**:
https://github.com/RisenID/kernel_samsung_ascendia_sm7125
(default branch `fifteen`). It is the kernel listed in the XDA
thread for UN1CA 2.5.0 on the A52 4G and A72 4G. Its Makefile
reads VERSION 4, PATCHLEVEL 14, SUBLEVEL 190, so it is a
**4.14.190** kernel, matching the stock kernel version reported
for the FXD2 firmware (`4.14.190-perf-28693687`).

What is **not** known about it:

- TODO: which defconfig it uses for the a52q, and whether that
  defconfig has been reviewed (no reviewed defconfig exists in
  this project for the a52q).
- TODO: EROFS support and SELinux mode in its config.
- TODO: whether it carries KernelSU support (see
  [root.md](root.md)).
- TODO: whether it has been built by us at all, on any runner.
  No build gates exist for the a52q yet. When the first build
  runs, record the gates here the way the m51 record does
  (defconfig, olddefconfig, image size vs the boot partition,
  kernel release string, EROFS, SELinux).

Do not copy another tree's build scripts blindly. The m51 record
shows that sibling trees can carry the same bugs (an NPU Makefile
overwrite and a hidden `__qdf_bug`), and the Ascendia tree has not
been audited for them on the a52q.

## Partition sizes (the hard limits)

From `BoardConfig.mk` in the TWRP device tree for the a52q
(https://github.com/TeamWin/android_device_samsung_a52q, branch
android-12.1):

| Partition | Size (bytes) | Size |
|---|---|---|
| Boot | 100,663,296 | 96 MiB |
| Recovery | 81,788,928 | 78 MiB |
| DTBO | 25,165,824 | 24 MiB |

**Do not flash a boot image of 96 MiB or larger.** The build must
gate on this: the image has to fit inside 100,663,296 bytes.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first.
3. **Keep the old boot image on the phone before you flash the new
   one.** Extract `boot.img` from the stock AP tar (see
   [flash-stock.md](flash-stock.md)): the AP tar is a plain tar,
   `tar -xf AP_...tar.md5 boot.img`. Or copy the last working
   kernel image. Without it, a bad boot has no quick way back.
4. **Battery above 50%, ideally full.**
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A525F**.
6. The kernel artifact, extracted to the boot image, with its
   SHA-256 checked against the build record. TODO: no artifact
   exists yet.

## Steps

1. Get the kernel artifact from the run page (TODO: no run exists
   yet) and extract the boot image. Check its SHA-256 against the
   build record above, and check the image is under 96 MiB.
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

- `adb shell uname -a` shows the expected version string (TODO:
  record it once a build exists; stock is `4.14.190-perf`).
- `adb shell cat /proc/version` matches the build record.
- The phone boots to the home screen and stays up. Wi-Fi, calls,
  and sensors work as before the flash.
- If this is the first boot of this kernel on this phone, record
  the result (booted or not, plus `dmesg` and `logcat`) and report
  it. That record is Gate 8.

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
- **Boot image is 96 MiB or larger.** Do not flash it. The boot
  partition is 100,663,296 bytes. A build that produces an image
  this size has failed its size gate.

## Sources

- Ascendia kernel repo and default branch (`fifteen`):
  https://github.com/RisenID/kernel_samsung_ascendia_sm7125
  (named as the kernel in the UN1CA XDA thread for the A52 4G
  and A72 4G,
  https://xdaforums.com/t/eol-rom-14-a525f-m-a725f-m-un1ca-1-1-6-one-ui-6-for-galaxy-a52-4g-a72-4g-12-01-2024.4650551/).
- Kernel version 4.14.190: `Makefile` (VERSION 4, PATCHLEVEL 14,
  SUBLEVEL 190) in the same repo, branch `fifteen`, read live.
- Stock kernel `4.14.190-perf-28693687`: samfrew record for
  A525FXXU6FXD2,
  https://samfrew.com/download/Galaxy__A52__/dbzn/XFA/A525FXXU6FXD2/A525FOJM6FXD2
- Partition sizes (boot 100,663,296; recovery 81,788,928; DTBO
  25,165,824): `BoardConfig.mk` in
  https://github.com/TeamWin/android_device_samsung_a52q
  (branch android-12.1).
- TODO: no kernel build exists for the a52q in this project; no
  defconfig review; no EROFS or SELinux findings; no Gate 8 boot
  test; no artifact or SHA-256.
