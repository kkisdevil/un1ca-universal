# Root - Galaxy S22+ (Snapdragon) (SM-S906E)

Root the Snapdragon Galaxy S22+ (g0q). This file is for
**SM-S906E, SM-S906N, SM-S9060** only. Do not use it on any other
model. SM-S906B is the Exynos model (g0s) and nothing here applies
to it.

## What root is

Root is administrator access to the phone's own system. You can
read and change anything, install modules, and run root apps.

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
   ([flash-twrp.md](flash-twrp.md)). TWRP has no verified download
   for g0q today, so Methods B and C are blocked until one is
   found. Method A needs no TWRP.
2. **Back up everything.** Rooting itself does not wipe data, but
   a wrong flash can. Back up EFS in TWRP first if TWRP is
   installed.
3. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself for the Odin steps.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-S906E** (or SM-S906N, or
   SM-S9060).
5. Know which stock build the phone runs (Settings, About phone,
   Software information, build number). Method A patches the AP
   tar of that exact build.

## Method A: Magisk, patch the AP (Samsung standard, no TWRP needed)

This is the standard Magisk method for Samsung phones, and the one
the S22+ root guide uses.

1. Download the **Magisk APK** (latest release) from
   https://github.com/topjohnwu/Magisk/releases and install it on
   the phone.
2. Copy the stock **AP tar** (for the current build, the name
   pattern is `AP_S906EXXSEGZH4_..._meta_OS16.tar.md5`, from the
   [flash-stock.md](flash-stock.md) firmware) to the phone's
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

Blocked until a working TWRP exists for g0q (see
[flash-twrp.md](flash-twrp.md)). The steps, once TWRP is
available:

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

Blocked until a working TWRP exists for g0q. Do not attempt it
without TWRP. The steps, once TWRP is available:

1. Rename the Magisk APK to `Magisk-vXX.zip` and copy it to the
   phone (or an SD card).
2. In TWRP: Install, select the zip, flash it, reboot.
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

- **APatch:** TODO. No report was found of APatch run end to end
  on g0q. Do not present it as working on this device until one
  is found.
- **KernelSU:** TODO. KernelSU needs a kernel built with
  KernelSU support. No KernelSU-enabled kernel for g0q was found
  in the sources read. Do not chase KernelSU on this phone unless
  you build or obtain one first.
- **Any optimizer or module that fights this project's fixes:**
  TODO. There is no g0q fix pack yet, so there is no known
  conflicting module for this device. Do not copy another
  device's module warning here.

## After root

- Modules install from the Magisk app (or the APatch app).
- If a banking app fails, that is Play Integrity, not a broken
  root. No Play Integrity fix has been verified by us on this
  phone, so none is recommended here.
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
  stock boot. Then re-do the method. If TWRP is not installed,
  flash the full stock firmware instead:
  [flash-stock.md](flash-stock.md).
- **Banking app fails after root.** Play Integrity. See "After
  root" above. This is expected, not a broken root.

## Sources

- Method A steps (Magisk patch the AP tar, Odin3 v3.14.1, AP slot,
  firmware via Frija): AndroidBiits, "How to Root Samsung Galaxy
  S22 Plus (SM-S906B, SM-S906E, SM-S906N)",
  https://androidbiits.com/root-samsung-galaxy-s22-plus-sm-s906b-sm-s906e-sm-s906n-easily/
  and GetDroidTips, "How To Root Samsung S22 / S22 Plus 5G Using
  Magisk [No TWRP needed]",
  https://www.getdroidtips.com/root-samsung-s22-s22-plus-5g/
- Magisk releases: https://github.com/topjohnwu/Magisk/releases
- AP tar filename pattern for the current build
  (`AP_S906EXXSEGZH4_..._meta_OS16.tar.md5`): firmware record for
  S906EXXSEGZH4, https://www.klikcloud.ru/en/file/88517-firmware-info
- TWRP blocked status: [flash-twrp.md](flash-twrp.md).

## TODO

- Confirm Method A end to end on a g0q phone running the current
  Android 16 build. The S22+ guides quoted above are from the
  Android 12/13 era; the steps are the standard Samsung shape,
  but no run on the current build was found.
- Odin3 v3.14.1 SHA-256: verify from a trusted source.
- APatch on g0q: find a real end-to-end report or mark it as not
  working.
- KernelSU on g0q: find a KernelSU-enabled kernel or mark it as
  not available.
- Play Integrity fix for g0q: none verified yet.
