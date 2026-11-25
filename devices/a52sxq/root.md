# Root - Galaxy A52s 5G (SM-A528B)

Root the SM-A528B. This file is for the SM-A528B only. Do not use
it on any other model.

## What root is

Root is administrator access to the phone's own system. You can
read and change anything, install modules, and run root apps.
This file documents the standard Samsung Magisk methods for this
device. None of them has been run end to end by us on this phone
in this session: the steps are the device-specific published
methods, marked where they are unverified.

## What root costs

- Knox is already tripped by the unlock, so root adds no new
  permanent loss.
- Banking apps and Play Integrity can fail on a rooted phone.
  The Android Infotech A52s root guide lists the same cost: no
  Samsung Pay, no Secure Folder, and some official Samsung apps
  stop working.
- System OTA updates will remove root and can fail mid-install.
  After root, update firmware manually by patching the new build
  the same way. Do not take OTAs.
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
   information: model must read **SM-A528B**. The UN1CA target
   firmware is the BTU region build (upstream
   `target/a52sxq/config.sh` line 13); check your own CSC and do
   not patch another region's AP.
5. Know which stock build the phone runs (Settings, About phone,
   Software information, build number). Method A patches the AP
   tar of that exact build. The latest BTU build found in this
   research is A528BXXSBGYI3 (Android 14, One UI 6.1, build
   2025-09-11, security patch 2025-09-01); see
   [flash-stock.md](flash-stock.md).

## Method A: Magisk, patch the AP (Samsung standard, no TWRP needed)

This is the standard Magisk method for Samsung phones, and the
one the A52s guides use.

1. Download the **Magisk APK** (latest release) from
   https://github.com/topjohnwu/Magisk/releases and install it on
   the phone.
2. Copy the stock **AP tar** (`AP_A528BXXSBGYI3_...tar.md5` for
   the latest BTU build, from the [flash-stock.md](flash-stock.md)
   firmware) to the phone's internal storage. TODO: record the
   exact AP filename for the BTU GYI3 package; the pattern above
   is the Samsung naming pattern, not a filename we listed.
3. Open Magisk, **Install**, **Select and Patch a File**, pick the
   AP tar. Magisk patches it (takes minutes: the AP is huge) and
   writes `magisk_patched-*.tar` to the Download folder.
4. Copy the patched tar back to the PC.
5. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
6. Open Odin **as administrator** (Odin3 v3.14.1; TODO: verify the
   ZIP SHA-256 from a trusted source in this session). Load the
   **patched tar in the AP slot**. If the phone is already on this
   exact stock build, AP-only is enough. Otherwise load BL, CP,
   and CSC from the same firmware package as well. Leave
   Re-Partition unticked. Click Start and wait for PASS.
7. Reboot. Open Magisk. It shows **Installed**.

## Method B: Magisk, patch the boot image (needs TWRP)

The GetDroidTips A52s root guide uses this shape: extract the
boot image from the stock firmware, patch it in Magisk, and flash
the patched image.

1. Extract `boot.img` from the stock AP tar. The AP tar is a plain
   tar: `tar -xf AP_...tar.md5 boot.img`.
2. Copy `boot.img` to the phone. In the Magisk app: Install,
   Select and Patch a File, pick `boot.img`. You get
   `magisk_patched-*.img` in Download. (The GetDroidTips guide
   describes the older "Patch Boot Image File" menu wording; the
   current Magisk wording is Select and Patch a File.)
3. Copy the patched image back to the phone. In TWRP: Install,
   **Install Image**, select the patched image, flash to the
   **Boot** partition. Reboot. Alternatively pack it into a
   `boot.tar` and flash it in Odin's AP slot.
4. Verify as below.

## Method C: Magisk zip in TWRP

1. Rename the Magisk APK to `Magisk-vXX.zip` and copy it to the
   phone (or an SD card).
2. In TWRP: Install, select the zip, flash it, reboot.
3. Verify as below. The Magisk app can also do a Direct Install
   once the phone is already booted with a patched boot.

This method works on this device because official TWRP exists for
a52sxq (see [flash-twrp.md](flash-twrp.md)). It has not been run
by us on this phone.

## Verify

- Open the Magisk app. It shows **Installed** with a version
  number.
- From a PC: `adb shell su -c id` prints `uid=0(root)`.
- If the app shows "Installed: N/A" or `su` is denied, the patch
  did not take. Re-do the method from step 1 and check you patched
  the AP or boot image of the build that is actually on the phone.

## Other root methods

- **APatch: not verified for this device.** No A52s-specific
  APatch end-to-end report was found in this research. Do not
  assume it works. TODO: check for an A52s APatch report before
  recommending it.
- **KernelSU: reported, not verified by us.** An XDA UN1CA thread
  comment says "You can just flash the latest KSU flashable zip
  after flashing the ROM to install it back", which suggests a
  KernelSU zip is used on UN1CA for this device. That is a
  comment, not a verified procedure, and no KernelSU-enabled
  kernel build for this device was found in this session. Do not
  chase KernelSU on this phone unless you obtain a KernelSU
  zip or kernel for a52sxq first and verify it. TODO: find the
  KernelSU zip source and a working report.
- **Camera note (A52s-specific).** An XDA thread is titled "How
  to root Samsung A52s (SM-A528B/DS) with working Camera" and
  reports a rooted A52s with working camera and passing
  SafetyNet. That is a user report, not our verification, and the
  exact method in that thread was not read in this session.
  TODO: read it before relying on it, because camera breakage
  after root is a known A52s complaint.

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
  stock boot. Then re-do the method.
- **Banking app fails after root.** Play Integrity. See "After
  root" above. This is expected, not a broken root.
- **Camera stops working after root.** Reported for this device
  on XDA. See "Other root methods" above; the fix, if any, is in
  the XDA camera thread, not verified here.

## Sources

- Android Infotech root guide, Android 14 SM-A528B/N (unlock,
  battery above 50%, Samsung Pay and Secure Folder loss):
  https://www.androidinfotech.com/root-samsung-galaxy-a52s-5g-android-14/
- GetDroidTips root guide (supported model SM-A528B, patch boot
  image, flash patched boot as tar in Odin):
  https://www.getdroidtips.com/root-samsung-a52s-5g-sm-a528b/
- Magisk releases: https://github.com/topjohnwu/Magisk/releases
- Official TWRP for a52sxq: https://twrp.me/samsung/samsunggalaxya52s5G.html
- XDA UN1CA 2.5.6 thread, KernelSU comment (page 3):
  https://xdaforums.com/t/rom-14-a528b-n-un1ca-2-5-0-one-ui-6-1-1-for-galaxy-a52s-5g-25-09-2024.4647289/page-3
- Upstream `target/a52sxq/config.sh` line 13 (BTU target
  firmware): https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/a52sxq/config.sh
- TODO: exact AP filename for BTU GYI3. TODO: Odin SHA-256.
  TODO: APatch report for a52sxq. TODO: KernelSU zip source and
  working report. TODO: read the XDA "root with working Camera"
  thread and record its method.
