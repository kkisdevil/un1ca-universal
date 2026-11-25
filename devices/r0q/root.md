# Root - Galaxy S22 (SM-S901E)

Root the SM-S901E. This file is for the Galaxy S22 (Snapdragon),
codename `r0q`, models SM-S901E, SM-S901N, and SM-S9010 only. Do
not use it on the Exynos Galaxy S22 (SM-S901B, codename `r0s`) or
on the US models SM-S901U, SM-S901U1, and SM-S901W, whose
bootloader cannot be unlocked.

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
   ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything.** Rooting itself does not wipe data, but
   a wrong flash can. Back up EFS in TWRP first.
3. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself for the Odin steps.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-S901E** (or SM-S901N or
   SM-S9010).
5. Know which stock build the phone runs (Settings, About phone,
   Software information, build number). Method A patches the AP
   tar of that exact build.

## Method A: Magisk, patch the AP (Samsung standard, no TWRP needed)

This is the standard Magisk method for Samsung phones, and it is
the method the S22 root guides use.

1. Download the **Magisk APK** (latest release) from
   https://github.com/topjohnwu/Magisk/releases and install it on
   the phone.
2. Copy the stock **AP tar** (`AP_S901EXX...tar.md5`, from the
   [flash-stock.md](flash-stock.md) firmware) to the phone's
   internal storage.
3. Open Magisk, **Install**, **Select and Patch a File**, pick the
   AP tar. Magisk patches it (takes minutes: the AP is huge) and
   writes `magisk_patched-*.tar` to the Download folder.
4. Copy the patched tar back to the PC.
5. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
6. Open Odin **as administrator** (Odin3 v3.14.1, SHA-256
   `638296a11b1bfa954991b0597214d833511b973480ae9e15e299a761fea1f794`,
   see [flash-twrp.md](flash-twrp.md) for the source).
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

Note: the older XDA TWRP thread for this device says a custom
permissive kernel is needed to boot with read/write vendor. If a
patched boot image bootloops, that note is the first suspect. See
[flash-kernel.md](flash-kernel.md).

## Method C: Magisk zip in TWRP

1. Rename the Magisk APK to `Magisk-vXX.zip` and copy it to the
   phone (or an SD card).
2. In TWRP: Install, select the zip, flash it, reboot.
3. Verify as below. The Magisk app can also do a Direct Install
   once the phone is already booted with a patched boot.

TODO: Method C has not been confirmed end to end on r0q by us.
The XDA TWRP thread does say to flash Magisk in TWRP after the
custom kernel (step 7 of that thread), which supports this method
in principle, but no r0q run has been recorded in this project.

## Verify

- Open the Magisk app. It shows **Installed** with a version
  number.
- From a PC: `adb shell su -c id` prints `uid=0(root)`.
- If the app shows "Installed: N/A" or `su` is denied, the patch
  did not take. Re-do the method from step 1 and check you patched
  the AP or boot image of the build that is actually on the phone.

## Other root methods

- **KernelSU: unverified by us.** An XDA development thread
  titled "Samsung Galaxy S22-S901E [ KernelSU ]" exists in the
  Galaxy S22 forum, but we have not read its method or run it.
  KernelSU needs a kernel built with KernelSU support. Do not
  chase KernelSU on this phone unless you obtain a KernelSU
  enabled kernel for r0q first (see
  [flash-kernel.md](flash-kernel.md)).
- **APatch: no r0q evidence found.** No APatch run on r0q has
  been found in our sources. Do not assume it works here.
  TODO: check whether APatch supports the r0q stock kernel
  (5.10, taro) before recommending it.
- **FastbootD recovery root route:** a March 2026 XDA how-to,
  "[RECOVERY] [SM-S901E] FastbootD for GSI ROMS and Root" by
  AlexisGSM, covers Magisk setup through a FastbootD recovery for
  the SM-S901E. We have not read the full thread. See
  [flash-gsi.md](flash-gsi.md).

## After root

- Modules install from the Magisk app.
- If a banking app fails, that is Play Integrity, not a broken
  root. UN1CA ships a Play Integrity Fix (see
  [flash-un1ca.md](flash-un1ca.md)). On stock, PIF and Shamiko
  style modules exist but are **not verified by us** on this phone,
  so they are named here, not recommended.
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
  stock boot. Then re-do the method. If it still bootloops, the
  XDA note about needing a custom permissive kernel for read/write
  vendor may apply.
- **Banking app fails after root.** Play Integrity. See "After
  root" above. This is expected, not a broken root.

## Sources

- Magisk patch-AP method for the S22 (SM-S901B/E/N), Odin
  3.14.1, Download mode key combination:
  https://androidbiits.com/root-samsung-galaxy-s22-sm-s901b-sm-s901e-sm-s901n-easily/
  and https://www.androidinfotech.com/root-samsung-galaxy-s22-android-14/
- Magisk releases: https://github.com/topjohnwu/Magisk/releases
- Custom permissive kernel note: XDA TWRP thread,
  https://xdaforums.com/t/closed-recovery-unofficial-twrp-for-galaxy-s22-snapdragon.4453811/
- KernelSU thread existence and FastbootD root thread existence:
  XDA Galaxy S22 forum index, https://xdaforums.com/f/12511/
  (thread titles only; contents not read)
- TODO: no root method has been run end to end on an r0q phone
  by us. Methods A and B are standard Samsung Magisk practice;
  Method C and the alternative root methods are unconfirmed here.
