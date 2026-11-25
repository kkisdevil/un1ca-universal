# Root - Galaxy S21+ 5G (SM-G996B)

Root the SM-G996B. This file is for the SM-G996B only. Do not use
it on any other model.

## What root is

Root is administrator access to the phone's own system. You can
read and change anything, install modules, and run root apps.

## What root costs

- Knox is already tripped by the unlock, so root adds no new
  permanent loss.
- Banking apps and Play Integrity can fail on a rooted phone.
- System OTA updates will remove root. Do not take them. OTA
  updates already stop working once custom binaries are flashed
  (see unlock-bootloader.md).
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
   information: model must read **SM-G996B** (or SM-G996B/DS).
5. Know which stock build the phone runs (Settings, About phone,
   Software information, build number). Method A patches the AP
   tar of that exact build. The newest firmware record found for
   this device is PDA `G996BXXSJHZC2` (see flash-stock.md).

## Method A: Magisk, patch the AP (Samsung standard, no TWRP needed)

This is the standard Magisk method for Samsung phones.

1. Download the **Magisk APK** (latest release) from
   https://github.com/topjohnwu/Magisk/releases and install it on
   the phone.
2. Copy the stock **AP tar** (for example
   `AP_G996BXXSJHZC2_...tar.md5`, from the
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

TODO: Method A has not been run end to end on a t2s on current
firmware in this repo. The steps are the standard Samsung Magisk
method (same shape as the m51 guide, cited below); confirm the
patched AP boots on this device and record the result before
treating it as verified.

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

TODO: Method B has not been run end to end on t2s in this repo.
Confirm it boots and record the result.

## Method C: Magisk zip in TWRP

The XDA TWRP thread for this device ends its install steps with
"Flash magisk apk in twrp", so this method is the thread's own
route.

1. Rename the Magisk APK to `Magisk-vXX.zip` and copy it to the
   phone (or an SD card). TODO: confirm the exact Magisk version
   that works with the 3.6.x TWRP on this device; the thread does
   not name one.
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

- **APatch:** TODO. No source found so far confirms APatch has
  been run end to end on t2s. Do not recommend it until someone
  has.
- **KernelSU:** TODO. KernelSU needs a kernel built with
  KernelSU support. No KernelSU-enabled kernel for t2s is known
  in this repo. Do not chase KernelSU on this phone unless you
  build or obtain one first.
- **Any other root tool:** TODO. None is recommended for this
  device yet.
- **Optimizer or module warning:** TODO. The m51 guide warns
  against a Magisk optimizer that fights the m51 lag fix pack.
  There is no t2s fix pack, so that warning does not transfer.
  Do not install a module that re-tunes zram or swappiness on
  this device until a t2s fix pack exists and says otherwise.

## After root

- Modules install from the Magisk app (or the APatch app).
- If a banking app fails, that is Play Integrity, not a broken
  root. UN1CA ships Play Integrity fixes of its own (see
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
- **Bootloop after flashing a patched AP in the AP slot in place
  of the TWRP tar.** Reported in the XDA TWRP thread: a user who
  replaced the TWRP tar with a patched AP file in the AP slot
  ended in a constant bootloop with no Download mode or recovery,
  and recovered only by forcing Download mode (USB connected,
  both volume buttons) and re-flashing TWRP 3.6.x. Keep the two
  flashes separate: TWRP tar first, patched AP after, and never
  one in place of the other.
- **Banking app fails after root.** Play Integrity. See "After
  root" above. This is expected, not a broken root.

## Sources

- XDA thread "[CLOSED][RECOVERY][UNOFFICIAL] TWRP for Galaxy
  S21+ (Exynos)" by afaneh92:
  https://xdaforums.com/t/closed-recovery-unofficial-twrp-for-galaxy-s21-exynos.4241935/page-2
  (step 7: flash Magisk APK in TWRP; patched-AP-in-place-of-TWRP
  bootloop report and recovery).
- Magisk releases: https://github.com/topjohnwu/Magisk/releases
- Method A/B/C steps, Odin3 v3.14.1 SHA-256, and guide
  structure: [../m51/root.md](../m51/root.md) (standard Samsung
  Magisk practice, not m51 values). AP tar filename pattern
  `AP_G996BXXSJHZC2_...tar.md5` comes from the firmware record
  in flash-stock.md.

## TODO

- Run Method A end to end on t2s on current firmware and record
  the result.
- Run Method B end to end on t2s and record the result.
- Confirm the Magisk version that works with TWRP 3.6.x on t2s.
- APatch and KernelSU status on t2s.
