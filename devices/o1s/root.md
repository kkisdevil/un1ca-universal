# Root - Galaxy S21 5G (SM-G991B)

Root the SM-G991B. This file is for the SM-G991B only. Do not use
it on any other model.

## What root is

Root is administrator access to the phone's own system. You can
read and change anything, install modules, and run root apps.
This file documents the exact methods so anyone can reproduce it.

## What root costs

- Knox is already tripped by the unlock, so root adds no new
  permanent loss.
- Banking apps and Play Integrity can fail on a rooted phone.
- System OTA updates will remove root. Do not take them.
- You must **never relock the bootloader** with root installed.
  That bricks the phone.
- To unroot: flash the stock boot or AP ([flash-stock.md](flash-stock.md)),
  or in Magisk go to Uninstall, Restore Images, then flash stock
  boot.

## Prereqs

1. **Unlocked bootloader** ([unlock-bootloader.md](unlock-bootloader.md)).
   For Methods B and C you also need TWRP
   ([flash-twrp.md](flash-twrp.md)). Note the warning there:
   afaneh92's TWRP is refused by the UN1CA installer, so pick
   your recovery with your end goal in mind.
2. **Back up everything.** Rooting itself does not wipe data, but
   a wrong flash can. Back up EFS in TWRP first.
3. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself for the Odin steps.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G991B** and the service
   provider software version must show **AUT**.
5. Know which stock build the phone runs (Settings, About phone,
   Software information, build number). Method A patches the AP
   tar of that exact build.

## Method A: Magisk, patch the AP (Samsung standard, no TWRP needed)

This is the standard Magisk method for Samsung phones.

1. Download the **Magisk APK** (latest release) from
   https://github.com/topjohnwu/Magisk/releases and install it on
   the phone.
2. Copy the stock **AP tar** (for example
   `AP_G991BXXSJHZA6_...tar.md5`, from the
   [flash-stock.md](flash-stock.md) firmware) to the phone's
   internal storage. TODO: confirm the exact AP child filename
   for the AUT HZA6 package.
3. Open Magisk, **Install**, **Select and Patch a File**, pick the
   AP tar. Magisk patches it (takes minutes: the AP is huge) and
   writes `magisk_patched-*.tar` to the Download folder.
4. Copy the patched tar back to the PC.
5. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
6. Open Odin **as administrator** (Odin3 v3.14.1, SHA-256
   `638296a11b1bfa954991b0597214d833511b973480ae9e15e299a761fea1f794`).
   Load the **patched tar in the AP slot**. If the phone is already
   on this exact stock build, AP-only is enough. Otherwise load BL,
   CP, and CSC from the same firmware package as well. Leave
   Re-Partition unticked. Click Start and wait for PASS.
7. Reboot. Open Magisk. It shows **Installed**.

## Method B: Magisk, patch the boot image (needs TWRP)

1. Extract `boot.img` from the stock AP tar. The AP tar is a plain
   tar: `tar -xf AP_...tar.md5 boot.img`.
2. Copy `boot.img` to the phone. In the Magisk app: Install,
   Select and Patch a File, pick `boot.img`. You get
   `magisk_patched-*.img` in Download.
3. Copy the patched image back to the phone. In TWRP: Install,
   **Install Image**, select the patched image, flash to the
   **Boot** partition. Reboot.
4. Verify as below.

## Method C: Magisk zip in TWRP

This is the method the XDA TWRP opening post prescribes for this
device: after installing TWRP and formatting data, flash the
Magisk APK in TWRP, then reboot to system.

1. Copy the Magisk APK to the phone (internal storage or USB OTG;
   the S21 has no SD card slot).
2. In TWRP: Install, select the Magisk APK, flash it, reboot.
   (Older guides rename the APK to `Magisk-vXX.zip` first; the
   XDA thread reports this TWRP flashes the APK directly.)
3. Verify as below. The Magisk app can also do a Direct Install
   once the phone is already booted with a patched boot.

## Verify

- Open the Magisk app. It shows **Installed** with a version
  number.
- From a PC: `adb shell su -c id` prints `uid=0(root)`.
- If the app shows "Installed: N/A" or `su` is denied, the patch
  did not take. Re-do the method from step 1 and check you patched
  the AP or boot image of the build that is actually on the phone.

## Other root methods

- **APatch:** TODO. No verified end-to-end APatch run on this
  device was found. Do not present it as working on o1s until
  one is recorded.
- **KernelSU:** TODO. KernelSU needs a kernel built with
  KernelSU support. No KernelSU-enabled kernel for o1s is
  verified in this folder. Do not chase KernelSU on this phone
  unless you build or obtain one first.
- **Any other root tool:** TODO. None is recommended for this
  device yet.
- **Modules that fight this project's fixes:** none known yet,
  because this device has no fix pack in this repo. TODO: revisit
  once an o1s fix pack exists.

## After root

- Modules install from the Magisk app (or the APatch app).
- If a banking app fails, that is Play Integrity, not a broken
  root. UN1CA ships a Play Integrity Fix (see
  [flash-un1ca.md](flash-un1ca.md)). On stock, PIF and Shamiko
  style modules exist but are **not verified by us** on this phone,
  so they are named here, not recommended.
- Do not take system OTA updates on a rooted phone. They remove
  root and can fail mid-install.
- Do not write to the bootloader partitions from root. That bricks
  the phone.

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
- **Banking app fails after root.** Play Integrity. See "After
  root" above. This is expected, not a broken root.

## Sources

- Method C (flash the Magisk APK in TWRP) and the AP-slot /
  USERDATA-slot flash: XDA TWRP thread,
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-s21-exynos.4241869/
- Methods A and B (Samsung standard Magisk AP and boot-image
  patching, Odin slots, Re-Partition warning): m51 docs
  (`../m51/root.md`), which document the Samsung-standard flow;
  device-specific values (AP filename pattern, build) come from
  this folder's [flash-stock.md](flash-stock.md).
- Magisk releases: https://github.com/topjohnwu/Magisk/releases
- No SD card slot on the S21: XDA BeyondROM thread,
  https://xdaforums.com/t/rom-beyondrom-v7-5-25-10-2024-gxh7-exynos-sm-g99xb.4254933/page-20
