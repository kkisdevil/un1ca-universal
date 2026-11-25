# Flash the custom kernel - Galaxy S21 Ultra 5G (SM-G998B)

Flash a custom kernel on the SM-G998B. This file is for the
SM-G998B only. Do not use it on any other model.

## WARNING: no custom kernel build exists for this device yet

**There is no p3s kernel build. No kernel has been built for this
device in our repos, and no kernel has booted on a p3s in front of
us. Treat this file as a stub until a build exists.** A green
build is not a booting kernel, and here there is not even a build
yet. Do not flash any kernel image on a phone you need working
today, and do not flash a kernel built for another device (o1s,
t2s, m51, or any other codename) on a p3s.

## What the kernel is

UN1CA ships its own kernel path for this device: the kernel comes
from the UN1CA build for p3s, not from a separate kernel project
in this repo. The upstream UN1CA installer flashes the firmware
for the target, and the kernel is part of that build. No separate
p3s kernel artifact, defconfig, or build record exists in our
porter yet.

What is verified:

- Stock kernel on the current AUT firmware is
  `5.4.242-30958140-abG998BXXSJHZC2` (firmware record, see
  [flash-stock.md](flash-stock.md)). The stock kernel version
  family is 5.4.
- The XDA o1s UN1CA thread links this kernel source as the
  upstreamed source for the S21 family, as required by the XDA GPL
  policy: https://github.com/xfwdrev/android_kernel_samsung_ex2100
  (exynos2100 kernel). TODO: verify that this tree covers p3s
  specifically (defconfig name, p3s device support) before using
  it for a p3s build. It is linked in the o1s thread, not a p3s
  thread, so it is a lead, not a verified p3s source.
- The UN1CA 3.2.1 changelog lists a kernel update to 5.4.302 for
  A52s, A73 and M52 only. No kernel version is listed for p3s in
  that changelog. TODO: record the kernel version inside the
  UN1CA 3.2.1 p3s zip once it is downloaded and inspected.

TODO, not verified:

- TODO: kernel source repo and branch for a standalone p3s build.
- TODO: defconfig name for p3s.
- TODO: EROFS support and SELinux mode for a p3s kernel build.
- TODO: boot partition size for p3s. Do not copy the m51 64 MB
  figure: it is not verified for this device.
- TODO: latest build number, run id, artifact name, size,
  SHA-256, retention.
- TODO: build gates for p3s and which passed.

## How it was built

TODO: no build has been run. When one is run, record here the
toolchain (name, commit, version), the defconfig handling, the
patches applied, and the bugs fixed along the way. Do not copy
another tree's build scripts blindly if they carry the same bugs
(the m51 record names two such bugs in the sm7150 trees; whether
the exynos2100 trees share them is TODO, not assumed).

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first.
3. **Keep the old boot image on the phone before you flash the new
   one.** Extract `boot.img` from the stock AP tar (see
   [flash-stock.md](flash-stock.md)), or copy the last working
   kernel image. Without it, a bad boot has no quick way back.
4. **Battery above 50%, ideally full.**
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G998B**.
6. The kernel artifact, extracted to the boot image, with its
   SHA-256 checked against the build record. TODO: no artifact
   exists yet, so this step cannot be completed.

## Steps

TODO: no verified steps exist for p3s yet. The generic shape,
to be confirmed against the first real build, is:

1. Get the kernel artifact from the run page and extract the boot
   image. Check its SHA-256 against the build record.
2. Copy the new boot image **and** the old boot image (prereq 3)
   to the phone.
3. In TWRP: Install, **Install Image**, select the new boot image,
   flash to the **Boot** partition. (Or pack it into a `boot.tar`
   and flash it in Odin's AP slot.) Only the boot partition is
   written. Recovery is untouched.
4. Reboot.
5. Check `adb shell uname -a` and `adb shell cat /proc/version`
   against the build record.

Do not run these steps until a p3s kernel artifact exists and its
build record is filled in above. The TWRP Install Image to Boot
shape is shared Samsung practice from `../m51/flash-kernel.md`;
the image itself, its size limit, and its version string are all
p3s TODOs.

## Verify

- `adb shell uname -a` shows the kernel version from the build
  record. TODO: no version string exists yet.
- `adb shell cat /proc/version` matches the build record.
- The phone boots to the home screen and stays up. Wi-Fi, calls,
  and sensors work as before the flash.
- If this is the first boot of this kernel on this phone, record
  the result (booted or not, plus `dmesg` and `logcat`) and report
  it. That record is Gate 8 for this device.

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
- **Image too large for the boot partition.** TODO: the boot
  partition size for p3s is not verified. Do not flash an image
  whose size has not been checked against the real partition size.

## TODO

- TODO: p3s kernel source, defconfig, toolchain, and build.
- TODO: verify the xfwdrev exynos2100 kernel tree covers p3s.
- TODO: boot partition size for p3s.
- TODO: kernel version inside the UN1CA 3.2.1 p3s zip.
- TODO: Gate 8 (first boot test) on a real p3s. Not done; no
  build exists to test.

## Sources

- Stock kernel `5.4.242-30958140-abG998BXXSJHZC2`: SamFrew AUT
  record,
  https://samfrew.com/download/Galaxy__S21__Ultra__5G__/tbqu/AUT/G998BXXSJHZC2/G998BOXMJHZC2
- Kernel source lead (o1s thread, not p3s-verified):
  https://github.com/xfwdrev/android_kernel_samsung_ex2100
  linked from XDA, "[ROM][16][G991B] UN1CA 3.1.0 (One UI 8.0) for
  Galaxy S21 5G (Exynos) (04/06/2026)",
  https://xdaforums.com/t/rom-16-g991b-un1ca-3-0-6-one-ui-8-0-for-galaxy-s21-5g-exynos-03-02-2026.4773332/
- UN1CA ships its own kernel as part of its build for the target:
  upstream repo https://github.com/salvogiangri/UN1CA, branch
  `sixteen`, `target/p3s/`; no separate p3s kernel target was
  found in that listing.
- TWRP Install Image to Boot shape and rollback steps: shared
  practice, verified in `../m51/flash-kernel.md`.

## Next step

Flash the stock ROM back if needed: [flash-stock.md](flash-stock.md).
