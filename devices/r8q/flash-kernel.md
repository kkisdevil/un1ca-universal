# Flash the custom kernel - Galaxy S20 FE (Snapdragon) (SM-G780G)

Flash the UN1CA sm8250 kernel on the SM-G780G. This file is for
the SM-G780G only. Do not use it on any other model, including
the Exynos S20 FE (SM-G780F).

## WARNING: the boot test has not been done

**The kernel has never been flashed or booted by us on an r8q.
Treat it as untested until it has.** No porter kernel build exists
for this phone. The kernel below is the upstream UN1CA kernel,
built by UN1CA's own CI, and it is the same kernel the UN1CA r8q
build installs. Flash it only if you accept that risk and you have
the previous boot image ready to restore (step 3 below). Do not
flash this kernel on a phone you need working today.

## What the kernel is

The UN1CA kernel for the sm8250 platform (Snapdragon 865), from
https://github.com/UN1CA/kernel_samsung_sm8250, branch `sixteen`.
It is Linux **4.19.325** (Makefile: VERSION 4, PATCHLEVEL 19,
SUBLEVEL 325). The stock kernel on the latest r8q firmware is
4.19.113, so this is a newer 4.19 than stock.

Latest release at research time (2026-11-25):
**UN1CA-r8q-20261007-164834** (released 2026-10-07 16:48 UTC),
kernel version `4.19.325-cip136-st20-perf-g86f2504e4af5`, source
commit `86f2504e4af5c878d327a225682ad988d78016e4`, 4 assets. The
UN1CA r8q build downloads `boot.img` and `dtbo.img` from the
latest release of this repo
(`target/r8q/patches/kernel/customize.sh`).

Boot partition size is 64 MB (`TARGET_BOOT_PARTITION_SIZE`
67108864 in `target/r8q/config.sh`, line 24). DTBO partition size
is 10 MB (`TARGET_DTBO_PARTITION_SIZE` 10485760, line 26). Any
boot image larger than 64 MB must not be flashed.

TODO: defconfig name, toolchain, build gates, EROFS support and
SELinux mode are not verified for this kernel. TODO: record the
release asset sizes and hashes here once a release is downloaded
and checked.

## How it is built

Upstream CI builds it in the kernel repo
(https://github.com/UN1CA/kernel_samsung_sm8250, `.github/workflows`).
We have not read that workflow, and no porter kernel build exists
for r8q. TODO: read the upstream kernel workflow, record the
toolchain and defconfig, and add a porter kernel build before
recommending a local build.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first.
3. **Keep the old boot image on the phone before you flash the new
   one.** Extract `boot.img` from the stock AP tar (see
   [flash-stock.md](flash-stock.md)), or copy the last working
   kernel image. Without it, a bad boot has no quick way back.
   Also keep the old `dtbo.img` if you flash a new one.
4. **Battery above 50%, ideally full.**
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G780G**.
6. The kernel release assets from the releases page above,
   extracted to the boot image (`boot.img`, plus `dtbo.img` if
   you flash DTBO), with their hashes checked against the release
   record. TODO: no asset hashes are recorded here yet.

## Steps

1. Get the latest release assets from
   https://github.com/UN1CA/kernel_samsung_sm8250/releases and
   extract the boot image (`boot.img`, and `dtbo.img` if you mean
   to flash DTBO). Check their hashes against the release record
   above.
2. Copy the new boot image **and** the old boot image (prereq 3)
   to the phone.
3. In TWRP: Install, **Install Image**, select the new boot image,
   flash to the **Boot** partition. (Or pack it into a `boot.tar`
   and flash it in Odin's AP slot.) Only the boot partition is
   written. Recovery is untouched.
4. If you also flash `dtbo.img`: in TWRP, Install, Install Image,
   select it, flash to the **DTBO** partition. TODO: confirm the
   DTBO partition is offered by TWRP on this phone before doing
   this; if it is not, do not flash DTBO.
5. Reboot.
6. Check `adb shell uname -a` shows `4.19.325-cip136-st20-perf`
   and `adb shell cat /proc/version` matches.

## Verify

- `adb shell uname -a` shows `4.19.325-cip136-st20-perf`.
- `adb shell cat /proc/version` matches the build record.
- The phone boots to the home screen and stays up. Wi-Fi, calls,
  and sensors work as before the flash.
- If this is the first boot of this kernel on this phone, record
  the result (booted or not, plus `dmesg` and `logcat`) and report
  it. That record is the boot test this phone still owes.

## Rollback

If it does not boot, or anything regresses:

1. Reboot into TWRP (power off, hold Volume Up + Power with the
   USB cable connected).
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
  image. Check the release name (`UN1CA-r8q-20261007-164834`) and
  the hashes, then re-flash the right one.
- **Phone boots but Wi-Fi or sensors broke.** The kernel and the
  vendor blobs disagree. Roll back, and report which function
  broke with a `dmesg` capture.
- **`boot.img` is 64 MB or larger.** Do not flash it. The boot
  partition is 64 MB. An image this size means the asset is not
  the one from the release above.

## Sources

- Kernel repo, branch sixteen, commit 86f2504:
  https://github.com/UN1CA/kernel_samsung_sm8250
- Kernel version 4.19.325-cip136-st20-perf, latest release
  UN1CA-r8q-20261007-164834:
  https://github.com/UN1CA/kernel_samsung_sm8250/releases
- Kernel version from the Makefile (VERSION 4, PATCHLEVEL 19,
  SUBLEVEL 325):
  https://raw.githubusercontent.com/UN1CA/kernel_samsung_sm8250/sixteen/Makefile
  (lines 2 to 8)
- The UN1CA r8q build downloads boot.img and dtbo.img from this
  repo's latest release:
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/r8q/patches/kernel/customize.sh
- Boot partition 64 MB, DTBO partition 10 MB:
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/r8q/config.sh
  (lines 24 to 26)
- Stock kernel 4.19.113 on the latest firmware:
  https://samfrew.com/download/Galaxy__S20__FE__/19hp/TPL/G780GXXSEEXL1/G780GOXMEEXL1
