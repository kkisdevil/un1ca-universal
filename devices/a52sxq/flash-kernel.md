# Flash the custom kernel - Galaxy A52s 5G (SM-A528B)

Flash a custom kernel on the SM-A528B. This file is for the
SM-A528B only. Do not use it on any other model.

## WARNING: no kernel build exists for this device in this project

**There is no porter kernel build for the A52s, and no kernel
has ever booted on this phone from this project. Treat any kernel
flash here as untested until it has booted.** There is no build
number, run id, artifact, size, or SHA-256 to record, and no
build gates have been run for this device. Do not flash a kernel
on a phone you need working today unless you have the previous
boot image ready to restore (step 4 below).

## What the kernel is

There is no kernel to describe yet. What is known about kernels
on this device:

- Stock kernel: `5.4.254-qgki` (recorded in the SamFrew firmware
  record for the SIO A528BXXSAGYA2 build:
  `5.4.254-qgki-28575149-abA528BXXSAGYA2`). The GYI3 build's
  kernel version is TODO: record it from the phone or the
  firmware record after the stock flash.
- UN1CA kernel: the upstream releases changelog says the kernel
  for A52s/A73/M52 was updated to **5.4.302** in the 3.2.1
  release. TODO: confirm the exact kernel string on a phone
  running UN1CA 3.2.1.
- TWRP kernel source (for reference, not a boot kernel):
  https://github.com/BlackMesa123/android_kernel_samsung_sm7325/tree/sep-15/twrp-12.1
- Samsung open-source kernel releases for this model are listed
  under the ORSC search value A528 (linked from the XDA UN1CA
  thread): https://opensource.samsung.com/uploadSearch?searchValue=A528

TODO: choose a kernel source for this device (stock ORSC source,
or the UN1CA kernel), record the repo, branch, version, and
defconfig name, and only then write a build record here. Do not
copy the m51 kernel source, defconfig, or build gates: the m51 is
a different SoC (sm7150, kernel 4.14) and a different tree.

## How it was built

TODO: nothing has been built. When a build is made, record here:
toolchain (name, commit, version), defconfig handling, patches
applied, and the build gates and their results. The boot
partition size for this device is **unknown**: it is not in
upstream `target/a52sxq/config.sh` (that file has no boot
partition size line), so no size gate can be written until the
partition table is read from the phone. TODO: read the boot
partition size from the phone and record it here before any
kernel is flashed.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first.
3. **Keep the old boot image on the phone before you flash the new
   one.** Extract `boot.img` from the stock AP tar (see
   [flash-stock.md](flash-stock.md)), or copy the last working
   kernel image. Without it, a bad boot has no quick way back.
4. **Battery above 50%, ideally full.**
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A528B**.
6. The kernel artifact, extracted to the boot image, with its
   SHA-256 checked against the build record. TODO: no artifact
   exists yet; this prereq cannot be met today.

## Steps

1. Get the kernel artifact from the run page and extract the boot
   image. Check its SHA-256 against the build record. TODO: no
   artifact exists yet.
2. Copy the new boot image **and** the old boot image (prereq 3)
   to the phone.
3. In TWRP: Install, **Install Image**, select the new boot image,
   flash to the **Boot** partition. (Or pack it into a `boot.tar`
   and flash it in Odin's AP slot.) Only the boot partition is
   written. Recovery is untouched.
4. Reboot.
5. Check `adb shell uname -a` shows the expected kernel version
   and `adb shell cat /proc/version` matches the build record.
   TODO: record the expected version string once a build exists.

## Verify

- `adb shell uname -a` shows the expected kernel version.
- `adb shell cat /proc/version` matches the build record.
- The phone boots to the home screen and stays up. Wi-Fi, calls,
  and sensors work as before the flash.
- Check the 120 Hz display still works at 120 Hz: this phone's
  default refresh rate is 120 (upstream config line 67). A kernel
  that locks it to 60 Hz is a regression to record.
- If this is the first boot of this kernel on this phone, record
  the result (booted or not, plus `dmesg` and `logcat`) and report
  it. That record is the boot test (Gate 8 in m51 terms).

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
  broke with a `dmesg` capture. Note the XDA reports of Wi-Fi
  breaking on UN1CA 3.x builds for this device (see
  [flash-un1ca.md](flash-un1ca.md)); Wi-Fi is a known weak point
  on the A52s, so test it first after any kernel flash.
- **Image too large for the boot partition.** Do not flash it.
  TODO: the boot partition size is unknown for this device.
  Record it here before any kernel is flashed, and add a build
  gate that rejects an image that does not fit.

## Sources

- SamFrew SIO A528BXXSAGYA2 record (stock kernel 5.4.254-qgki):
  https://samfrew.com/download/Galaxy__A52s__5G__/kjen/SIO/A528BXXSAGYA2/A528BOXMAGYA2
- Upstream UN1CA releases (kernel updated to 5.4.302 for
  A52s/A73/M52): https://github.com/salvogiangri/UN1CA/releases
- Upstream `target/a52sxq/config.sh` line 67 (HFR default 120):
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/a52sxq/config.sh
- TWRP kernel source:
  https://github.com/BlackMesa123/android_kernel_samsung_sm7325/tree/sep-15/twrp-12.1
- Samsung ORSC kernel source search for A528:
  https://opensource.samsung.com/uploadSearch?searchValue=A528
- TODO: choose a kernel source and defconfig for this device.
  TODO: read the boot partition size from the phone. TODO: build
  record (toolchain, gates, artifact, SHA-256). TODO: boot test
  (Gate 8) has not been done.
