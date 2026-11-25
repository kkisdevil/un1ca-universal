# Root - Galaxy A73 5G (SM-A736B)

Root the SM-A736B. This file is for the SM-A736B only. Do not use
it on any other model.

## What root is

Root is administrator access to the phone's own system. You can
read and change anything, install modules, and run root apps. This
file documents the methods reported for this phone so anyone can
reproduce them. Root on this phone has been reported by users
(for example an XDA user rooted Android 14 / One UI 6.1 with the
AP-patch method below), but no root run has been done in front of
us in this project.

## What root costs

- Knox is already tripped by the unlock, so root adds no new
  permanent loss. Rooting also means losing Samsung Pay, Secure
  Folder, and some official Samsung apps.
- Banking apps and Play Integrity can fail on a rooted phone.
- System OTA updates will remove root, and on a rooted phone you
  must update firmware manually by repeating the patch steps with
  the new firmware.
- You must **never relock the bootloader** with root installed.
  That bricks the phone.
- To unroot: flash the stock boot or AP ([flash-stock.md](flash-stock.md)),
  or in Magisk go to Uninstall, Restore Images, then flash stock
  boot.

## Prereqs

1. **Unlocked bootloader** ([unlock-bootloader.md](unlock-bootloader.md)).
   For Methods B and C you also need TWRP
   ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything.** Rooting itself does not wipe data, but
   a wrong flash can. Back up EFS in TWRP first. One XDA user
   reports the phone pushed them into a hard reset after flashing
   a patched boot image, so a backup is not optional even for the
   boot-only method.
3. **Battery above 50%, ideally full.** Some a73xq guides say
   70% or more. A good USB data cable and a USB port on the PC
   itself for the Odin steps.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A736B** and the service
   provider software version must show your region code.
5. Know which stock build the phone runs (Settings, About phone,
   Software information, build number). Method A patches the AP
   tar of that exact build. Also check the bootloader version of
   the phone against the stock firmware you download, so the two
   match.

## Method A: Magisk, patch the AP (Samsung standard, no TWRP needed)

This is the standard Magisk method for Samsung phones, and the
one XDA answers recommend for this phone on Android 14.

1. Download the **Magisk APK** (latest release) from
   https://github.com/topjohnwu/Magisk/releases and install it on
   the phone.
2. Copy the stock **AP tar** (`AP_A736BXXSCGZK3_...tar.md5`, from
   the [flash-stock.md](flash-stock.md) firmware) to the phone's
   internal storage.
3. Open Magisk, **Install**, **Select and Patch a File**, pick the
   AP tar. Magisk patches it (takes minutes: the AP is huge) and
   writes `magisk_patched-*.tar` to the Download folder.
4. Copy the patched tar back to the PC.
5. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
6. Open Odin **as administrator** (Odin3 v3.14.1). Load the
   **patched tar in the AP slot**. If the phone is already on this
   exact stock build, AP-only is enough. Otherwise load BL, CP,
   and CSC from the same firmware package as well. Leave
   Re-Partition unticked. Click Start and wait for PASS.
7. Reboot. Open Magisk. It shows **Installed**.

## Method B: Magisk, patch the boot image (needs TWRP)

1. Extract `boot.img` from the stock AP tar. The AP tar is a plain
   tar, but on this phone the boot image inside is stored as
   `boot.img.lz4`, so decompress it first (an XDA answer names
   `lz4_win64` for this step): `tar -xf AP_...tar.md5 boot.img.lz4`,
   then decompress the lz4 file to `boot.img`.
2. Copy `boot.img` to the phone. In the Magisk app: Install,
   Select and Patch a File, pick `boot.img`. You get
   `magisk_patched-*.img` in Download.
3. Copy the patched image back to the phone. In TWRP: Install,
   **Install Image**, select the patched image, flash to the
   **Boot** partition. Reboot. (Alternatively, pack the patched
   `boot.img` into a `.tar` and flash it in Odin's AP slot.)
4. Verify as below. Note the XDA report that the phone may push
   you into a hard reset on the first reboot after flashing only
   the boot image; have your backup ready.

## Method C: Magisk zip in TWRP

1. Rename the Magisk APK to `Magisk-vXX.zip` and copy it to the
   phone (or an SD card).
2. In TWRP: Install, select the zip, flash it, reboot.
3. Verify as below. The Magisk app can also do a Direct Install
   once the phone is already booted with a patched boot.
4. This method is the standard TWRP route and is listed in the
   a73xq TWRP guides, but it has not been run end to end on this
   phone in this project. Method A is the one with a user report
   on this phone.

## Verify

- Open the Magisk app. It shows **Installed** with a version
  number.
- From a PC: `adb shell su -c id` prints `uid=0(root)`.
- If the app shows "Installed: N/A" or `su` is denied, the patch
  did not take. Re-do the method from step 1 and check you patched
  the AP or boot image of the build that is actually on the phone.

## Other root methods

- **APatch: not verified on this phone.** No a73xq APatch run
  was found in the sources read. Do not assume the m51 APatch
  notes transfer. If you try it, record the result; until then
  it is unproven here.
- **KernelSU: not recommended.** KernelSU needs a kernel built
  with KernelSU support. No KernelSU-enabled kernel for the a73xq
  was found in the sources read, and this project has no a73xq
  kernel build (see [flash-kernel.md](flash-kernel.md)). Do not
  chase KernelSU on this phone unless you build or obtain a
  KernelSU-enabled kernel for the a73xq first.
- **No optimizer module is recommended here.** This project has
  no a73xq fix pack yet (see [flash-un1ca.md](flash-un1ca.md)),
  so there is no fix for a module to fight. Do not install a
  nightly optimizer that re-tunes zram or swappiness on this
  phone without a recorded reason.

## After root

- Modules install from the Magisk app (or the APatch app).
- If a banking app fails, that is Play Integrity, not a broken
  root. UN1CA ships a Play Integrity Fix (see
  [flash-un1ca.md](flash-un1ca.md)). On stock, PIF and Shamiko
  style modules exist but are **not verified by us** on this
  phone, so they are named here, not recommended.
- Do not take system OTA updates on a rooted phone. They remove
  root and can fail mid-install.
- Do not write to the bootloader partitions (`aboot` / `xbl` /
  `sbl`) from root. That bricks the phone.

## Troubleshooting

- **Magisk shows "Installed: N/A".** You patched the wrong build.
  Check the build number on the phone and patch the AP or boot
  image from that exact build.
- **`su` is denied.** Root did not stick. Reboot into TWRP and
  check the Boot partition holds the patched image (Method B), or
  re-flash the patched AP tar (Method A).
- **Bootloop after flashing a patched image.** Reboot into TWRP
  and flash the stock `boot.img` from the AP tar to the Boot
  partition (Install Image, Boot). The phone is back to unrooted
  stock boot. Then re-do the method.
- **Phone goes to recovery / hard reset after flashing a patched
  boot image.** Reported by an XDA user on this phone after the
  boot-only method. Restore from your backup, then re-do the
  method; if it repeats, use Method A (full patched AP) instead.
- **Banking app fails after root.** Play Integrity. See "After
  root" above. This is expected, not a broken root.

## Sources

- XDA, root without TWRP on Android 14 / One UI 6.1 (AP-patch
  recommendation, boot.img.lz4 note, hard-reset report):
  https://forum.xda-developers.com/t/how-can-i-root-my-galaxy-a73-5g-android-14-one-ui-6-1-without-twrp.4690807/
- Magisk releases: https://github.com/topjohnwu/Magisk/releases
- AndroidBiits, root SM-A736B with Magisk (AP-patch steps, Odin
  3.14.1): https://androidbiits.com/root-samsung-galaxy-a73-sm-a736b-easily/
- Stock AP tar filename pattern from the CGZK3 firmware record
  in [flash-stock.md](flash-stock.md).

## TODO

- TODO: no root run has been done in front of us in this project
  on this phone; Methods A to C are documented from the sources
  above, not from a verified run here.
- TODO: Odin3 v3.14.1 SHA-256 was not verified from a trusted
  source in this session.
- TODO: APatch and KernelSU status on this phone are unproven;
  no a73xq run was found for either.
