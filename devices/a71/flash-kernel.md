# Flash the custom kernel - Galaxy A71 (SM-A715F)

Flash a custom kernel on the SM-A715F. This file is for the
SM-A715F only. Do not use it on any other model. Do not use it
on the Galaxy A71 5G (SM-A716, codename a71xq): that is a
different phone.

## Boot test warning

**No custom kernel has booted on an A71 in this project.** There
is no a71 kernel build in our repos. A green build is not a
booting kernel. Nothing in this file has been run end-to-end on
an A71 by us. Read the whole file before flashing anything.

## What the kernel is

There are three candidate kernels for this device. None has
been built by us.

**1. The UN1CA Paradigm kernel (the one UN1CA ships).** The
UN1CA a71 target downloads it as `boot.img` + `dtbo.img` from
https://github.com/UN1CA/kernel_samsung_sm7150/releases/latest/download
(`target/a71/patches/kernel/customize.sh`, Arnav `seventeen`).
Latest release 20261106-144920: boot.img 49,889,280 B, dtbo.img
2,346,289 B. The boot image fits the 64 MB boot partition
(67,108,864 B). **TODO: the kernel version, defconfig, and
source commit for this release were not recorded.** The release
is a binary download, not a source build.

**2. The crDroid sm7150 kernel (the candidate for our own
build).** Source: `crdroidandroid/android_kernel_samsung_sm7150`,
branch 16.0, version 4.14.357-openela (the same tree the m51
kernel build uses). The tree's `arch/arm64/configs/` holds an
`a71.config` fragment (plus a70q, m51.config, and a generic
defconfig). **TODO: no a71 kernel build has been run from this
tree.** The m51 build gates (defconfig, olddefconfig,
savedefconfig, Image.gz-dtb size, kernelrelease, EROFS, SELinux)
would apply, but none has been run for a71.

**3. Prime Kernel (pascua28).** "Prime Kernel for A71 4G" by
pascua28 is the kernel the seelenchik GSI threads flash on the
A71 (a `boot.img` in TWRP, before the GSI). **TODO: the exact
version, source commit, and whether it is still maintained were
not recorded.** It is a third-party binary, not our build.

**Defconfig and source layout (from the device trees).**
`a71-devs/android_device_samsung_a71@lineage-22.2`,
`BoardConfig.mk:24`: `TARGET_KERNEL_CONFIG := a71_defconfig`.
`a71-devs/android_device_samsung_a71-common@lineage-22.2`,
`BoardConfigCommon.mk`: `BOARD_KERNEL_IMAGE_NAME :=
Image.gz-dtb`, `TARGET_KERNEL_SOURCE := kernel/samsung/a71`,
`BOARD_KERNEL_SEPARATED_DTBO := true`, `BOARD_KERNEL_PAGESIZE :=
4096`. The LineageOS kernel source for this device is
`a71-devs/android_kernel_samsung_a71` (lineage-22.2, 4.14.336),
which the HyperOS port work superseded in favour of the crDroid
sm7150 tree (4.14.357-openela). **TODO: whether the crDroid
tree's `a71.config` fragment plus `a71_defconfig` builds
cleanly is unproven.** The two bugs fixed in the m51 kernel
build (the NPU Makefile `:=` overwrite and the `__qdf_bug`
WLAN_DEBUG guard) are in the same tree family; check whether
they affect an a71 build before running one.

**Boot partition: 67,108,864 B (64 MB).**
`target/a71/config.sh:15` (Arnav `seventeen`, identical in
Mehedi `sixteen`). DTBO partition: 10,485,760 B (10 MB)
(`config.sh:16`). Any kernel image that does not fit 64 MB
cannot be flashed.

## How it was built

**TODO: no a71 kernel build exists in our repos.** The m51
kernel build (`.github/workflows/build-kernel.yml` in the
m51-hyperos repo, toolchain kdrag0n/proton-clang commit
`9fb011b183fe7e69b04b873ef6533b4b077e3c5e`, Clang 13.0.0) is
m51-only. An a71 build would need its own workflow (or a
parameterised one) with `a71_defconfig` and the `a71.config`
fragment, and its own Gate 8 boot test on a real A71.

## Prereqs

1. **Unlocked bootloader.** Do
   [unlock-bootloader.md](unlock-bootloader.md) first.
2. **TWRP installed.** Do
   [flash-twrp.md](flash-twrp.md) first.
3. **Back up everything** (and back up EFS in TWRP).
4. **Keep the old boot image on the phone before flashing the
   new one.** Pull the stock `boot.img` out of the AP tar (see
   [flash-stock.md](flash-stock.md)), or back up the Boot
   partition in TWRP. Without it you cannot roll back without a
   full stock flash.
5. **Battery above 50%, ideally full.**
6. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A715F**.
7. **The kernel artifact, extracted to the boot image, with its
   SHA-256 checked.** **TODO: no a71 kernel artifact exists
   yet, so there is nothing to check.**

## Steps

1. Copy the kernel `boot.img` (and `dtbo.img`, if the kernel
   ships one) onto the phone.
2. Boot into TWRP (power off, hold Volume Up + Power).
3. Install, Install Image, choose the `boot.img`, flash it to
   the **Boot** partition. If the kernel ships a `dtbo.img`,
   flash it to the **DTBO** partition the same way.
4. **Confirm only the boot partition (and dtbo, if used) was
   written.** Recovery is untouched: the kernel image goes to
   Boot, never to Recovery. Check the TWRP log after the flash:
   it must show only the Boot (and DTBO) partition written.
5. Reboot to System. First boot after a kernel change can take
   a few minutes.

**Odin route (alternative).** Pack the `boot.img` into a
`boot.tar` (tar, no compression) and flash it in Odin's **AP
slot**. **TODO: the Odin route for a kernel on a71 has not
been verified by us.** The TWRP route above is the one to use.

## Verify

- `adb shell uname -a` and `adb shell cat /proc/version` show
  the new kernel version (for example `4.14.357-openela` for a
  crDroid-tree build).
- Wi-Fi connects. Calls work. Sensors work (proximity,
  accelerometer, fingerprint).
- The phone does not bootloop and does not overheat at idle.
- **Record the first boot result.** That is Gate 8 for this
  device. Until it is recorded, the kernel is unboot-tested.

## Rollback

1. Boot into TWRP.
2. Install, Install Image, choose the **old** `boot.img` you
   saved in Prereqs step 4, flash it to the **Boot** partition.
   (And the old `dtbo.img` to DTBO, if you flashed one.)
3. Reboot to System.
4. If you do not have the old boot image, flash the stock AP
   in Odin ([flash-stock.md](flash-stock.md)) or flash the full
   stock firmware. That restores the stock kernel and removes
   TWRP (re-flash TWRP afterwards if you need it).

## Troubleshooting

- **Bootloop after flashing.** Do not wipe data first: the
  kernel is the problem, not your data. Roll back the boot
  image (above). Wiping data would lose your files for no
  reason.
- **Kernel version string is wrong.** You flashed the wrong
  image, or the build's `LOCALVERSION` was not set. Check
  `uname -a` and compare with the build record.
- **Wi-Fi or sensors broke after flashing.** The kernel and the
  vendor blobs do not match. The stock vendor (VNDK 31, kernel
  4.14) expects the stock kernel's module ABI. Roll back.
- **Image too large for the boot partition.** The boot partition
  is 64 MB (67,108,864 B). The Paradigm boot.img is 49,889,280
  B and fits. If a build produces a larger image, it cannot be
  flashed. Shrink it (strip debug symbols, drop modules) or do
  not flash it.

## Sources

- Boot partition 67,108,864 B, DTBO 10,485,760 B:
  Arnav3078/UN1CA-SM7150@seventeen, `target/a71/config.sh:15-16`
  (identical in mehedihjoy0/UN1CA-SM7150@sixteen).
- Paradigm kernel download (boot.img + dtbo.img from
  UN1CA/kernel_samsung_sm7150 releases/latest/download):
  Arnav3078/UN1CA-SM7150@seventeen,
  `target/a71/patches/kernel/customize.sh`. Latest release
  20261106-144920, boot.img 49,889,280 B, dtbo.img 2,346,289 B:
  GitHub API,
  https://api.github.com/repos/UN1CA/kernel_samsung_sm7150/releases/latest
  (2026-11-25).
- `a71_defconfig`, kernel source `kernel/samsung/a71`,
  `Image.gz-dtb`, page size 4096, separated DTBO:
  a71-devs/android_device_samsung_a71@lineage-22.2,
  `BoardConfig.mk:24`; a71-devs/android_device_samsung_a71-common@lineage-22.2,
  `BoardConfigCommon.mk`.
- crDroid sm7150 tree (4.14.357-openela) and `a71.config`
  fragment in `arch/arm64/configs/`: crdroidandroid/android_kernel_samsung_sm7150@16.0
  (directory listing, 2026-11-25). The m51 kernel build from
  the same tree is the reference; no a71 build has been run.
- Prime Kernel for A71 4G by pascua28, used in the seelenchik
  GSI threads: XDA GSI threads for a71 (searched 2026-11-25).
- The NPU Makefile and `__qdf_bug` bugs fixed in the m51 kernel
  build: the m51 kernel record (same tree family; unproven for
  a71).
