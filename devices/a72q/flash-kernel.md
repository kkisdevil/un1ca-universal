# Flash the custom kernel - Galaxy A72 (SM-A725F)

Flash a custom kernel on the SM-A725F. This file is for the
SM-A725F only. Do not use it on any other model.

## WARNING: no custom kernel build exists for this device yet

**No custom kernel has been built for the a72q in this porter,
and no kernel has ever booted on this phone from our work. There
is no build number, no run id, no artifact, and no Gate 8 boot
test.** A green build is not a booting kernel, and here there is
not even a build yet. Do not flash any kernel image on a phone
you need working today until the first build exists and its
record is written here. This file is kept (not deleted) so the
stock kernel facts and the flash procedure are recorded in one
place, and so the first build has a checklist to fill.

## What the kernel is

The stock kernel is Linux **4.14.190-perf**, build string
`4.14.190-perf-28694960-abA725FXXSBFYC1` on the FYC1 firmware.
That is the kernel the phone ships with today, and the kernel
any custom build starts from. The A72 SoC is the Snapdragon
720G (sm7125), and the stock kernel source for this device
family is the Samsung sm7125 kernel tree. TODO: name the exact
kernel source repo, branch, and defconfig for the a72q build
once the build project is set up. Likely candidates to check:
the LineageOS / crDroid sm7125 kernel trees and the Samsung
open source release for SM-A725F. Do not record one as the
source until it is actually used for a build.

TODO, for the first build, fill in:

- Kernel source (repo, branch, version), defconfig name, EROFS
  support, SELinux mode.
- Latest build number, run id, artifact name, size, SHA-256,
  retention.
- Which build gates exist for this device and which passed.

## How it was built

TODO: no build exists yet. When the first build runs, record
here: the toolchain (name, commit, version), the defconfig
handling (merged or reviewed savedefconfig, and how many CONFIG
lines), the patches applied for this device, and the bugs fixed
along the way. Do not copy another tree's build scripts blindly
if they carry the same bugs: the m51 build found two bugs
(NPU Makefile `:=` overwrite, `__qdf_bug` hidden behind the
WLAN_DEBUG guard) in trees that share this Qualcomm heritage,
so check for them here before trusting a borrowed script.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first.
3. **Keep the old boot image on the phone before you flash the new
   one.** Extract `boot.img` from the stock AP tar (see
   [flash-stock.md](flash-stock.md)), or copy the last working
   kernel image. Without it, a bad boot has no quick way back.
4. **Battery above 50%, ideally full.**
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A725F**.
6. The kernel artifact from the run page, extracted to the boot
   image, with its SHA-256 checked against the build record
   above. TODO: fill in the artifact name and hash once the
   first build exists.

## Steps

1. Get the kernel artifact from the run page and extract the boot
   image. Check its SHA-256 against the build record above.
2. Copy the new boot image **and** the old boot image (prereq 3)
   to the phone.
3. In TWRP: Install, **Install Image**, select the new boot image,
   flash to the **Boot** partition. (Or pack it into a `boot.tar`
   and flash it in Odin's AP slot.) Only the boot partition is
   written. Recovery is untouched.
4. Reboot.
5. Check `adb shell uname -a` shows the new kernel version and
   `adb shell cat /proc/version` matches the build record.

## Verify

- `adb shell uname -a` shows the new kernel version string.
- `adb shell cat /proc/version` matches the build record.
- The phone boots to the home screen and stays up. Wi-Fi, calls,
  and sensors work as before the flash.
- If this is the first boot of this kernel on this phone, record
  the result (booted or not, plus `dmesg` and `logcat`) and report
  it. That record is Gate 8.

## Rollback

If it does not boot, or anything regresses:

1. Reboot into TWRP (power off, hold Volume Up + Power).
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
  partition size for this device is not recorded anywhere in
  the sources used for this guide. It is not in
  `target/a72q/config.sh`. Measure it from a live phone
  (`cat /proc/partitions` or the PIT) and record it here before
  the first build. Do not assume the m51 64 MB value: that is a
  different device.

## Sources

- Stock kernel string:
  https://samfrew.com/download/Galaxy__A72__/3tpt/SEK/A725FXXSBFYC1/A725FOXMBFYC1
  (`4.14.190-perf-28694960-abA725FXXSBFYC1` on FYC1).
- Upstream target config:
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/a72q/config.sh
  line 7 (`TARGET_PLATFORM="sm7125"`). No boot partition size,
  no kernel source, and no defconfig are in the target.
- The m51 kernel build record in this porter is the model for
  the gates and the procedure, not the source of any a72q fact.
  No a72q kernel build, artifact, or boot test exists yet.
