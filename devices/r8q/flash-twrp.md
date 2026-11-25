# Flash TWRP - Galaxy S20 FE (Snapdragon) (SM-G780G)

Flash the custom recovery on the SM-G780G and keep it. This file
is for the SM-G780G only. Do not use it on any other model,
including the Exynos S20 FE (SM-G780F).

## What TWRP is

TWRP is a custom recovery: the menu you boot into to install zips,
make backups, and wipe. Everything in this repo is flashed through
it. Every other procedure in this folder assumes it.

## Official build

TWRP for r8q is **official**. Support status is Current,
maintainer **ata-kaner**, device tree
https://github.com/TeamWin/android_device_samsung_r8q, Android
12.1 base. The current version in the official XDA thread is
**TWRP 3.7.1_12-2** for the Galaxy S20 FE 4G/5G (Snapdragon).
Download it from the official TWRP device page for r8q or from
the XDA thread below.

Two things changed in the official build that catch people out:

- **Decryption support was removed** (twrp.me changelog,
  2024-10-20/21: prebuilt image updated from G780GXXSBEXG1,
  decryption support removed). The thread states TWRP cannot
  decrypt stock firmware, and decryption only works with no
  password, PIN, or pattern set, and only for FBE V2. Plan on
  Format Data, not on reading an encrypted /data.
- **There is no multidisabler for this build.** The maintainer
  writes: "Gone and will never get any support from me." Do not
  go looking for one. The older unofficial TWRP thread (3.6.2)
  used a `multidisabler` terminal command; that is not the
  official route.

## Verified build

**Not verified by us.** No TWRP image for r8q is on our phone and
no hash has been checked against a reference build. The version
above (3.7.1_12-2) is what the official XDA thread names, and the
twrp.me page confirms official support with maintainer ata-kaner.
Before flashing, check the version on the TWRP device page and
record the exact file you flashed.

TODO: verify a downloaded r8q TWRP tar (version, build date, hash)
against the official listing and record it here.

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
   information: model must read **SM-G780G**. The UN1CA donor
   region for this phone is **BTU**.
6. **After any stock flash, boot the phone and complete setup
   before flashing TWRP.** If Download mode shows KG STATUS
   PRENORMAL, Odin refuses to flash anything. Booting and setting
   up the phone first clears it.

## What you need

- A Windows PC with the **Samsung USB Driver** installed (from
  Samsung: developer.samsung.com) and Samsung Smart Switch closed.
- **Odin3 v3.14.1** (the conservative choice). TODO: Odin SHA-256
  not verified for this guide; verify it from the XDA Odin3
  thread before opening it. The r8q All-in-One XDA thread uses
  Odin v3.14.4 instead; we do not recommend a version newer than
  v3.14.4. Odin is Windows-only. On Linux, use Heimdall (the
  twrp.me page gives `heimdall flash --RECOVERY recovery.img`)
  or `samloader-rs flash`, which speaks the same Odin protocol.
  Odin is a leaked internal tool, not officially distributed by
  Samsung, and its binary is never committed to our repos.
- A **patched vbmeta tar** for r8q, linked from the official XDA
  TWRP thread below. A disabled vbmeta is needed before Odin will
  flash anything unofficial.
- The **TWRP tar** for r8q, from the official TWRP device page or
  the XDA thread "[RECOVERY][OFFICIAL][EXTERNAL SD][SNAPDRAGON]
  TWRP 3.7.1_12-2 for Samsung Galaxy S20 FE 4G/5G":
  https://xdaforums.com/t/recovery-official-external-sd-snapdragon-twrp-3-7-1_12-2-for-samsung-galaxy-s20-fe-4g-5g.4646593/
- No multidisabler. See "Official build" above.

## Steps

1. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
2. Open Odin **as administrator**. The `ID:COM` box turns blue and
   shows `Added!` when the phone is detected. If nothing appears,
   the driver, cable, or port is the problem. Do not proceed.
3. Load the **TWRP tar in the AP slot** and the **patched vbmeta
   tar in the USERDATA slot**, as the official XDA thread
   prescribes, and click Start. Wait for PASS.
   Note: putting vbmeta on the USERDATA slot is unusual. The
   older unofficial r8q TWRP thread instead flashes
   `vbmeta_disabled.tar` in the AP slot. The official thread's
   USERDATA route is the one written here because it is the
   official thread's own instruction. TODO: confirm by a real
   Odin run which slot the patched vbmeta needs on this phone.
4. **The moment Odin shows PASS, boot straight into recovery. Do
   not let the phone boot to system.** While the phone is still
   plugged into the PC, hold **Volume Up + Power** until the TWRP
   logo appears. The USB cable must stay connected for the key
   combo to work. If the phone boots to system first, stock
   recovery gets restored and you have to flash TWRP again. TWRP
   disables that restore on its first boot.
5. **Format Data:** Wipe, Format Data, type `yes`. This is a
   format, not a wipe. It removes encryption so TWRP and the ROM
   can use /data.
6. Reboot, System for a stock boot, or stay in TWRP for the next
   flash (root, GSI, UN1CA, or kernel).

## Verify

- Reboot to recovery (power off, hold Volume Up + Power with the
  USB cable connected). TWRP **3.7.1_12-2** opens. The version is
  shown on the main screen.
- In TWRP, /data mounts and Format Data completed without errors.

## Keeping TWRP: the rules

- A full stock AP flash **replaces TWRP** with stock recovery
  (the stock AP tar contains `recovery.img`). TODO: confirm by
  listing the contents of the r8q AP tar before relying on this;
  it is the standard Samsung layout. To keep TWRP, either remove
  `recovery.img` from the AP tar before flashing (advanced:
  re-pack the tar and recompute the trailing MD5; the `.md5`
  suffix is only a checksum footer, not a signature), or flash
  stock and then **immediately re-flash TWRP before the first boot
  into system** (steps 1 to 4 above, then boot straight into
  recovery).
- Never let a ROM's own updater touch recovery. Do not check any
  "update recovery on first boot" box.
- After any stock flash, re-flash TWRP before doing custom work
  again, and take a fresh TWRP backup (including EFS) once the
  phone is back on stock.
- /data decryption inside TWRP is **not available on the official
  build**: decryption support was removed, and the build cannot
  decrypt stock firmware. Keep your real backups on the system
  side, or on an external SD card (the thread title notes
  external SD support).
- This phone uses dynamic partitions (super partition). TWRP
  will not allow modifications to the individual partitions that
  make up super on the stock ROM; backups and restores cover the
  full super partition, and flashing individual partitions needs
  fastbootd.

## Troubleshooting

- **Odin does not see the phone.** Reinstall the Samsung USB
  Driver, try another port (on the PC itself, not a hub) and
  another data cable. Confirm the phone is in Download mode, not
  just charging.
- **"Only official released binaries are allowed to be flashed
  (vbmeta)".** KG STATUS is PRENORMAL, or no disabled vbmeta was
  flashed. Boot the phone, complete setup, and retry with the
  patched vbmeta tar. Do not try to flash an older firmware to
  get around it: the bootloader anti-rollback will refuse it.
- **TWRP is gone after a boot.** You booted to system first.
  Re-flash from step 1 and boot straight to recovery this time,
  with the USB cable still connected.
- **Cannot boot into recovery after flashing.** Keep the USB cable
  connected to the PC when doing the Volume Up + Power combo.
  Without it the combo does not work on this phone.
- **Stuck on the Samsung logo after flashing.** Boot into recovery
  and Format Data again.
- **TWRP asks for a password or cannot mount /data.** That is the
  removed decryption support. Format Data (step 5) removes
  encryption. If you need the data on /data, stop: back it up from
  the running system first, then format.

## Next step

Root the phone: [root.md](root.md). Or flash something:
[flash-stock.md](flash-stock.md),
[flash-gsi.md](flash-gsi.md), [flash-un1ca.md](flash-un1ca.md),
[flash-kernel.md](flash-kernel.md).

## Sources

- Official TWRP device page for r8q (status Current, maintainer
  ata-kaner, dynamic partitions, decryption removed 2024-10-20,
  prebuilt image from G780GXXSBEXG1, Heimdall method):
  https://test.twrp.me/samsung/samsunggalaxys20fe.html
- Official XDA TWRP thread 3.7.1_12-2 (AP + USERDATA slots, boot
  straight to recovery with cable connected, KG PRENORMAL rule,
  multidisabler dropped, decryption limits):
  https://xdaforums.com/t/recovery-official-external-sd-snapdragon-twrp-3-7-1_12-2-for-samsung-galaxy-s20-fe-4g-5g.4646593/
- Unofficial XDA TWRP thread (vbmeta_disabled.tar in AP slot,
  multidisabler terminal command, Format Data, supported models
  including G780G):
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-s20-fe-5g-snapdragon.4188991
- Device tree: https://github.com/TeamWin/android_device_samsung_r8q
