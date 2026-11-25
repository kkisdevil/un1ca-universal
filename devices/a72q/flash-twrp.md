# Flash TWRP - Galaxy A72 (SM-A725F)

Flash the custom recovery on the SM-A725F and keep it. This file
is for the SM-A725F only. Do not use it on any other model.

## What TWRP is

TWRP is a custom recovery: the menu you boot into to install zips,
make backups, and wipe. Everything in this repo is flashed through
it. Every other procedure in this folder assumes it.

## Verified build

TWRP is **official** for this device. The latest official build
listed on the TWRP download page is **3.7.1_12-0-a72q**, Android 12
base, dated **2024-02-18 01:55:01 UTC**, 43.6 MB. The tar to flash
with Odin is `twrp-3.7.1_12-0-a72q.img.tar`, with published
checksums:

- MD5: `f287b42416449b23f1068347a9aec252`
- SHA-256: `6af448609ed8a8d9e59e78f0ba973b8d937197fa801599d4ff66c8bcd5845782`

Verify the file against one of those before flashing. The first
official build was 3.5.2_10-0-a72q (2021-05-22, 28.6 MB), from the
XDA thread below.

TODO: this build has not been verified on a live A72 in front of
us. The version, date, size and hashes above are from the official
download listing, not from a phone check. The 3.7.x XDA thread
reports TWRP 3.7 supports Android 11, 12 and 13 on this device,
with encryption support for AOSP and One UI, and notes that
encryption only works on One UI if no lock screen is set. That
claim is from the thread, not from our own test.

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
   information: model must read **SM-A725F**. The upstream target
   firmware is BTU
   (`target/a72q/config.sh` line 8).

## What you need

- A Windows PC with the **Samsung USB Driver** installed (from
  Samsung: developer.samsung.com) and Samsung Smart Switch closed.
- **Odin3 v3.14.1** (2,595,015 B, SHA-256
  `638296a11b1bfa954991b0597214d833511b973480ae9e15e299a761fea1f794`,
  from the XDA Odin3 thread or https://getodintool.com/). Verify
  with PowerShell before opening it:
  `Get-FileHash .\Odin3-v3.14.1.zip -Algorithm SHA256`.
  Odin is Windows-only. On Linux, `samloader-rs flash` speaks the
  same Odin protocol. Odin is a leaked internal tool, not
  officially distributed by Samsung, and its binary is never
  committed to our repos. Do not use any file claiming to be a
  newer Odin3 than v3.14.4. Odin3 v3.14.4 is disputed (same compile
  date as v3.14.1, older DLL, an unsigned DLL no component
  references, four different ZIPs circulating). We do not recommend
  it.
- `vbmeta_disabled.tar`: a disabled vbmeta, so the unsigned TWRP
  can boot. Named in the XDA TWRP thread below.
- The **TWRP tar** for a72q, from the official download page
  https://dl.twrp.me/a72q/ (`twrp-3.7.1_12-0-a72q.img.tar`).
- `multidisabler`, named in the XDA thread. It stops stock from
  re-encrypting or re-locking things after the flash. The 3.5.2
  thread also names a DM Verity Force Disabler zip for avoiding
  reboot issues. TODO: confirm which of these two zips the 3.7.1
  build still needs on Android 14 stock; the thread
  instructions predate the Android 14 firmware.

## Steps

1. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
2. Open Odin **as administrator**. The `ID:COM` box turns blue and
   shows `Added!` when the phone is detected. If nothing appears,
   the driver, cable, or port is the problem. Do not proceed.
3. Load `vbmeta_disabled.tar` in Odin and flash it (AP slot, as in
   the 3.5.2 XDA thread). Wait for PASS. Note: the 3.7 XDA thread
   instead puts the disabled vbmeta in the **USERDATA** slot. That
   is unusual and unverified by us. Do not follow the USERDATA
   variant without verifying it against a real Odin run for this
   device. The AP-slot route is the one this guide uses.
4. In Odin, disable **Auto Reboot**, load the **TWRP tar in the AP
   slot** and flash it. Wait for PASS.
5. **The moment Odin shows PASS, boot straight into recovery. Do
   not let the phone boot to system.** Hold **Volume Up + Power**
   until the TWRP logo appears. If the phone boots to system
   first, stock recovery gets restored and you have to flash TWRP
   again.
6. In TWRP, run **`multidisabler`**: Install, select the zip,
   flash it. (And the DM Verity Force Disabler zip if the
   3.5.2-thread route is being followed; see the TODO above.)
7. **Format Data:** Wipe, Format Data, type `YES`. This is a
   format, not a wipe. It removes encryption so TWRP and the ROM
   can use /data.
8. Reboot, System for a stock boot, or stay in TWRP for the next
   flash (root, GSI, UN1CA, or kernel).

## Verify

- Reboot to recovery (power off, hold Volume Up + Power). TWRP
  **3.7.1_12-0** opens. The version is shown on the main screen.
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
- Never let a ROM's own updater touch recovery. Do not check any
  "update recovery on first boot" box.
- After any stock flash, re-flash TWRP before doing custom work
  again, and take a fresh TWRP backup (including EFS) once the
  phone is back on stock.
- /data decryption inside TWRP: the 3.7 XDA thread claims
  encryption support for One UI, but only with no lock screen set.
  TODO: prove or disprove /data decryption on this device with a
  real backup test before relying on it. Keep real backups on the
  system side.

## Troubleshooting

- **Odin does not see the phone.** Reinstall the Samsung USB
  Driver, try another port (on the PC itself, not a hub) and
  another data cable. Confirm the phone is in Download mode, not
  just charging.
- **TWRP is gone after a boot.** You booted to system first.
  Re-flash from step 2 and boot straight to recovery this time.
- **Stuck on the Samsung logo after flashing.** Boot into recovery
  and Format Data again.
- **TWRP asks for a password or cannot mount /data.** That is the
  encryption support gap. Format Data (step 7) removes
  encryption. If you need the data on /data, stop: back it up from
  the running system first, then format.

## Next step

Root the phone: [root.md](root.md). Or flash something:
[flash-stock.md](flash-stock.md),
[flash-gsi.md](flash-gsi.md), [flash-un1ca.md](flash-un1ca.md),
[flash-kernel.md](flash-kernel.md).

## Sources

- Official TWRP download listing, https://dl.twrp.me/a72q/
  (3.7.1_12-0-a72q, 43.6 MB, 2024-02-18; checksum files
  `twrp-3.7.1_12-0-a72q.img.tar.md5` and `.sha256`, read
  2026-11-25).
- Official TWRP device list, https://twrp.me/Devices/Samsung/
  (lists "Samsung Galaxy A72 4G (a72q)").
- XDA, "[RECOVERY] [OFFICIAL] TWRP 3.5.2 for Galaxy A72 4G":
  https://xdaforums.com/t/recovery-official-twrp-3-5-2-for-galaxy-a72-4g.4278031/
  (flash disabled vbmeta, TWRP tar in AP with Auto Reboot off,
  Format Data, multidisabler, DM Verity Force Disabler).
- XDA, "[RECOVERY][OFFICIAL] TWRP 3.7 for Galaxy A52 4G and A72 4G":
  https://xdaforums.com/t/recovery-official-twrp-3-7-for-galaxy-a52-4g-and-a72-4g.4405751/
  (Android 11/12/13 support, encryption notes, USERDATA-slot
  vbmeta variant, device trees at
  https://github.com/TeamWin/android_device_samsung_a72q).
- Upstream target config:
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/a72q/config.sh
  line 8 (BTU target firmware).
