# Flash TWRP - Galaxy S21 5G (SM-G991B)

Flash the custom recovery on the SM-G991B and keep it. This file
is for the SM-G991B only. Do not use it on any other model.

## WARNING: read this before you pick a recovery

The UN1CA installer for this device **refuses afaneh92's TWRP**
and aborts with E3000 (see
[flash-un1ca.md](flash-un1ca.md)). afaneh92's TWRP is the only
TWRP build documented for this device, and it is the build this
file describes. If your goal is to flash UN1CA, do **not** use
it: the UN1CA XDA thread names **TWRP or OrangeFox** as the
recovery, and which non-afaneh92 build UN1CA accepts on o1s is
TODO: verify the exact recovery build before flashing UN1CA.
If your goal is root or a GSI on stock, afaneh92's TWRP below is
the documented route.

## What TWRP is

TWRP is a custom recovery: the menu you boot into to install zips,
make backups, and wipe. Everything else in this folder is flashed
through it, except where a guide says otherwise.

## Verified build

**There is no official TWRP for this device.** No twrp.me device
page for o1s was found in search on 2026-11-25, and an XDA
report states twrp.me lists no TWRP for this device. TWRP here
is **unofficial only**, by XDA Senior Member afaneh92:

- Thread: "[CLOSED][RECOVERY][UNOFFICIAL] TWRP for Galaxy S21
  (Exynos)",
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-s21-exynos.4241869/
- Supported models: Galaxy S21 SM-G991B/N.
- Versions: 3.5.0 initial release (2021-03-03), 3.5.2_11-3, then
  **3.6.0** (2021-11-29 changelog entry). No newer version is
  recorded in the thread. The thread was closed by a moderator
  (last edited 2025-10-19), and the download link in the opening
  post is shown struck through.
- Known bugs from the opening post: **encryption not fully
  working**, and haptic feedback did not work at launch.
- The build has **not** been verified by us against a reference
  (no file-by-file check, no fingerprint on record). TODO:
  verify the current download location and the hash of the
  TWRP tar before anyone flashes it. BeyondROM v8.4 (2026-02-22)
  still links "S21 TWRP [XDA]", so the XDA thread remains the
  live pointer.

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
   information: model must read **SM-G991B** and the service
   provider software version must show **AUT**.
6. The S21 has **no SD card slot**. Copy zips to internal storage
   or a USB OTG device, not an SD card.

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
  it. (Odin version and hash reused from the m51 docs, which
  verified them; the hash is for the Odin tool itself, not for
  this device.)
- `vbmeta_disabled_R.tar`: a disabled vbmeta, so the unsigned
  TWRP can boot. Named in the XDA TWRP thread below.
- The **TWRP tar** for o1s, from the XDA thread above. TODO:
  exact filename and hash of the current tar.
- `multidisabler` (by ianmacd, credited in the XDA thread). It
  stops stock from re-encrypting or re-locking things after the
  flash. In TWRP it is run from Advanced, Terminal, by typing
  `multidisabler`.

## Steps

These steps follow the XDA thread opening post verbatim, with
the BeyondROM variant noted where it differs.

1. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
2. Open Odin **as administrator**. The `ID:COM` box turns blue and
   shows `Added!` when the phone is detected. If nothing appears,
   the driver, cable, or port is the problem. Do not proceed.
3. Load the **TWRP tar in the AP slot** and
   `vbmeta_disabled_R.tar` in the **USERDATA slot**, then click
   Start. Wait for PASS. Note: this USERDATA-slot vbmeta route is
   the one the XDA opening post prescribes for this device. It
   differs from the usual AP-slot vbmeta route used on other
   devices; do not "correct" it to the AP slot without verifying
   against a real Odin run on this device.
4. **The moment Odin shows PASS, boot straight into recovery. Do
   not let the phone boot to system.** Keep the USB cable
   plugged in, hold **Volume Down + Power** until the screen goes
   black, then immediately hold **Volume Up + Power** until the
   TWRP logo appears. (BeyondROM variant. The XDA post says:
   reboot to recovery via the recovery key combo, Volume Up +
   Power with USB connected.) If the phone boots to system first,
   stock recovery gets restored and you have to flash TWRP again.
5. In TWRP, disable encryption: Advanced, Terminal, type
   **`multidisabler`** and run it.
6. **Format Data:** Wipe, Format Data, type `YES`. This is a
   format, not a wipe. It removes encryption so TWRP and the ROM
   can use /data.
7. Reboot back to recovery, then flash the Magisk APK in TWRP if
   you want root (see [root.md](root.md)).
8. Reboot, System for a stock boot, or stay in TWRP for the next
   flash (root, GSI, UN1CA, or kernel).

## Verify

- Reboot to recovery (power off, connect USB, hold Volume Up +
  Power). TWRP opens. The version is shown on the main screen:
  expect 3.6.0 if you flashed the latest thread build. TODO:
  confirm the exact version string shown.
- In TWRP, /data mounts and Format Data completed without errors.

## Keeping TWRP: the rules

- A full stock AP flash is expected to **replace TWRP** with stock
  recovery, because stock Samsung AP tars contain `recovery.img`.
  TODO: confirm by listing the o1s AP tar contents before
  stating this as verified for this device. If confirmed, the
  keep-TWRP routes are the same as on other Samsung devices:
  either remove `recovery.img` from the AP tar before flashing
  (advanced: re-pack the tar and recompute the trailing MD5; the
  `.md5` suffix is only a checksum footer, not a signature), or
  flash stock and then **immediately re-flash TWRP before the
  first boot into system** (steps 2 to 4 above, then boot straight
  into recovery).
- Never let a ROM's own updater touch recovery. TODO: verify
  whether this device has a broken "update recovery on first
  boot" flow.
- After any stock flash, re-flash TWRP before doing custom work
  again, and take a fresh TWRP backup (including EFS) once the
  phone is back on stock.
- /data decryption inside TWRP is **not fully working** (opening
  post, Bugs section). Do not rely on a /data backup in TWRP.
  Keep your real backups on the system side. Format Data (step 6)
  removes encryption.
- Do **not** follow a vbmeta-on-USERDATA variant from any other
  guide except this device's own XDA opening post. The route
  above is the one this device's thread prescribes.

## Troubleshooting

- **Odin does not see the phone.** Reinstall the Samsung USB
  Driver, try another port (on the PC itself, not a hub) and
  another data cable. Confirm the phone is in Download mode, not
  just charging.
- **TWRP is gone after a boot, stock recovery is back.** You
  booted to system first, or you put the vbmeta tar in the wrong
  slot. Re-flash from step 2 and boot straight to recovery this
  time.
- **Stuck on the Samsung logo after flashing.** Boot into recovery
  and Format Data again.
- **TWRP asks for a password or cannot mount /data.** That is the
  known encryption bug on this build. Format Data (step 6)
  removes encryption. If you need the data on /data, stop: back
  it up from the running system first, then format.
- **Flashing a firmware update without the TWRP vbmeta leaves
  the phone unable to start.** Reported in the XDA thread
  comments: after an Odin firmware update, re-flash TWRP with
  vbmeta disabled or the phone will not start.

## Next step

Root the phone: [root.md](root.md). Or flash something:
[flash-stock.md](flash-stock.md),
[flash-gsi.md](flash-gsi.md), [flash-un1ca.md](flash-un1ca.md),
[flash-kernel.md](flash-kernel.md). If your goal is UN1CA, read
the warning at the top of this file first.

## Sources

- TWRP thread, versions, bugs, steps (AP slot TWRP,
  USERDATA slot vbmeta, multidisabler, Format Data, flash Magisk
  APK): "[CLOSED][RECOVERY][UNOFFICIAL] TWRP for Galaxy S21
  (Exynos)",
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-s21-exynos.4241869/
- TWRP 3.5.0 launch, models SM-G991B/N, haptic and encryption
  bugs: XDA Developers, "TWRP ports are now available for the
  Samsung Galaxy S21, S21 Plus, and S21 Ultra",
  http://www.xda-developers.com/unofficial-twrp-samsung-galaxy-s21-plus-ultra/
- Recovery key combo and Auto Reboot off variant: XDA BeyondROM
  thread,
  https://xdaforums.com/t/rom-beyondrom-v7-5-25-10-2024-gxh7-exynos-sm-g99xb.4254933/page-20
- No official twrp.me page found for o1s in search 2026-11-25;
  XDA report "twrp.me website shows no twrp for such device":
  https://xdaforums.com/t/where-do-i-get-the-twrp-for-samsung-galaxy-s21-sm-g996b.4680427/post-89656203
- afaneh92 TWRP refused by the UN1CA installer (E3000):
  upstream `salvogiangri/UN1CA` branch `sixteen`,
  `target/o1s/installer/assertions.edify`, read live 2026-11-25.
- Odin3 v3.14.1 size and SHA-256: m51 docs
  (`../m51/flash-twrp.md`), verified there for the Odin tool
  itself.
