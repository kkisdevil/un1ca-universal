# Root - Galaxy A71 (SM-A715F)

Root the SM-A715F with Magisk. This file is for the SM-A715F
only. Do not use it on any other model. Do not use it on the
Galaxy A71 5G (SM-A716, codename a71xq): that is a different
phone.

**Rooting works by editing the stock boot image, not by editing
the running system.** Magisk changes only `boot.img` (or the
AP tar). Everything that reads the system stays stock, which is
why the phone still boots like stock afterwards.

## Prereqs

1. **Unlocked bootloader.** Do
   [unlock-bootloader.md](unlock-bootloader.md) first.
2. **TWRP installed.** Do
   [flash-twrp.md](flash-twrp.md) first. Root on this device is
   done from TWRP.
3. **Back up everything** (and back up EFS in TWRP) before you
   patch anything. You are about to rewrite the boot image.
4. **Battery above 50%, ideally full.** A good USB data cable
   and a USB port on the PC itself.
5. **A stock firmware matching your device.** AP patching must use
   the AP from the firmware the phone is running (or the one you
   are about to flash). See [flash-stock.md](flash-stock.md)
   for the latest stock build. The AP tar filename pattern is
   `AP_A715FXXSBDXB1_A715FXXSBDXB1_MQB77793475_REV00_user_low_ship_MULTI_CERT_meta_OS13.tar.md5.zip`
   (XSG build of A715FXXSBDXB1, 5.45 GB for the AP child file
   alone; Samfw).
6. **Magisk.** From https://github.com/topjohnwu/Magisk/releases
   (the Magisk APK).

## Method A: patch the AP tar (standard Samsung method)

This is the method the androidweblog.com and droidwin.com A71
guides document, and the Samsung-standard one.

1. Copy the **AP tar** from the stock firmware onto the phone.
2. Install the Magisk APK.
3. In Magisk, tap **Install**, then **Select and Patch a File**,
   and choose the AP tar. Magisk patches it and writes a
   `magisk_patched-...tar` file to Downloads.
4. Copy the patched tar to the PC.
5. Boot into Download mode (power off, hold Volume Up + Volume
   Down, connect USB, press Volume Up).
6. In Odin, load the patched tar in the **AP slot**. **Also load
   the BL, CP and CSC files from the same stock firmware** (the
   unpatched ones). Wait for PASS.
7. **Do not let the phone boot to system first.** If TWRP is
   installed, boot straight into recovery (hold Volume Up +
   Power) and then reboot to System from TWRP.
8. Open Magisk. It should show Magisk as installed.

## Method B: patch boot.img from TWRP

This is the shorter route once TWRP is already installed.

1. In TWRP, pull the stock `boot.img` out of the AP tar (or use
   the one from a previous stock flash).
2. Copy `boot.img` onto the phone.
3. In Magisk, tap **Install**, **Select and Patch a File**, choose
   `boot.img`. Magisk writes a `magisk_patched-....img` to
   Downloads.
4. In TWRP, Install, Install Image, choose the patched image,
   flash it to the **Boot** partition.
5. Reboot to System. Open Magisk. It should show Magisk as
   installed.

## Method C: flash Magisk zip in TWRP

1. Copy the Magisk APK (renamed to `.zip`) onto the phone.
2. In TWRP, Install, choose the zip, swipe to flash.
3. Reboot to System. Open Magisk.

## Verify

- Open Magisk. It should show Magisk as installed.
- In a terminal or Termux:

```text
adb shell su -c id
```

It should print `uid=0(root) gid=0(root)`.

## Troubleshooting

- **Magisk says "not installed".** The patched boot image did
  not stick. The phone probably booted to system before you
  flashed the patched image, or you patched the wrong AP. Start
  from Method A step 1 with the AP from the firmware the phone
  is actually running.
- **The phone bootloops after root.** Boot into recovery and
  restore the stock `boot.img` (flash the stock AP in Odin, or
  restore the boot partition from your TWRP backup).
- **The patched AP does not flash.** Use the AP tar from the
  firmware the phone is running, not a random newer or older
  one. Check the trailing MD5 (the `.md5` suffix is only a
  checksum footer; if you edited the tar, recompute it).
- **The AP tar is not the one you patched.** If Magisk patched a
  file in Downloads, make sure you copied the *patched* file to
  the PC, not the original.

## After root

- MagiskHide and Zygisk are Magisk's own settings. Use them if an
  app refuses to run on a rooted phone.
- **APatch and KernelSU are listed by some A71 guides as
  alternatives. TODO: neither has been verified by us on this
  device.** The m51 record lists APatch as the recommended
  alternative there; that does not transfer to a71. Do not
  present APatch or KernelSU as working on a71 until someone
  tests them on one.
- AAO (Automatic Android Optimizer, a Magisk module) re-tunes
  zram and swappiness. There is **no a71 fix pack** in this repo,
  so there is no tuned memory setting for it to fight, but do
  not install AAO unasked: it changes memory behaviour that
  nothing on this device has been tuned for.

## Next step

Flash something: [flash-stock.md](flash-stock.md),
[flash-gsi.md](flash-gsi.md), [flash-un1ca.md](flash-un1ca.md),
[flash-kernel.md](flash-kernel.md).

## Sources

- Method A (AP patch), Method B (boot.img patch), Method C
  (Magisk zip in TWRP): androidweblog.com "Root Samsung Galaxy
  A71 SM-A715 and Install TWRP Recovery 3.5.1" and droidwin.com
  "Install TWRP and Root Samsung Galaxy A71" (both name afaneh92
  TWRP 3.7.0_11-1 and Magisk from
  https://github.com/topjohnwu/Magisk/releases).
- AP tar filename pattern for A715FXXSBDXB1 (XSG):
  samfw.com, https://samfw.com/firmware/SM-A715F/XSG/A715FXXSBDXB1
  (child file `AP_A715FXXSBDXB1_A715FXXSBDXB1_MQB77793475_REV00_user_low_ship_MULTI_CERT_meta_OS13.tar.md5.zip`,
  5.45 GB).
- APatch/KernelSU as alternatives on a71: myghi63's flashing
  guide (for m51) recommends APatch and lists KernelSU; no a71
  source found. TODO.
- AAO fights the m51 fix pack (research/08-mehedi-core.md). No
  a71 fix pack exists, so the conflict does not apply here.
