# Flash the custom kernel - Galaxy S22+ (Snapdragon) (SM-S906E)

Flash a custom kernel on the Snapdragon Galaxy S22+ (g0q). This
file is for **SM-S906E, SM-S906N, SM-S9060** only. Do not use it
on any other model. SM-S906B is the Exynos model (g0s) and nothing
here applies to it.

## WARNING: no kernel build exists for this device

**No custom kernel has been built for g0q in this project, and no
kernel has ever booted on a g0q phone from us.** There is no build
number, no run id, no artifact, and no SHA-256 to record. Do not
flash anything from this file until a build exists and its boot
test is recorded. The stock kernel facts below are the starting
point for building one, not a flashable kernel.

(The blank template for this file said to delete it if no kernel
build exists. It is kept as this stub instead, so the starting
facts and the open work are on record. Delete it if the project
decides g0q will never get a custom kernel.)

## What the kernel is (stock, the starting point)

- Stock kernel on the current firmware:
  `5.10.236-android12-9-31998796-abS906EXXSDGZB6` (from the
  SamFrew record for build GZB6). Board `taro`, platform `sm8450`
  (Snapdragon 8 Gen 1).
- Kernel source: Samsung publishes the S22 family kernel source
  at the Samsung Open Source Release Center
  (opensource.samsung.com, search by model SM-S906E). The launch
  source was Android 12 based; the current 5.10.236 source for
  the Android 16 builds is a TODO to locate and record.
- Defconfig name: TODO (not verified; do not assume a name until
  it is read from the source tree).
- EROFS support, SELinux mode: TODO (not verified for g0q).
- Boot partition size: TODO (not verified; do not flash an image
  without knowing it fits).

## How it was built

TODO. No build exists. When one is built, record here: toolchain
(name, commit, version), defconfig handling, patches applied, and
the build gates and which passed.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
   **Blocked today**: no working TWRP exists for g0q.
2. **Back up everything** and back up EFS in TWRP first.
3. **Keep the old boot image on the phone before you flash the new
   one.** Extract `boot.img` from the stock AP tar (see
   [flash-stock.md](flash-stock.md)), or copy the last working
   kernel image. Without it, a bad boot has no quick way back.
4. **Battery above 50%, ideally full.**
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-S906E** (or SM-S906N, or
   SM-S9060).
6. The kernel artifact from the run page, extracted to the boot
   image, with its SHA-256 checked against the build record.
   TODO: no artifact exists yet.

## Steps

Blocked until a kernel build and a working TWRP exist. The steps,
once both are available:

1. Get the kernel artifact from the run page and extract the boot
   image (`Image.gz-dtb` / `boot.img`). Check its SHA-256 against
   the build record.
2. Copy the new boot image **and** the old boot image (prereq 3)
   to the phone.
3. In TWRP: Install, **Install Image**, select the new boot image,
   flash to the **Boot** partition. (Or pack it into a `boot.tar`
   and flash it in Odin's AP slot.) Only the boot partition is
   written. Recovery is untouched.
4. Reboot.
5. Check `adb shell uname -a` shows the new kernel version and
   `adb shell cat /proc/version` matches.

Note from the g0q TWRP thread: a custom permissive kernel is
needed to boot with R/W vendor on this device. Any kernel built
for g0q should be checked against that expectation.

## Verify

- `adb shell uname -a` shows the new kernel version.
- `adb shell cat /proc/version` matches the build record.
- The phone boots to the home screen and stays up. Wi-Fi, calls,
  and sensors work as before the flash.
- If this is the first boot of this kernel on this phone, record
  the result (booted or not, plus `dmesg` and `logcat`) and report
  it. That record is the boot test.

## Rollback

If it does not boot, or anything regresses:

1. Reboot into TWRP (power off, hold Volume Up + Power with USB
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
  The boot partition size for g0q is still TODO; check it before
  any flash.

## Sources

- Stock kernel string `5.10.236-android12-9-31998796-abS906EXXSDGZB6`
  and board `taro`: SamFrew TUR record for S906EXXSDGZB6,
  https://samfrew.com/download/Galaxy__S22+__/47wa/TUR/S906EXXSDGZB6/S906EOXMDGZB6
- Samsung kernel source at the Open Source Release Center:
  GizChina, "Samsung Galaxy S22 / S22+/S22 Ultra series kernel
  source code released",
  https://www.gizchina.com/samsung/samsung-galaxy-s22-s22-s22-ultra-series-kernel-source-code-released
  and Android Police, "Samsung releases Galaxy S22 kernel
  source",
  https://www.androidpolice.com/samsung-releases-galaxy-s22-kernel-source/
  (both describe the Exynos launch source; the Snapdragon source
  location for the current builds is still TODO).
- "You need a custom permissive kernel to boot with R/W vendor":
  XDA TWRP thread,
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-s22-snapdragon.4453813/
- TWRP blocked status: [flash-twrp.md](flash-twrp.md).

## TODO

- Locate the current (Android 16 era) kernel source for SM-S906E
  and record its defconfig name.
- Build the first g0q kernel and record the toolchain, gates,
  artifact, and SHA-256.
- Verify the boot partition size for g0q.
- Record the first boot test on a g0q phone.
- Decide whether this file stays (as a real guide) or is deleted
  if g0q never gets a custom kernel.
