# Root - Galaxy A72 (SM-A725F)

Root the SM-A725F. This file is for the SM-A725F only. Do not use
it on any other model.

## What root is

Root is administrator access to the phone's own system. You can
read and change anything, install modules, and run root apps. This
file documents the exact methods so anyone can reproduce them.
Root has not been run end to end on an A72 in front of us; the
methods below are the standard Samsung Magisk methods, adapted to
this device's own firmware identifiers. TODO: run one method on a
live A72 and record the result.

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
   information: model must read **SM-A725F**. The upstream target
   firmware is BTU
   (`target/a72q/config.sh` line 8).
5. Know which stock build the phone runs (Settings, About phone,
   Software information, build number). Method A patches the AP
   tar of that exact build. The latest BTU build is
   `UP1A.231005.007.A725FXXSBFYC1` (see flash-stock.md).

## Method A: Magisk, patch the AP (Samsung standard, no TWRP needed)

This is the standard Magisk method for Samsung phones.

1. Download the **Magisk APK** (latest release) from
   https://github.com/topjohnwu/Magisk/releases and install it on
   the phone.
2. Copy the stock **AP tar** (`AP_A725FXXSBFYC1_...tar.md5`, from
   the [flash-stock.md](flash-stock.md) firmware) to the phone's
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

## Verify

- Open the Magisk app. It shows **Installed** with a version
  number.
- From a PC: `adb shell su -c id` prints `uid=0(root)`.
- If the app shows "Installed: N/A" or `su` is denied, the patch
  did not take. Re-do the method from step 1 and check you patched
  the AP or boot image of the build that is actually on the phone.

## Other root methods

- **APatch:** not verified on this device. APatch is KernelPatch
  based and follows the same shape as Method B (patch `boot.img`,
  flash to Boot in TWRP), but nobody has run it end to end on an
  A72 in front of us. Do not treat it as a proven method here.
  TODO: check the APatch supported-device record for sm7125
  before recommending it.
- **KernelSU:** not recommended. KernelSU needs a kernel built
  with KernelSU support. The stock A72 kernel (4.14.190-perf, see
  flash-kernel.md) does not have it, and no KernelSU-enabled
  kernel for this device has been verified by us. Do not chase
  KernelSU on this phone unless you build or obtain a
  KernelSU-enabled kernel for the a72q first.
- **SuperSU:** do not use it. The old guides that bundle SuperSU
  with this device are from 2021 and SuperSU is unmaintained.
  Magisk is the method.
- **AAO (Automatic Android Optimizer): do not install.** It is a
  nightly Magisk optimizer that re-tunes zram and swappiness on
  every boot. This project has no a72q fix pack yet, so there is
  nothing for it to fight today, but it is the same class of tool
  that undoes tuned memory settings on other devices in this
  porter. Do not install optimizers that re-tune memory
  behaviour.

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
- **Banking app fails after root.** Play Integrity. See "After
  root" above. This is expected, not a broken root.

## Sources

- Upstream target config:
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/a72q/config.sh
  line 8 (BTU target firmware).
- Stock build identifiers:
  https://www.sammobile.com/samsung/galaxy-a72/firmware/SM-A725F/BTU/download/A725FXXSBFYC1/1914787/
  (build `UP1A.231005.007.A725FXXSBFYC1`, Android 14, One UI 6.1).
- Magisk releases: https://github.com/topjohnwu/Magisk/releases
- Methods A, B and C are the standard Samsung Magisk methods as
  documented in this porter's m51 guide, adapted to the A72 AP
  filename pattern. No A72-specific root run has been done in
  front of us yet; that is the TODO at the top of this file.
