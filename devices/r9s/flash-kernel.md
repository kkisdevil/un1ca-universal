# Flash the custom kernel - Galaxy S21 FE 5G (SM-G990E)

Flash a custom kernel on the SM-G990E. This file is for the
SM-G990E only (Exynos S21 FE 5G, codename r9s). Do not use it on
the Snapdragon FE (SM-G990B, SM-G990B2, SM-G990U) or any other
model.

## WARNING: no kernel build exists and the boot test has not been done

**There is no custom kernel build for the r9s in our repo, and no
kernel has ever booted on this phone from our work. Treat any
kernel flash here as untested until proven.** UN1CA ships its own
kernel path for this device: the kernel comes from the UN1CA build
itself (see [flash-un1ca.md](flash-un1ca.md)), so a separate
kernel flash is not part of the normal UN1CA flow. Do not flash a
kernel on a phone you need working today unless you have the
previous boot image ready to restore (step 3 below).

## What the kernel is

- **UN1CA kernel path (verified):** UN1CA builds the r9s kernel
  from its own kernel source, linked from the XDA release thread
  under the GPL policy:
  https://github.com/xfwdrev/android_kernel_samsung_ex2100
  (Exynos 2100 kernel source, maintainers @xfwdrev/@maximusXZ).
  That is the kernel a UN1CA flash installs. There is no separate
  kernel artifact to download for it.
- **Stock kernel (verified):** the GYI3 stock build runs kernel
  `5.4.242-30976065-abG990EXXSIGYI3` (SamFrew GYI3 record). The
  r9s recovery tree also names a kernel source,
  https://github.com/mohammad92/android_kernel_samsung_r9s, used
  to build the recovery.
- TODO: no our-repo kernel build exists, so there is no build
  number, run id, artifact name, size, SHA-256, or retention to
  list. No defconfig name, no EROFS/SELinux findings, and no build
  gates have been recorded for this device. Do not copy the m51
  kernel record (4.14.357-openela, m51_defconfig, 64 MB boot
  partition): every one of those values is m51-specific.
- TODO: the r9s boot partition size is not verified in this pass.
  Do not flash an image without checking it fits first.

## How it was built

TODO: no kernel has been built for this device in our repo, so
there is no toolchain, defconfig handling, or patch list to
record. If a build is started, record the toolchain (name,
commit, version), the defconfig (merged or reviewed savedefconfig,
and how many CONFIG lines), and every patch applied, here.

## Prereqs

1. **A custom recovery installed** ([flash-twrp.md](flash-twrp.md)).
   Use OrangeFox for UN1CA work (afaneh92's TWRP is rejected by
   the UN1CA installer).
2. **Back up everything** and back up EFS in the recovery first.
3. **Keep the old boot image on the phone before you flash the new
   one.** Extract `boot.img` from the stock AP tar (see
   [flash-stock.md](flash-stock.md)), or copy the last working
   kernel image. Without it, a bad boot has no quick way back.
4. **Battery above 50%, ideally full.**
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G990E**.
6. The kernel artifact, extracted to the boot image, with its
   SHA-256 checked against the build record. TODO: no artifact
   exists yet.

## Steps

TODO: the exact flash steps for a standalone r9s kernel are not
verified in this pass. The standard shape (same as the m51
procedure, adapted, not verified here) is:

1. Get the kernel artifact and extract the boot image. Check its
   SHA-256 against the build record above. TODO: no artifact or
   record exists yet.
2. Copy the new boot image **and** the old boot image (prereq 3)
   to the phone.
3. In the recovery: Install, **Install Image**, select the new
   boot image, flash to the **Boot** partition. (Or pack it into a
   `boot.tar` and flash it in Odin's AP slot.) Only the boot
   partition is written. Recovery is untouched. TODO: confirm the
   image format the r9s recovery expects (Image.gz-dtb, boot.img,
   or other) before flashing.
4. Reboot.
5. Check `adb shell uname -a` and `adb shell cat /proc/version`
   against the build record.

Do not run these steps until the TODOs above are resolved and a
real artifact exists.

## Verify

- `adb shell uname -a` shows the expected kernel version string.
  TODO: the exact expected string for a future build.
- `adb shell cat /proc/version` matches the build record.
- The phone boots to the home screen and stays up. Wi-Fi, calls,
  and sensors work as before the flash.
- If this is the first boot of a custom kernel on this phone,
  record the result (booted or not, plus `dmesg` and `logcat`) and
  report it. That record is Gate 8 for this device, and it has
  not been done.

## Rollback

If it does not boot, or anything regresses:

1. Reboot into the recovery (power off, hold Volume Up + Power,
   USB connected).
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
  TODO: the r9s boot partition size is not verified; confirm it
  before flashing any image.

## Next step

Flash UN1CA (which carries its own kernel):
[flash-un1ca.md](flash-un1ca.md). Or go back to stock:
[flash-stock.md](flash-stock.md).

## Sources

- UN1CA kernel path and kernel source:
  https://github.com/xfwdrev/android_kernel_samsung_ex2100
  (linked in "[ROM][16][G990E] UN1CA 3.1.0 (One UI 8.0) for
  Galaxy S21 FE 5G (Exynos)",
  https://xdaforums.com/t/rom-16-g990e-un1ca-3-0-6-one-ui-8-0-for-galaxy-s21-fe-5g-exynos-03-02-2026.4773337/).
- Stock kernel 5.4.242 on GYI3:
  https://samfrew.com/download/Galaxy__S21__FE__5G__/hqik/MYM/G990EXXSIGYI3/G990EOLMIGYI3
- Recovery kernel source:
  https://github.com/mohammad92/android_kernel_samsung_r9s
  (named in https://github.com/MLXProjects/recovery_samsung_r9s).
- Procedure shape (Install Image to Boot, rollback, Gate 8
  warning): `../m51/flash-kernel.md` in this repo (shape only;
  no m51 kernel version, defconfig, gates, or partition size are
  copied).
