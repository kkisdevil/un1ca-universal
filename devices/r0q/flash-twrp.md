# Flash TWRP - Galaxy S22 (SM-S901E)

Flash the custom recovery on the SM-S901E and keep it. This file
is for the Galaxy S22 (Snapdragon), codename `r0q`, models
SM-S901E, SM-S901N, and SM-S9010 only. Do not use it on the Exynos
Galaxy S22 (SM-S901B, codename `r0s`) or on the Galaxy S22 Ultra
(SM-S908x, codename `b0q`).

## What TWRP is

TWRP is a custom recovery: the menu you boot into to install zips,
make backups, and wipe. Everything in this repo is flashed through
it.

## What TWRP is on this device: unofficial only

There is **no official TWRP for r0q**. No twrp.me device page for
the Galaxy S22 (Snapdragon) exists: the official page that turns
up in search is for the S22 Ultra (`b0q`, maintainer Archer3770,
support status Current). For r0q, TWRP is unofficial, from XDA.

The build to use is **TWRP 3.7.1_12-0** by Archer3770, shared in
the XDA thread "[SHARED] [RECOVERY][UNOFFICIAL] TWRP for Galaxy
S22 (Snapdragon)":
https://xdaforums.com/t/shared-recovery-unofficial-twrp-for-galaxy-s22-snapdragon.4687531/post-89720940
Attachments in that thread: `twrp-3.7.1_12-0-r0q.img.tar`
(53.7 MB), `vbmeta_disabled_R.tar` (11.5 KB), and `cache.img.tar`
(3.5 KB). Supported devices per the thread: S22 SM-S901E (should
also work for S901N/S9010). The older development thread for the
same device is closed:
https://xdaforums.com/t/closed-recovery-unofficial-twrp-for-galaxy-s22-snapdragon.4453811/
(supported models S901E/S901N/S9010, same Odin slot layout).

Two warnings from the XDA threads, stated plainly:

- **TWRP cannot decrypt /data on this device.** A November 2025
  comment on the shared thread says so directly, and the older
  thread lists "Encryption not fully working" as a bug. Treat
  /data decryption as unproven. Format Data (step 7 below) removes
  encryption instead.
- **This build is old** (August 2024) and Android 12 based
  (`_12-0`). A November 2025 comment suggests LineageOS recovery
  may work better than this old build. That is unverified by us.
  If you use LineageOS recovery instead, do not follow this file.

## Verified build

**Not verified by us.** The 3.7.1_12-0 build above is the newest
r0q TWRP named in any XDA thread we found, and it is reported
working by the thread tester, but no image in our hands has been
checked file-by-file against a reference build. Do not treat it
as verified until someone in this project downloads it, records
its hash, and boots it.

## Prereqs

1. **Unlocked bootloader.** Do
   [unlock-bootloader.md](unlock-bootloader.md) first. US models
   (SM-S901U, SM-S901U1, SM-S901W) cannot be unlocked, so they
   cannot run TWRP.
2. **Back up everything** and back up EFS in TWRP if it is already
   installed. Flashing TWRP itself does not wipe data, but the
   Format Data step below does.
3. **Log out of Google and Samsung accounts** before wiping, or
   Factory Reset Protection can lock you out afterwards.
4. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself. No hubs, no front-panel ports.
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-S901E** (or SM-S901N or
   SM-S9010).

## What you need

- A Windows PC with the **Samsung USB Driver** installed (from
  Samsung: developer.samsung.com) and Samsung Smart Switch closed.
- **Odin3 v3.14.1** (2,595,015 B, SHA-256
  `638296a11b1bfa954991b0597214d833511b973480ae9e15e299a761fea1f794`,
  verified against the checksum published by
  https://getodintool.com/, file check November 5, 2026). Verify
  with PowerShell before opening it:
  `Get-FileHash .\Odin3-v3.14.1.zip -Algorithm SHA256`.
  Odin is Windows-only. On Linux, `samloader-rs flash` speaks the
  same Odin protocol, and Heimdall 2.1.0 is another route. Odin is
  a leaked internal tool, not officially distributed by Samsung,
  and its binary is never committed to our repos. Do not use any
  file claiming to be a newer Odin3 than v3.14.4. Odin3 v3.14.4 is
  disputed: the XDA patched-Odin thread states all v3.14.4 builds
  are fake (same filesize as v3.14.1 with an added DLL). We do not
  recommend it. Note that other mirrors repack Odin differently
  and publish different hashes (for example the SamUpdater ZIP is
  1,400,908 B with SHA-256
  `64298cafa5f13a8a4db5134fb8b3f8d5333e469b41e7409c269fa4b61eec6465`):
  always verify against the hash of the exact file you downloaded.
- `vbmeta_disabled_R.tar`: a disabled vbmeta, so the unsigned TWRP
  can boot. Attached to the XDA thread above. It goes in the
  **USERDATA** slot in Odin, per both XDA threads for this device.
- The **TWRP tar** for r0q (`twrp-3.7.1_12-0-r0q.img.tar`), from
  the XDA thread above. It goes in the **AP** slot.
- `cache.img.tar` (3.5 KB, attached to the same thread): loaded in
  the **CSC** slot so the phone boots into recovery automatically
  after the flash, per the shared XDA thread.
- `multidisabler`, run from the TWRP terminal (see step 6). The
  older XDA thread requires it to disable encryption.

## Steps

1. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
2. Open Odin **as administrator**. The `ID:COM` box turns blue and
   shows `Added!` when the phone is detected. If nothing appears,
   the driver, cable, or port is the problem. Do not proceed.
3. Load the **TWRP tar in the AP slot**, `vbmeta_disabled_R.tar`
   in the **USERDATA** slot, and `cache.img.tar` in the **CSC**
   slot, as in the XDA thread. Click Start and wait for PASS.
   (The vbmeta-on-USERDATA layout is unusual, but it is what both
   r0q XDA threads prescribe for this device. Do not move vbmeta
   to the AP slot without a verified reason.)
4. **The moment Odin shows PASS, boot straight into recovery. Do
   not let the phone boot to system.** Hold **Volume Up + Power**
   (with USB connected, per the older XDA thread) until the TWRP
   logo appears. The `cache.img.tar` in CSC should also boot the
   phone into recovery automatically. If the phone boots to system
   first, stock recovery gets restored and you have to flash TWRP
   again.
5. In TWRP, run **`multidisabler`**: Advanced, Terminal, type
   `multidisabler`.
6. **Format Data:** Wipe, Format Data, type `yes`. This is a
   format, not a wipe. It removes encryption so TWRP and the ROM
   can use /data. (TWRP cannot decrypt /data on this device, so
   this step is not optional.)
7. Reboot to recovery again, then reboot to System for a stock
   boot, or stay in TWRP for the next flash (root, GSI, UN1CA, or
   kernel).

## Verify

- Reboot to recovery (power off, hold Volume Up + Power, with USB
  connected). TWRP **3.7.1_12-0** opens. The version is shown on
  the main screen.
- In TWRP, /data mounts after Format Data.

## Keeping TWRP: the rules

- A full stock AP flash **replaces TWRP** with stock recovery (the
  stock AP tar contains `recovery.img`). TODO: confirm
  `recovery.img` is present in an actual r0q AP tar before
  relying on this. To keep TWRP, either remove `recovery.img`
  from the AP tar before flashing (advanced: re-pack the tar and
  recompute the trailing MD5; the `.md5` suffix is only a checksum
  footer, not a signature), or flash stock and then **immediately
  re-flash TWRP before the first boot into system** (steps 2 to 4
  above, then boot straight into recovery).
- Never let a ROM's own updater touch recovery. Do not check any
  "update recovery on first boot" box.
- After any stock flash, re-flash TWRP before doing custom work
  again, and take a fresh TWRP backup (including EFS) once the
  phone is back on stock.
- /data decryption inside TWRP is **not working on this device**
  (see above). Keep your real backups on the system side, not in
  TWRP /data backups.

## Troubleshooting

- **Odin does not see the phone.** Reinstall the Samsung USB
  Driver, try another port (on the PC itself, not a hub) and
  another data cable. Confirm the phone is in Download mode, not
  just charging.
- **TWRP is gone after a boot.** You booted to system first.
  Re-flash from step 2 and boot straight to recovery this time.
- **Stuck on the Samsung logo after flashing.** Boot into recovery
  and wipe metadata from Advanced Wipe (per the older XDA
  thread), then Format Data again.
- **TWRP asks for a password or cannot mount /data.** That is the
  broken /data decryption on this device. Format Data (step 6)
  removes encryption. If you need the data on /data, stop: back it
  up from the running system first, then format.

## Next step

Root the phone: [root.md](root.md). Or flash something:
[flash-stock.md](flash-stock.md),
[flash-gsi.md](flash-gsi.md), [flash-un1ca.md](flash-un1ca.md),
[flash-kernel.md](flash-kernel.md).

## Sources

- TWRP 3.7.1_12-0, files, slots, supported models, /data
  decryption failure: XDA shared thread,
  https://xdaforums.com/t/shared-recovery-unofficial-twrp-for-galaxy-s22-snapdragon.4687531/post-89720940
  (attachments `twrp-3.7.1_12-0-r0q.img.tar` 53.7 MB,
  `vbmeta_disabled_R.tar` 11.5 KB, `cache.img.tar` 3.5 KB; AP /
  USERDATA / CSC layout; last edited Aug 18, 2024; /data
  decryption comments Nov 2025)
- Older closed thread, same layout, multidisabler step, metadata
  wipe note:
  https://xdaforums.com/t/closed-recovery-unofficial-twrp-for-galaxy-s22-snapdragon.4453811/
- No official r0q page on twrp.me: the only twrp.me S22 page
  found in search is the S22 Ultra (`b0q`),
  https://TWRP.me/samsung/samsunggalaxyb0q.html (maintainer
  Archer3770, support status Current)
- Odin3 v3.14.1 size and SHA-256: https://getodintool.com/ (file
  check November 5, 2026). SamUpdater repack hash:
  https://samupdater.com/download-latest-odin-flash-tool-v3-14-4/.
  v3.14.4 fake warning: XDA patched-Odin thread,
  https://xdaforums.com/t/3762572
- TODO: no r0q TWRP image has been downloaded, hashed, or booted
  by us. The version, file sizes, and slot layout above come from
  the XDA threads only.
