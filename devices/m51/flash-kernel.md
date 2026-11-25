> Mirror of the verified m51 guides. Canonical home is the [m51-hyperos repo](https://github.com/kkisdevil/m51-hyperos) (`docs/devices/m51/`); if the two copies disagree, that copy wins.

# Flash the custom kernel - Galaxy M51 (SM-M515F)

Flash our own m51 kernel on the SM-M515F. This file is for the
SM-M515F only. Do not use it on any other model.

## WARNING: the boot test has not been done

**Gate 8, the boot test, has not been done. The kernel has never
booted on the phone. Treat it as untested until it has.** Build #8
is green on GitHub (all 7 build gates passed), but a green build
is not a booting kernel. Flash it only if you accept that risk and
you have the previous boot image ready to restore (step 4 below).
Do not flash this kernel on a phone you need working today.

## What the kernel is

Our own m51 kernel, built on GitHub from the crDroid sm7150 tree
(4.14.357-openela) with a reviewed `m51_defconfig` (EROFS LZ4
only, SELinux permissive possible). **Build #8 is green** (run
45372379403, 15m 4s, all 7 gates passed): artifact `m51-kernel-8`,
36.9 MB, SHA-256
`c7086a7e4d05701156138f529da94a06fa898d311aa725a16116be78af8b78ae`,
14-day retention.

## How it was built

Toolchain pinned to kdrag0n/proton-clang (commit `9fb011b`,
Clang 13.0.0). The workflow installs our merged
`kernel/m51_defconfig` (SHA-256 verified), applies
`patches/kernel/*.patch` (`git apply --check` first), runs `make
m51_defconfig`, then `olddefconfig`, then the build, then
`savedefconfig`, and uploads the artifacts. Seven gates:
defconfig completes; olddefconfig keeps every boot-critical
symbol; savedefconfig uploaded; Image.gz-dtb is at least 1 MB and
under 64 MB (the boot partition is 64 MB); kernelrelease is exactly
`4.14.357-openela`; EROFS_FS plus EROFS_FS_ZIP are =y with no LZMA;
SECURITY_SELINUX_DEVELOP is =y. The savedefconfig was committed
back to the repo after review (909 CONFIG lines). Full record:
[../../kernel-build.md](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/kernel-build.md),
[../../kernel-defconfig-plan.md](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/kernel-defconfig-plan.md).

Two bugs fixed along the way (NPU Makefile `:=` overwrite,
`__qdf_bug` hidden behind the WLAN_DEBUG guard) are also present in
Mehedi's and LostPrime's trees. Do not copy those trees' build
scripts blindly. LostPrime's toolchain comes from a secret URL we
cannot reproduce, and its Nov 11 release is self-flagged corrupted.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first.
3. **Keep the old boot image on the phone before you flash the new
   one.** Extract `boot.img` from the stock AP tar (see
   [flash-stock.md](flash-stock.md)), or copy the last working
   kernel image. Without it, a bad boot has no quick way back.
4. **Battery above 50%, ideally full.**
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-M515F**.
6. The `m51-kernel-8` artifact from the run page, extracted to the
   boot image (`Image.gz-dtb` / `boot.img`), with its SHA-256
   checked against the build record above.

## Steps

1. Get the `m51-kernel-8` artifact from the run page and extract
   the boot image (`Image.gz-dtb` / `boot.img`). Check its SHA-256
   against the build record above.
2. Copy the new boot image **and** the old boot image (prereq 3)
   to the phone.
3. In TWRP: Install, **Install Image**, select the new boot image,
   flash to the **Boot** partition. (Or pack it into a `boot.tar`
   and flash it in Odin's AP slot.) Only the boot partition is
   written. Recovery is untouched.
4. Reboot.
5. Check `adb shell uname -a` shows `4.14.357-openela` and `adb
   shell cat /proc/version` matches.

## Verify

- `adb shell uname -a` shows `4.14.357-openela`.
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
  image. Check the artifact name (`m51-kernel-8`) and the SHA-256,
  then re-flash the right one.
- **Phone boots but Wi-Fi or sensors broke.** The kernel and the
  vendor blobs disagree. Roll back, and report which function
  broke with a `dmesg` capture.
- **`Image.gz-dtb` is 64 MB or larger.** Do not flash it. The boot
  partition is 64 MB. The build gate rejects this, so an image
  this size means the artifact is not from build #8.
