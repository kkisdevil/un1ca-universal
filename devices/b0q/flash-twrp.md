# Flash TWRP - Galaxy S22 Ultra (SM-S908E)

Flash the custom recovery on the Galaxy S22 Ultra (Snapdragon),
codename `b0q`. This file is for the SM-S908E, SM-S908N, and
SM-S9080 only. Do not use it on any other model, and do not use
it on the Exynos S22 Ultra (SM-S908B): that phone is codename
`b0s`, not `b0q`.

## What TWRP is

TWRP is a custom recovery: the menu you boot into to install zips,
make backups, and wipe. Everything in this folder is flashed
through it. This device uses dynamic partitions, so TWRP will not
let you modify the individual partitions inside super on the
stock ROM; backups and restores cover the full super partition,
and flashing individual partitions needs fastbootd (see below).

## Verified build

**TODO: version, build date, and file hash are not yet verified.**
What is verified:

- TWRP is **official** for this device. The official device page
  lists Support Status: Current, Maintainer: Archer3770, Code
  Name: b0q. Get the file only from the official download mirrors
  linked on that page.
- The device tree is
  https://github.com/afaneh92/android_device_samsung_b0q
  (supported models: Galaxy S22 Ultra Snapdragon S908E, S908N,
  S9080).
- The XDA thread that originally shipped this TWRP is
  "[CLOSED][RECOVERY][UNOFFICIAL] TWRP for Galaxy S22 Ultra
  (Snapdragon)" by afaneh92. It is closed, and its download links
  point at Android File Host and Drive mirrors that are no longer
  the current source. Use the official twrp.me build, not the
  closed thread's files.

TODO: open https://dl.twrp.me/b0q/ , record the latest version
and build date, download the `.tar`, and record its size and
SHA-256 here. The download page could not be reached during
research (DNS failure), so no version is claimed here. Do not
flash a TWRP file whose version you have not checked against the
official page.

## Prereqs

1. **Unlocked bootloader.** Do
   [unlock-bootloader.md](unlock-bootloader.md) first.
2. **Back up everything** and back up EFS in TWRP if it is already
   installed. Flashing TWRP itself does not wipe data, but the
   Format Data step below does.
3. **Log out of Google and Samsung accounts** before wiping, or
   Factory Reset Protection can lock you out afterwards.
4. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself. No hubs, no front-panel ports.
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-S908E**, **SM-S908N**, or
   **SM-S9080**.

## What you need

- A Windows PC with the **Samsung USB Driver** installed (from
  Samsung: developer.samsung.com) and Samsung Smart Switch closed.
- **Odin3.** Odin is Windows-only. On Linux, `samloader-rs flash`
  speaks the same Odin protocol. Odin is a leaked internal tool,
  not officially distributed by Samsung, and its binary is never
  committed to our repos. TODO: record the Odin version and
  SHA-256 verified from a trusted source for this device. The
  S22 Ultra guides name Odin3 v3.14.4, but no hash for it has
  been verified here; do not copy another device's hash.
- `vbmeta_disabled_R.tar`: a disabled vbmeta, so the unsigned
  TWRP and GSI can boot. Named in the XDA b0q thread below.
  On this device it goes in the **USERDATA** slot, not the AP
  slot. That is the b0q thread's own instruction, verified
  against the thread's first post. Do not move it to another slot.
- The **TWRP tar** for b0q, from the official twrp.me mirrors
  linked on the device page.
- `multidisabler`, run from TWRP's terminal (see step 6). It stops
  stock from re-encrypting things after the flash. The XDA thread
  says to run it twice if it asks, until it prints `Finished.`
- A custom permissive kernel, flashed in TWRP after
  multidisabler. The XDA thread notes you need a custom
  permissive kernel to boot with read/write vendor. TODO: name
  the kernel and its source; none is recorded for b0q yet.

## Steps

1. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
2. Open Odin **as administrator**. The `ID:COM` box turns blue and
   shows `Added!` when the phone is detected. If nothing appears,
   the driver, cable, or port is the problem. Do not proceed.
3. **Uncheck Auto Reboot in Odin** before flashing. This matters:
   you must catch recovery before the system boots.
4. Load the **TWRP tar in the AP slot** and
   `vbmeta_disabled_R.tar` in the **USERDATA** slot, then flash.
   Wait for PASS.
5. **The moment Odin shows PASS, boot straight into recovery. Do
   not let the phone boot to system.** Hold **Volume Down + Power**
   until the screen goes black, then immediately switch to holding
   **Volume Up + Power** (with USB connected) until the TWRP logo
   appears. If the phone boots to system first, stock recovery
   gets restored and you have to flash TWRP again.
6. In TWRP, disable encryption: Advanced, Terminal, type
   `multidisabler`. If it complains about free space on vendor it
   will try to resize vendor; run `multidisabler` again until it
   prints `Finished.`
7. **Format Data:** Wipe, Format Data, type `yes`. This is a
   format, not a wipe. It removes encryption so TWRP and the ROM
   can use /data.
8. Reboot to recovery (not to system), then flash the custom
   permissive kernel and Magisk if you want root (see
   [root.md](root.md)).
9. Reboot, System for a stock boot, or stay in TWRP for the next
   flash (root, GSI, UN1CA, or kernel).

## Verify

- Reboot to recovery (power off, hold Volume Up + Power with USB
  connected). TWRP opens. TODO: record the version shown on the
  main screen once the official build is downloaded.
- In TWRP, /data mounts and Format Data completed without errors.

## Keeping TWRP: the rules

- A full stock AP flash **replaces TWRP** with stock recovery
  (the stock AP tar contains `recovery.img`). To keep TWRP, either
  remove `recovery.img` from the AP tar before flashing (advanced:
  re-pack the tar and recompute the trailing MD5; the `.md5`
  suffix is only a checksum footer, not a signature), or flash
  stock and then **immediately re-flash TWRP before the first boot
  into system** (steps 2 to 5 above, then boot straight into
  recovery).
- The official twrp.me page warns that many devices replace the
  custom recovery automatically during first boot, and that once
  TWRP has booted it patches the stock ROM to prevent the stock
  ROM from replacing TWRP. Do not skip the boot-straight-to-
  recovery step.
- Never let a ROM's own updater touch recovery.
- After any stock flash, re-flash TWRP before doing custom work
  again, and take a fresh TWRP backup (including EFS) once the
  phone is back on stock.
- /data decryption inside TWRP is **not fully working** on this
  device (listed under Bugs in the XDA thread). Do not rely on
  TWRP to read an encrypted /data. Format Data (step 7) removes
  encryption. Keep your real backups on the system side.
- **Do not follow the vbmeta-on-AP variant that appears in some
  other guides.** On this device the XDA thread puts the disabled
  vbmeta in the USERDATA slot. That is the b0q-specific route.

## Troubleshooting

- **Odin does not see the phone.** Reinstall the Samsung USB
  Driver, try another port (on the PC itself, not a hub) and
  another data cable. Confirm the phone is in Download mode, not
  just charging.
- **TWRP is gone after a boot.** You booted to system first.
  Re-flash from step 2 and boot straight to recovery this time.
- **Stuck on the Samsung logo after flashing.** Boot into
  recovery and wipe metadata from the Advanced Wipe section (XDA
  thread note 2), then Format Data again if needed.
- **TWRP asks for a password or cannot mount /data.** That is the
  known incomplete encryption support on this device. Format Data
  (step 7) removes encryption. If you need the data on /data,
  stop: back it up from the running system first, then format.
- **`SW REV CHECK FAIL (VBMETA)`.** The vbmeta binary is older
  than the phone's vbmeta revision. Get a vbmeta matching your
  firmware's bootloader level; do not flash an old one over a
  newer phone. TODO: confirm the exact vbmeta revision rule for
  b0q.

## Next step

Root the phone: [root.md](root.md). Or flash something:
[flash-stock.md](flash-stock.md),
[flash-gsi.md](flash-gsi.md), [flash-un1ca.md](flash-un1ca.md),
[flash-kernel.md](flash-kernel.md).

## Sources

- Official device page (status Current, maintainer Archer3770,
  codename b0q, dynamic partitions note, Odin method):
  https://twrp.me/samsung/samsunggalaxyb0q.html
- Device tree (supported models S908E/S908N/S9080):
  https://github.com/afaneh92/android_device_samsung_b0q
- Install steps (AP slot TWRP, USERDATA slot vbmeta, recovery
  combo, multidisabler twice, Format Data, permissive kernel,
  encryption bug, metadata wipe):
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-s22-ultra-snapdragon.4453235/
  (afaneh92; closed Dec 2023, so its download links are stale
  and the official twrp.me build is the source to use).
- Recovery combo with USB connected:
  https://droidwin.com/install-twrp-recovery-on-galaxy-s22-ultra-root-via-magisk/
- TWRP version, build date, file hash, Odin version and hash,
  and the permissive kernel: TODO, not verified (dl.twrp.me
  unreachable during research).
