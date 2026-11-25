# Root - Galaxy A53 5G (SM-A536B)

Root the SM-A536B. This file is for the SM-A536B only. Do not use
it on any other model.

## The one device difference that changes everything

On this phone **Magisk installs to the recovery partition, not
the boot partition**. The device is system-as-root in an A-only
partition layout, and both TWRP and a Magisk-rooted Android boot
using the recovery kernel. The official TWRP page states this
plainly and advises rooting with Magisk first, then pre-rooting a
TWRP image before flashing it to recovery. Do not patch
`boot.img` expecting root: on this device that is not where
Magisk lives.

## What root is

Root is administrator access to the phone's own system. You can
read and change anything, install modules, and run root apps.

## What root costs

- Knox is already tripped by the unlock, so root adds no new
  permanent loss.
- Banking apps and Play Integrity can fail on a rooted phone.
- System OTA updates will remove root. Do not take them. The
  ExynosUnbound kernel thread states it bluntly: never update
  via OTA if the device is rooted or has any partition different
  from stock.
- You must **never relock the bootloader** with root installed.
  That bricks the phone.
- To unroot: flash the stock AP ([flash-stock.md](flash-stock.md)),
  which restores the stock recovery, or in Magisk go to
  Uninstall, Restore Images, then flash stock recovery.

## Prereqs

1. **Unlocked bootloader** ([unlock-bootloader.md](unlock-bootloader.md)).
   Method A needs no TWRP. Method B needs TWRP
   ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything.** Rooting itself does not wipe data, but
   a wrong flash can. Back up EFS in TWRP first if TWRP is
   installed.
3. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself for the Odin steps.
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A536B** and the service
   provider software version must show **EUX**.
5. Know which stock build the phone runs (Settings, About phone,
   Software information, build number). Method A patches the AP
   tar of that exact build.

## Method A: Magisk, patch the AP (Samsung standard, no TWRP needed)

This is the standard Magisk method for Samsung phones, and the
recommended first step on this device because Magisk here
patches recovery inside the AP.

1. Download the **Magisk APK** (latest release) from
   https://github.com/topjohnwu/Magisk/releases and install it on
   the phone.
2. Copy the stock **AP tar** (`AP_A536BXXU...tar.md5`, from the
   [flash-stock.md](flash-stock.md) firmware) to the phone's
   internal storage.
3. Open Magisk, **Install**, **Select and Patch a File**, pick the
   AP tar. Magisk patches it (takes minutes: the AP is huge) and
   writes `magisk_patched-*.tar` to the Download folder. On this
   device Magisk patches the recovery image inside the AP, not
   the boot image.
4. Copy the patched tar back to the PC.
5. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
6. Open Odin **as administrator** (Odin3 v3.14.1). Load the
   **patched tar in the AP slot**. If the phone is already on
   this exact stock build, AP-only is enough. Otherwise load BL,
   CP, and CSC from the same firmware package as well. Leave
   Re-Partition unticked. Click Start and wait for PASS.
7. Reboot. Open Magisk. It shows **Installed**.

## Method B: Magisk, patch the recovery image (needs TWRP)

Use this if you already have TWRP and want to root or re-root
without Odin.

1. Extract `recovery.img` from the stock AP tar. The AP tar is a
   plain tar: `tar -xf AP_...tar.md5 recovery.img`.
2. Copy `recovery.img` to the phone. In the Magisk app: Install,
   Select and Patch a File, pick `recovery.img`. You get
   `magisk_patched-*.img` in Download.
3. Copy the patched image back to the phone. In TWRP: Install,
   **Install Image**, select the patched image, flash to the
   **Recovery** partition. Reboot.
4. Verify as below.

Do NOT use the "patch the boot image" variant on this device.
Magisk does not live in boot here; a patched `boot.img` will not
give you root, and flashing it to Boot is wasted effort at best.

## Method C: Magisk zip in TWRP

**Does not work on this device.** The official TWRP page states
the Magisk installer does not support installation to recovery
from TWRP. Do not flash a Magisk zip in TWRP expecting root. Use
Method A or Method B.

## Verify

- Open the Magisk app. It shows **Installed** with a version
  number.
- From a PC: `adb shell su -c id` prints `uid=0(root)`.
- If the app shows "Installed: N/A" or `su` is denied, the patch
  did not take. Re-do the method from step 1 and check you
  patched the AP or recovery image of the build that is actually
  on the phone.

## Other root methods

- **KernelSU: available through the ExynosUnbound kernel.** The
  ExynosUnbound kernel for a53x ships KernelSU built in (v0.6.9
  in release R1.0; later releases carry newer KernelSU). Install
  the kernel (see [flash-kernel.md](flash-kernel.md)), then
  install the KernelSU manager app; if you do not want KernelSU,
  simply do not install the manager and Magisk works as normal.
  TODO: the newest ExynosUnbound release and its KernelSU version
  were not verified at the time of writing; check the XDA thread
  before flashing.
- **APatch: not verified on this device.** No end-to-end APatch
  run on the a53x was found in the sources checked. Do not treat
  it as a working method here until someone runs it on this
  phone and records it.
- **AAO (Automatic Android Optimizer) and similar nightly
  optimizers: do not install.** No a53x fix pack exists yet to
  protect, but a nightly optimizer that re-tunes zram and
  swappiness will fight any tuning this project adds later. See
  [flash-un1ca.md](flash-un1ca.md).

## After root

- Modules install from the Magisk app (or the KernelSU manager
  app, if you use the ExynosUnbound kernel).
- If a banking app fails, that is Play Integrity, not a broken
  root. UN1CA ships a Play Integrity Fix (see
  [flash-un1ca.md](flash-un1ca.md)). On stock, PIF and Shamiko
  style modules exist but are **not verified by us** on this
  phone, so they are named here, not recommended.
- Do not take system OTA updates on a rooted phone. They remove
  root and can fail mid-install.
- Do not write to the bootloader partitions from root. That
  bricks the phone.

## Troubleshooting

- **Magisk shows "Installed: N/A".** You patched the wrong build,
  or you patched `boot.img` instead of the AP/recovery. Check
  the build number on the phone and patch the AP or recovery
  image from that exact build.
- **`su` is denied.** Root did not stick. Reboot into TWRP and
  check the Recovery partition holds the patched image (Method
  B), or re-flash the patched AP tar (Method A).
- **Bootloop after flashing a patched image.** Reboot into TWRP
  and flash the stock `recovery.img` from the AP tar to the
  Recovery partition (Install Image, Recovery). The phone is
  back to unrooted stock recovery. Then re-do the method.
- **Banking app fails after root.** Play Integrity. See "After
  root" above. This is expected, not a broken root.

## Sources

- Magisk installs to the recovery partition on a53x, root-first
  advice, Magisk installer not supporting install to recovery
  from TWRP: https://twrp.me/samsung/samsunggalaxya53.html
- Magisk APK releases: https://github.com/topjohnwu/Magisk/releases
- KernelSU in ExynosUnbound, OTA warning, Magisk still works if
  the KernelSU manager is not installed: XDA thread "[KERNEL]
  [a53x] ExynosUnbound Kernel for Galaxy A53 5G",
  https://xdaforums.com/t/kernel-a53x-exynosunbound-kernel-for-galaxy-a53-5g.4637659/
- AP tar filename pattern and stock build: SamFrew record for
  SM-A536B EUX, https://samfrew.com/download/Galaxy__A53__5G__/5wgv/EUX/A536BXXSJGZA2/A536BOXMJGZA2
