# Root - Galaxy S21 FE 5G (SM-G990E)

Root the SM-G990E. This file is for the SM-G990E only (Exynos S21
FE 5G, codename r9s). Do not use it on the Snapdragon FE
(SM-G990B, SM-G990B2, SM-G990U) or any other model.

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
- TODO: root on One UI 8 (Android 16) is unconfirmed for this
  device. An XDA question thread ("S21 fe G990E exynos one ui 8,
  ROOT") shows users asking, with no verified answer found in this
  pass. If the phone is already on One UI 8 it cannot even be
  unlocked (see [unlock-bootloader.md](unlock-bootloader.md)), so
  root on One UI 8 is only a question for phones unlocked before
  the update. Method A below is the route to try; its result on
  One UI 8 is TODO.

## Prereqs

1. **Unlocked bootloader** ([unlock-bootloader.md](unlock-bootloader.md)).
   For Methods B and C you also need a custom recovery
   ([flash-twrp.md](flash-twrp.md)). Note: for UN1CA use
   OrangeFox, not afaneh92's TWRP (the UN1CA installer rejects
   it).
2. **Back up everything.** Rooting itself does not wipe data, but
   a wrong flash can. Back up EFS in the recovery first.
3. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself for the Odin steps.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G990E** and the service
   provider software version must show your region (for example
   THL or INS).
5. Know which stock build the phone runs (Settings, About phone,
   Software information, build number). Method A patches the AP
   tar of that exact build.

## Method A: Magisk, patch the AP (Samsung standard, no recovery needed)

This is the standard Magisk method for Samsung phones.

1. Download the **Magisk APK** (latest release) from
   https://github.com/topjohnwu/Magisk/releases and install it on
   the phone.
2. Copy the stock **AP tar** (for example
   `AP_G990EXXSJHYJ4_...tar.md5`, from the
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
   Load the **patched tar in the AP slot**. If the phone is already
   on this exact stock build, AP-only is enough. Otherwise load BL,
   CP, and CSC from the same firmware package as well. Leave
   Re-Partition unticked. Click Start and wait for PASS.
7. Reboot. Open Magisk. It shows **Installed**.

## Method B: Magisk, patch the boot image (needs a custom recovery)

1. Extract `boot.img` from the stock AP tar. The AP tar is a plain
   tar: `tar -xf AP_...tar.md5 boot.img`.
2. Copy `boot.img` to the phone. In the Magisk app: Install,
   Select and Patch a File, pick `boot.img`. You get
   `magisk_patched-*.img` in Download.
3. Copy the patched image back to the phone. In the recovery:
   Install, **Install Image**, select the patched image, flash to
   the **Boot** partition. Reboot.
4. Verify as below.

## Method C: Magisk zip in the recovery

This method is the one the r9s TWRP thread itself uses: its step 7
is "Flash magisk apk in twrp."

1. Rename the Magisk APK to `Magisk-vXX.zip` and copy it to the
   phone (or an SD card).
2. In the recovery: Install, select the zip, flash it, reboot.
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

- **APatch: not verified on this device.** No end-to-end APatch
  run on the SM-G990E was found in this pass. Do not present it
  as working here until one is. TODO: check for an APatch report
  on the r9s before recommending it.
- **KernelSU: no standalone KernelSU kernel verified for this
  device.** KernelSU needs a kernel built with KernelSU support.
  One data point exists: the "StockLite rom for SM-G990E" ships
  pre-rooted with KernelSU Next (v1.0.4), but that is root inside
  that custom ROM, not a kernel you can flash on stock. Do not
  chase KernelSU on stock r9s unless you build or obtain a
  KernelSU-enabled kernel for the r9s first. TODO: verify whether
  a standalone KernelSU kernel exists for the r9s.
- **Any other root tool:** none recommended for this device. TODO.

## After root

- Modules install from the Magisk app (or the APatch app).
- If a banking app fails, that is Play Integrity, not a broken
  root. UN1CA ships a Play Integrity Fix (see
  [flash-un1ca.md](flash-un1ca.md)). On stock, PIF and Shamiko
  style modules exist but are **not verified by us** on this phone,
  so they are named here, not recommended.
- Do not take system OTA updates on a rooted phone. They remove
  root and can fail mid-install. On this device an OTA to One UI 8
  would also remove the unlock option permanently (see
  [unlock-bootloader.md](unlock-bootloader.md)).
- Do not write to the bootloader partitions (`aboot` / `xbl` /
  `sbl`) from root. That bricks the phone.

## Troubleshooting

- **Magisk shows "Installed: N/A".** You patched the wrong build.
  Check the build number on the phone and patch the AP or boot
  image from that exact build.
- **`su` is denied.** Root did not stick. Reboot into the recovery
  and check the Boot partition holds the patched image (Method B),
  or re-flash the patched AP tar (Method A).
- **Bootloop after flashing a patched image.** Reboot into the
  recovery and flash the stock `boot.img` from the AP tar to the
  Boot partition (Install Image, Boot). The phone is back to
  unrooted stock boot. Then re-do the method.
- **Banking app fails after root.** Play Integrity. See "After
  root" above. This is expected, not a broken root.

## Next step

Flash UN1CA: [flash-un1ca.md](flash-un1ca.md). Or flash the
HyperOS GSI: [flash-gsi.md](flash-gsi.md).

## Sources

- Method C (flash Magisk APK in TWRP) and the recovery it runs
  in: "[CLOSED][RECOVERY][UNOFFICIAL] TWRP for Galaxy S21 FE
  (Exynos)",
  https://xdaforums.com/t/closed-recovery-unofficial-twrp-for-galaxy-s21-fe-exynos.4421829/
  (step 7).
- KernelSU Next in a custom ROM (not stock): "StockLite rom for
  SM-G990E",
  https://xdaforums.com/t/stocklite-rom-for-sm-g990e.4719034/
  ("the rom comes pre rooted with ksu next").
- One UI 8 unlock removal (which blocks root on One UI 8):
  https://xdaforums.com/t/unlock-bootloader-g990e.4781493/
- Magisk releases: https://github.com/topjohnwu/Magisk/releases
- Shared Samsung root flow (Methods A and B, Odin slots,
  Re-Partition rule): `../m51/root.md` in this repo.
