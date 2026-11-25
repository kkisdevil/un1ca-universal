# Flash the custom kernel - Galaxy S21+ 5G (SM-G996B)

Flash a custom kernel on the SM-G996B. This file is for the
SM-G996B only. Do not use it on any other model.

## WARNING: no custom kernel exists for this device

**There is no custom kernel build for t2s in this repo, and no
kernel has ever booted on a t2s from this project. Do not flash
anything from this file yet.** A green build is not a booting
kernel, and here there is not even a build. Everything below the
prereqs is the procedure to use once a kernel exists, not a
report of one.

What is verified: UN1CA ships its own kernel path for this
device. The kernel comes from the UN1CA build itself (the
installer flashes firmware; the kernel is part of what the UN1CA
build produces for the target), so there is no separate kernel
to flash for a stock UN1CA install. A standalone custom kernel
for t2s would be a separate project from UN1CA, and it does not
exist yet.

TODO: kernel source (repo, branch, version), defconfig name,
EROFS support, SELinux mode, build number, run id, artifact
name, size, SHA-256, retention, build gates, toolchain, patches,
and boot partition size for t2s. None of these is known. Do not
copy the m51 kernel facts (crDroid sm7150 tree, 4.14.357-openela,
m51_defconfig, 64 MB boot partition): the t2s is an Exynos 2100
phone, its kernel is a different tree, and its boot partition
size is unverified.

## What the kernel would be

TODO. Until a t2s kernel source is chosen, this section stays
empty. The stock t2s kernel on Android 15 is 5.4.x (a
deviceinfo.app record for SM-G996B reports kernel 5.4.242 on One
UI 7), but that is the stock kernel, not a custom build, and it
is not a basis for flashing anything.

## How it would be built

TODO. No toolchain, defconfig, or patch set exists for t2s in
this repo.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first.
3. **Keep the old boot image on the phone before you flash the new
   one.** Extract `boot.img` from the stock AP tar (see
   [flash-stock.md](flash-stock.md)), or copy the last working
   kernel image. Without it, a bad boot has no quick way back.
4. **Battery above 50%, ideally full.**
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G996B** (or SM-G996B/DS).
6. The kernel artifact from the run page, extracted to the boot
   image, with its SHA-256 checked against the build record.
   TODO: no artifact exists yet.

## Steps

TODO: these steps are the standard TWRP Install Image shape,
not yet run for t2s. Confirm each one against the first t2s
kernel build.

1. Get the kernel artifact from the run page and extract the boot
   image. Check its SHA-256 against the build record above.
2. Copy the new boot image **and** the old boot image (prereq 3)
   to the phone.
3. In TWRP: Install, **Install Image**, select the new boot image,
   flash to the **Boot** partition. (Or pack it into a `boot.tar`
   and flash it in Odin's AP slot.) Only the boot partition is
   written. Recovery is untouched.
4. Reboot.
5. Check `adb shell uname -a` and `adb shell cat /proc/version`
   against the build record.

## Verify

- `adb shell uname -a` shows the new kernel version string.
- `adb shell cat /proc/version` matches the build record.
- The phone boots to the home screen and stays up. Wi-Fi, calls,
  and sensors work as before the flash.
- If this is the first boot of this kernel on this phone, record
  the result (booted or not, plus `dmesg` and `logcat`) and report
  it. That record is the boot test (Gate 8 in the m51 kernel
  guide).

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
- **Image too large for the boot partition.** TODO: the t2s boot
  partition size is unverified. Do not state a size limit, and
  do not flash an image whose size has not been checked against
  the real partition.

## Sources

- Upstream UN1CA `target/t2s/config.sh` (salvogiangri/UN1CA,
  branch sixteen, UN1CA 3.2.1): the UN1CA build is the kernel
  path for this device; no separate kernel target is listed in
  `target/t2s/`. Read live 2026-11-25.
- Stock kernel 5.4.242 on One UI 7 (Android 15) for SM-G996B:
  deviceinfo.app record:
  https://www.deviceinfo.app/devices/samsung/galaxy-s21-plus-5g/
- Guide structure and Gate 8 concept:
  [../m51/flash-kernel.md](../m51/flash-kernel.md) (shape only;
  no m51 kernel facts were copied).

## TODO

- Choose a t2s kernel source and defconfig, or decide that no
  standalone kernel will be built and this file should be
  deleted (the template says to delete it if no kernel build
  exists for the device; it is kept for now as a stub because
  the UN1CA kernel path is still being worked out).
- Boot partition size for t2s.
- First kernel build: number, run id, artifact, size, SHA-256,
  gates, toolchain, patches.
- First boot test (Gate 8) on a real phone.
