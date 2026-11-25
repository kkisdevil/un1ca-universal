# Root - Galaxy S21 Ultra 5G (SM-G998B)

Root the SM-G998B. This file is for the SM-G998B only. Do not use
it on any other model.

## What root is

Root is administrator access to the phone's own system. You can
read and change anything, install modules, and run root apps.

## What root costs

- Knox is already tripped by the unlock, so root adds no new
  permanent loss. Samsung Pay, Samsung Pass and Secure Folder are
  already gone from the unlock.
- Banking apps and Play Integrity can fail on a rooted phone.
  Widevine may drop to L3 on some firmware combinations after
  root, so HD playback in apps that require L1 can stop working.
- System OTA updates will remove root, and on this device OTA
  stops working once custom binaries are flashed. Do not take
  them. Update manually by flashing firmware (see
  [flash-stock.md](flash-stock.md)).
- You must **never relock the bootloader** with root installed.
  That bricks the phone.
- To unroot: flash the stock boot or AP ([flash-stock.md](flash-stock.md)),
  or in Magisk go to Uninstall, Restore Images, then flash stock
  boot.

## Prereqs

1. **Unlocked bootloader** ([unlock-bootloader.md](unlock-bootloader.md)),
   including the VaultKeeper step. For Methods B and C you also
   need TWRP ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything.** Rooting itself does not wipe data, but
   a wrong flash can. Back up EFS in TWRP first.
3. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself for the Odin steps.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G998B** and the service
   provider software version must show your region code.
5. Know which stock build the phone runs (Settings, About phone,
   Software information, build number). Method A patches the AP
   tar of that exact build. The current latest for AUT is
   `G998BXXSJHZC2`, build number
   `AP3A.240905.015.A2.G998BXXSJHZC2` (see
   [flash-stock.md](flash-stock.md)).

## Method A: Magisk, patch the AP (Samsung standard, no TWRP needed)

This is the standard Magisk method for Samsung phones, and the
method the S21 series XDA root thread uses.

1. Download the **Magisk APK** (latest release) from
   https://github.com/topjohnwu/Magisk/releases and install it on
   the phone.
2. Copy the stock **AP tar** (for example
   `AP_G998BXXSJHZC2_...tar.md5`, from the
   [flash-stock.md](flash-stock.md) firmware) to the phone's
   internal storage.
3. Open Magisk, **Install**, **Select and Patch a File**, pick the
   AP tar. Magisk patches it (takes minutes: the AP is huge) and
   writes `magisk_patched-*.tar` to the Download folder.
4. Copy the patched tar back to the PC.
5. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
6. Open Odin **as administrator** (Odin3 v3.14.1, SHA-256
   `638296a11b1bfa954991b0597214d833511b973480ae9e15e299a761fea1f794`).
   Load the **patched tar in the AP slot**, together with BL, CP,
   and CSC (**not** HOME_CSC, because a data wipe is wanted here)
   from the original firmware. Leave Re-Partition unticked. Click
   Start and wait for PASS. This AP plus BL, CP and CSC
   combination is the S21 series Magisk thread's own instruction.
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
   phone (or an SD card). The p3s TWRP thread itself says step 7
   is "Flash magisk apk in twrp", so this method applies on this
   device.
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

- **APatch: not verified on this device.** No p3s-specific APatch
  end-to-end report was found in research on 2026-11-25. Do not
  treat the m51 APatch note as applying here. TODO: find or run
  a p3s APatch report before recommending it.
- **KernelSU: not recommended.** KernelSU needs a kernel built
  with KernelSU support. No KernelSU-enabled kernel for the
  SM-G998B was verified in research on 2026-11-25. Do not chase
  KernelSU on this phone unless you build or obtain a
  KernelSU-enabled kernel for p3s first.
- **Any other root tool:** none verified for p3s. Do not use a
  one-click root tool on this device without a p3s-specific
  source.
- **TODO: optimizer or module warning for this device.** The m51
  guide warns against AAO because it fights the m51 lag fix pack.
  No p3s fix pack exists yet (see [flash-un1ca.md](flash-un1ca.md)),
  so no equivalent warning can be written yet. TODO: add one if a
  p3s fix pack is ever defined.

## After root

- Modules install from the Magisk app (or the APatch app, if that
  method is ever verified here).
- If a banking app fails, that is Play Integrity, not a broken
  root. UN1CA ships KnoxPatch and a Play Integrity Fix (see
  [flash-un1ca.md](flash-un1ca.md)). On stock, PIF and Shamiko
  style modules exist but are **not verified by us** on this
  phone, so they are named here, not recommended.
- Do not take system OTA updates on a rooted phone. They remove
  root and can fail mid-install.
- Do not write to the bootloader partitions (`aboot` / `xbl` /
  `sbl`) from root. That bricks the phone.
- TODO: confirm the touchscreen behaviour after root on
  G998BXXSJHZA6 and G998BXXSJHZC2. An XDA thread reports the
  touchscreen stopping after the HZA6 update, fixed by flashing a
  single vendor_boot file with the bootloader already unlocked.
  That is a firmware bug report, not a root step, and the fix file
  is build-specific. See Sources.

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
- **Touchscreen dead after the HZA6 update.** See the XDA
  touchscreen thread in Sources. Do not flash its vendor_boot
  file unless your phone is on exactly G998BXXSJHZA6.

## TODO

- TODO: APatch end-to-end report for p3s, or a plain statement
  that it was tested and failed.
- TODO: KernelSU-enabled kernel for p3s, if one ever exists.
- TODO: Magisk version actually tested on G998BXXSJHZC2. No
  p3s-specific Magisk version test was found in research.

## Sources

- S21 series Magisk root thread (Method A shape, AP plus BL, CP
  and CSC, not HOME_CSC, VaultKeeper step): XDA, "[Magisk][US/CAN
  BL Unlock] Root for Galaxy S21 Series (B/N/0/U/U1/W)",
  https://xdaforums.com/t/magisk-us-can-bl-unlock-root-for-galaxy-s21-series-b-n-0-u-u1-w.4233567/page-2
- Magisk releases: https://github.com/topjohnwu/Magisk/releases
- TWRP thread step 7 (flash Magisk APK in TWRP): XDA,
  "[CLOSED][RECOVERY][UNOFFICIAL] TWRP for Galaxy S21 Ultra
  (Exynos)",
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-s21-ultra-exynos.4240993
- Touchscreen issue on HZA6: XDA, "Galaxy S21 Ultra (SM-G998B):
  touchscreen fix for G998BXXSJHZA6 without root",
  https://xdaforums.com/t/galaxy-s21-ultra-sm-g998b-touchscreen-fix-for-g998bxxsjhza6-without-root-unlocked-bootloader-required.4809366/
- Odin3 v3.14.1 SHA-256 and the m51 Method A/B/C shape: shared
  practice, verified in `../m51/root.md`.
- Firmware build number for the current AUT build: SamFrew,
  https://samfrew.com/download/Galaxy__S21__Ultra__5G__/tbqu/AUT/G998BXXSJHZC2/G998BOXMJHZC2

## Next step

Flash UN1CA: [flash-un1ca.md](flash-un1ca.md). Or flash the stock
ROM back: [flash-stock.md](flash-stock.md).
