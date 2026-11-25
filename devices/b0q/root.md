# Root - Galaxy S22 Ultra (SM-S908E)

Root the Galaxy S22 Ultra (Snapdragon), codename `b0q`. This file
is for the SM-S908E, SM-S908N, and SM-S9080 only. Do not use it
on any other model, and do not use it on the Exynos S22 Ultra
(SM-S908B, codename `b0s`).

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
- To unroot: flash the stock boot or AP
  ([flash-stock.md](flash-stock.md)), or in Magisk go to
  Uninstall, Restore Images, then flash stock boot.

## Prereqs

1. **Unlocked bootloader** ([unlock-bootloader.md](unlock-bootloader.md)).
   For Methods B and C you also need TWRP
   ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything.** Rooting itself does not wipe data, but
   a wrong flash can. Back up EFS in TWRP first.
3. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself for the Odin steps.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-S908E**, **SM-S908N**, or
   **SM-S9080**.
5. Know which stock build the phone runs (Settings, About phone,
   Software information, build number). Method A patches the AP
   tar of that exact build. The current latest for INS is build
   `BP2A.250605.031.A3.S908EXXSEGZH4` (see
   [flash-stock.md](flash-stock.md)).

## Method A: Magisk, patch the AP (Samsung standard, no TWRP needed)

This is the standard Magisk method for Samsung phones.

1. Download the **Magisk APK** (latest release) from
   https://github.com/topjohnwu/Magisk/releases and install it on
   the phone.
2. Copy the stock **AP tar** (for example
   `AP_S908EXXSEGZH4_...tar.md5`, from the
   [flash-stock.md](flash-stock.md) firmware) to the phone's
   internal storage. TODO: confirm the exact AP filename once
   the firmware zip is downloaded; the pattern above is the
   standard Samsung naming for this build, not a verified
   filename.
3. Open Magisk, **Install**, **Select and Patch a File**, pick the
   AP tar. Magisk patches it (takes minutes: the AP is huge) and
   writes `magisk_patched-*.tar` to the Download folder.
4. Copy the patched tar back to the PC.
5. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
6. Open Odin **as administrator**. Load the **patched tar in the
   AP slot**. If the phone is already on this exact stock build,
   AP-only is enough. Otherwise load BL, CP, and CSC from the
   same firmware package as well. Leave Re-Partition unticked.
   Click Start and wait for PASS.
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

This is the route the b0q XDA thread itself uses: after
multidisabler and Format Data, flash the custom kernel and the
Magisk APK in TWRP.

1. Rename the Magisk APK to `Magisk-vXX.zip` and copy it to the
   phone (or an SD card / USB-OTG).
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

- **APatch: not verified on this device.** No b0q-specific APatch
  report was found during research. Do not assume it works here.
  TODO: record whether APatch (KernelPatch based) has been run
  end-to-end on a b0q.
- **KernelSU: not recommended.** KernelSU needs a kernel built
  with KernelSU support. No KernelSU-enabled kernel for the b0q
  has been verified here. Do not chase KernelSU on this phone
  unless you build or obtain a KernelSU-enabled kernel for the
  b0q first.
- **No optimizer or module is named here** as fighting this
  project's fixes on this device, because no fix pack exists for
  the b0q yet (see [flash-un1ca.md](flash-un1ca.md)). TODO: add
  the warning if a b0q fix pack is ever made.

## After root

- Modules install from the Magisk app (or the APatch app).
- If a banking app fails, that is Play Integrity, not a broken
  root. On stock, PIF and Shamiko style modules exist but are
  **not verified by us** on this phone, so they are named here,
  not recommended.
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
  stock boot. Then re-do the method. If the bootloop is on the
  Samsung logo right after a TWRP install, wipe metadata from
  TWRP's Advanced Wipe first (XDA thread note).
- **Banking app fails after root.** Play Integrity. See "After
  root" above. This is expected, not a broken root.

## Sources

- Method A and B are the standard Samsung Magisk methods; the
  build number to patch against is from SamFrew
  (https://samfrew.com/download/Galaxy__S22__Ultra__/45va/INS/S908EXXSCGZA2/S908EOXMCGZA2
  and the INS firmware list
  https://samfrew.com/firmware/model/SM-S908E/region/INS/upload/Desc/0/10).
- Method C (custom kernel plus Magisk in TWRP after multidisabler)
  and the metadata-wipe note: XDA thread
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-s22-ultra-snapdragon.4453235/
- Magisk releases: https://github.com/topjohnwu/Magisk/releases
- APatch and KernelSU status on b0q: TODO, no verified report
  found during research.
- Exact AP tar filename for the current firmware: TODO, pending a
  firmware download.
