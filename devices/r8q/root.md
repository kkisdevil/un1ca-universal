# Root - Galaxy S20 FE (Snapdragon) (SM-G780G)

Root the SM-G780G. This file is for the SM-G780G only. Do not use
it on any other model, including the Exynos S20 FE (SM-G780F).
US carrier models with locked bootloaders cannot be rooted this
way at all.

## What root is

Root is administrator access to the phone's own system. You can
read and change anything, install modules, and run root apps. This
file documents the standard Samsung methods so anyone can
reproduce them. None of them has been run end to end by us on an
r8q; they are the documented Samsung and Magisk practice for this
phone.

## What root costs

- Knox is already tripped by the unlock, so root adds no new
  permanent loss.
- Banking apps and Play Integrity can fail on a rooted phone.
  UN1CA ships a Play Integrity Fix; on stock, PIF and Shamiko
  style modules exist but are **not verified by us** on this
  phone, so they are named here, not recommended.
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
   information: model must read **SM-G780G**. The UN1CA donor
   region for this phone is **BTU**.
5. Know which stock build the phone runs (Settings, About phone,
   Software information, build number). Method A patches the AP
   tar of that exact build. The latest stock build for this phone
   is `G780GXXSHEYJ1` (see [flash-stock.md](flash-stock.md)).

## Method A: Magisk, patch the AP (Samsung standard, no TWRP needed)

This is the standard Magisk method for Samsung phones.

1. Download the **Magisk APK** (latest release) from
   https://github.com/topjohnwu/Magisk/releases and install it on
   the phone.
2. Copy the stock **AP tar** (`AP_G780GXXSHEYJ1_...tar.md5`, from
   the [flash-stock.md](flash-stock.md) firmware) to the phone's
   internal storage.
3. Open Magisk, **Install**, **Select and Patch a File**, pick the
   AP tar. Magisk patches it (takes minutes: the AP is huge) and
   writes `magisk_patched-*.tar` to the Download folder.
4. Copy the patched tar back to the PC.
5. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
6. Open Odin **as administrator** (Odin3 v3.14.1, the conservative
   choice; TODO: SHA-256 not verified for this guide). Load the
   **patched tar in the AP slot**. If the phone is already on this
   exact stock build, AP-only is enough. Otherwise load BL, CP,
   and CSC from the same firmware package as well. Leave
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

1. Rename the Magisk APK to `Magisk-vXX.zip` and copy it to the
   phone (or an SD card).
2. In TWRP: Install, select the zip, flash it, reboot.
3. Verify as below. The Magisk app can also do a Direct Install
   once the phone is already booted with a patched boot.

This method is the one reported working on UN1CA for r8q: rename
Magisk.apk to Magisk.zip, flash it in TWRP, reboot a few times
after the install.

## Verify

- Open the Magisk app. It shows **Installed** with a version
  number.
- From a PC: `adb shell su -c id` prints `uid=0(root)`.
- If the app shows "Installed: N/A" or `su` is denied, the patch
  did not take. Re-do the method from step 1 and check you patched
  the AP or boot image of the build that is actually on the phone.

## Other root methods

- **APatch: not verified on this phone.** APatch is KernelPatch
  based and follows the same shape as Method B (patch `boot.img`,
  flash it to Boot in TWRP). TODO: nobody we can cite has run it
  end to end on an r8q. Do not treat it as proven here.
- **KernelSU: not recommended.** KernelSU needs a kernel built
  with KernelSU support. TODO: no KernelSU-enabled kernel for the
  r8q has been verified. Do not chase KernelSU on this phone
  unless you build or obtain one first.
- **Any other root tool:** TODO. None is recommended for this
  phone until it is verified here.

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
- **"Only official released binaries are allowed to be flashed
  (vbmeta)".** KG STATUS is PRENORMAL, or no disabled vbmeta was
  flashed. Boot the phone, complete setup, and retry with the
  patched vbmeta tar (see [flash-twrp.md](flash-twrp.md)).
- **Banking app fails after root.** Play Integrity. See "After
  root" above. This is expected, not a broken root.

## Sources

- Magisk releases: https://github.com/topjohnwu/Magisk/releases
- Magisk AP patch method for the S20 FE (firmware via SamFirm or
  Frija, patch AP, flash in Odin):
  https://www.ytechb.com/how-to-root-samsung-galaxy-s20-fe-and-unlock-bootloader/
- Root on UN1CA for r8q via Magisk zip in TWRP (UN1CA 2.5.6 XDA
  thread, page 23):
  https://xdaforums.com/t/rom-14-g780g-g781b-g781n-g7810-un1ca-2-5-1-one-ui-6-1-1-for-galaxy-s20-fe-qualcomm-19-10-2024.4657878/page-23
- US Snapdragon variants have locked bootloaders:
  https://www.androidinfotech.com/43848-root-samsung-galaxy-s20-fe-android-13-sm-g780f-g-magisk/
- Latest stock build G780GXXSHEYJ1: [flash-stock.md](flash-stock.md)
