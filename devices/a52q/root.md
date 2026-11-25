# Root - Galaxy A52 (SM-A525F)

Root the SM-A525F. This file is for the SM-A525F only. Do not use
it on any other model.

## What root is

Root is administrator access to the phone's own system. You can
read and change anything, install modules, and run root apps.

## What root costs on this device

- Knox is already tripped by the unlock, so root adds no new
  permanent loss.
- Banking apps and Play Integrity can fail on a rooted phone.
- System OTA updates will remove root. Do not take them.
- You must **never relock the bootloader** with root installed.
  That bricks the phone.
- To unroot: flash the stock boot or AP ([flash-stock.md](flash-stock.md)),
  or in Magisk go to Uninstall, Restore Images, then flash stock
  recovery (see the note below: on this device Magisk lives in
  the recovery partition, so unrooting means restoring the stock
  recovery image, not just the boot image).

## The one thing that is different on this device

On the a52q, **Magisk installs to the recovery partition, not the
boot partition**. This is stated on the official TWRP device page
for the a52q: the phone uses system-as-root in an A-only partition
configuration, both TWRP and Magisk-rooted Android boot using the
recovery kernel, and the hardware keys choose between TWRP and
Android at boot time. Three consequences follow, and they change
the methods below:

1. Patching `boot.img` does **not** give root on this device.
   Do not use the m51 Method B (patch the boot image) here.
2. Flashing the Magisk zip in TWRP does **not** work. The TWRP
   page says the Magisk installer does not support installation
   to recovery from TWRP.
3. The TWRP page advises rooting with Magisk first, then
   pre-rooting a TWRP image before flashing it to recovery.
   That order is the recommended route if you want both root and
   TWRP.

## Prereqs

1. **Unlocked bootloader** ([unlock-bootloader.md](unlock-bootloader.md)).
2. **Back up everything.** Rooting itself does not wipe data, but
   a wrong flash can. Back up EFS in TWRP first (once TWRP is
   installed).
3. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself for the Odin steps.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A525F** and the service
   provider software version must show **EUX**.
5. Know which stock build the phone runs (Settings, About phone,
   Software information, build number). Method A patches the AP
   tar of that exact build.

## Method A: Magisk, patch the AP (Samsung standard, no TWRP needed)

This is the standard Magisk method for Samsung phones, and the
primary method for this device. The AP tar contains
`recovery.img`, which is where Magisk installs on the a52q.

1. Download the **Magisk APK** (latest release) from
   https://github.com/topjohnwu/Magisk/releases and install it on
   the phone.
2. Copy the stock **AP tar** (`AP_A525FXX..._...tar.md5`, from
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

Note the boot-key behaviour on this device: because Magisk lives
in recovery, the hardware keys at boot choose between TWRP and
Android. TODO: the exact key combination that boots the
Magisk-rooted system (as opposed to TWRP) was not pinned down from
the sources read for this guide. Confirm it on the device and
record it here before telling anyone to rely on it.

## Method B: Magisk, patch the recovery image (needs TWRP)

This is the a52q replacement for the usual "patch the boot image"
method. It patches `recovery.img`, not `boot.img`.

1. Extract `recovery.img` from the stock AP tar. The AP tar is a
   plain tar: `tar -xf AP_...tar.md5 recovery.img`.
2. Copy `recovery.img` to the phone. In the Magisk app: Install,
   Select and Patch a File, pick `recovery.img`. You get
   `magisk_patched-*.img` in Download.
3. Copy the patched image back to the phone. In TWRP: Install,
   **Install Image**, select the patched image, flash to the
   **Recovery** partition. Reboot.
4. Verify as below.

TODO: this method is the direct application of the TWRP device
page's statement that Magisk installs to the recovery partition.
It has not been run end to end on an a52q in front of us. The
Magisk app's "Select and Patch a File" flow on a recovery image
is the step to confirm on the device.

## Method C: Magisk zip in TWRP

**Does not work on this device.** The official TWRP device page
for the a52q says the Magisk installer does not support
installation to recovery from TWRP. Do not flash a Magisk zip in
TWRP on the a52q. Use Method A or Method B.

## Pre-rooted TWRP (the TWRP page's recommended order)

If you want both root and TWRP: root first with Method A, then
use the Magisk app to patch the TWRP image
(`twrp-3.7.1_12-0-a52q.img`) the same way Method B patches a
recovery image, and flash the patched TWRP image to the Recovery
partition. That gives you a TWRP that keeps root. See
[flash-twrp.md](flash-twrp.md) for the TWRP build and hashes.
TODO: the exact Magisk menu path for patching a recovery image
("Install to recovery" wording) was not confirmed from the sources
read for this guide. Confirm it on the device.

## Verify

- Open the Magisk app. It shows **Installed** with a version
  number.
- From a PC: `adb shell su -c id` prints `uid=0(root)`.
- If the app shows "Installed: N/A" or `su` is denied, the patch
  did not take. Re-do the method from step 1 and check you patched
  the AP or recovery image of the build that is actually on the
  phone.

## Other root methods

- **APatch: not verified on this device.** No a52q-specific APatch
  report was found while writing this guide. APatch patches the
  boot image, and on this device root lives in recovery, so an
  APatch boot-image patch is not expected to give root here.
  Do not recommend it until someone runs it end to end on an
  a52q and reports the result.
- **KernelSU: not recommended.** KernelSU needs a kernel built
  with KernelSU support. The kernel named for this device is the
  Ascendia kernel
  (https://github.com/RisenID/kernel_samsung_ascendia_sm7125),
  and no source was found stating it carries KernelSU support.
  Do not chase KernelSU on this phone unless you build or obtain
  a KernelSU-enabled kernel for the a52q first. TODO: check the
  Ascendia kernel config for KernelSU support.
- **No module conflict list exists for this device yet.** There is
  no a52q fix pack (see [flash-un1ca.md](flash-un1ca.md)), so
  there is no known optimizer that fights it. TODO: build this
  list once an a52q fix pack exists.

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
- Do not flash a plain TWRP image over a Magisk-patched recovery,
  or flash stock recovery, without expecting to lose root. On
  this device TWRP and Magisk share the recovery partition.

## Troubleshooting

- **Magisk shows "Installed: N/A".** You patched the wrong build,
  or you patched `boot.img` instead of the AP or `recovery.img`.
  Check the build number on the phone and patch the AP or
  recovery image from that exact build.
- **`su` is denied.** Root did not stick. Reboot into TWRP and
  check the Recovery partition holds the patched image
  (Method B), or re-flash the patched AP tar (Method A).
- **Bootloop after flashing a patched image.** Reboot into TWRP
  and flash the stock `recovery.img` from the AP tar to the
  Recovery partition (Install Image, Recovery). The phone is back
  to unrooted stock recovery. Then re-do the method. Do not wipe
  data first: this is a recovery image problem, and a wipe will
  not fix it.
- **Banking app fails after root.** Play Integrity. See "After
  root" above. This is expected, not a broken root.

## Sources

- Official TWRP device page, Samsung Galaxy A52 4G (a52q):
  system-as-root A-only, Magisk installs to the recovery
  partition, root first then pre-rooted TWRP, Magisk installer
  does not support installation to recovery from TWRP:
  https://test.twrp.me/samsung/samsunggalaxya52q.html
- Magisk releases: https://github.com/topjohnwu/Magisk/releases
- Ascendia kernel (named in the UN1CA XDA thread for the a52q):
  https://github.com/RisenID/kernel_samsung_ascendia_sm7125
- Odin3 v3.14.1 SHA-256 and the Samsung USB driver source are the
  shared Samsung tool values already verified in this repo, not
  a52q values.
- TODO: exact boot-key behaviour for the Magisk-rooted system;
  Method B run end to end on an a52q; Magisk menu wording for
  patching a recovery image; KernelSU support in the Ascendia
  kernel; any a52q APatch report.
