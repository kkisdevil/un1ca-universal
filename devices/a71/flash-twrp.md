# Flash TWRP - Galaxy A71 (SM-A715F)

Flash the custom recovery on the SM-A715F and keep it. This file
is for the SM-A715F only. Do not use it on any other model. Do not
use it on the Galaxy A71 5G (SM-A716, codename a71xq): that is a
different phone with its own TWRP thread.

## What TWRP is

TWRP is a custom recovery: the menu you boot into to install zips,
make backups, and wipe. Everything in this repo is flashed through
it. Every other procedure in this folder assumes it.

## TWRP on this device: unofficial, by afaneh92

There is **no official TWRP for the A71** (no device page on
twrp.me). The recovery for this phone is unofficial, built by XDA
Senior Member afaneh92:

- XDA thread: "[RECOVERY][UNOFFICIAL] TWRP for Galaxy A71
  (Snapdragon)":
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-a71-snapdragon.4350893/
- Latest build named in the thread: **twrp-3.7.0_11-1_afaneh92-a71**.
  An older build, **twrp-3.6.2_11-3_afaneh92-a71.tar** (32.3 MB), is
  the one attached to the A71 GSI-fix thread (see
  [flash-gsi.md](flash-gsi.md)).
- Known bug in that build, from the GSI-fix thread: "This TWRP
  build's encryption/decryption not fully working. Make sure your
  device storage is already decrypted, as formatting data will not
  decrypt your device storage."

**TODO: no TWRP image has been verified by us.** Nobody on this
project has downloaded an a71 TWRP image and checked it
file-by-file (version, fingerprint, build date, build host) the
way the m51 image was checked. Do not present any a71 TWRP build
as verified until that check is done.

**Warning that changes the UN1CA plan:** the UN1CA installer for
this device **refuses afaneh92's recovery** (see
[flash-un1ca.md](flash-un1ca.md)). That is the only TWRP found
for this phone. Which recovery to flash UN1CA from is unresolved.
Do not flash UN1CA until that is settled.

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
   information: model must read **SM-A715F**.

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
  it. Note: the droidwin.com A71 guide uses Odin3 v3.14.4. We
  still recommend v3.14.1 for the reasons above.
- `vbmeta_disabled.tar`: a disabled vbmeta, so the unsigned TWRP
  and GSI can boot. Attached to the XDA TWRP thread above.
- The **TWRP tar** for a71, from the XDA thread above.
- `multidisabler` (by ianmacd), named in the same thread. It stops
  stock from re-encrypting or re-locking things after the flash.

## Steps

1. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
2. Open Odin **as administrator**. The `ID:COM` box turns blue and
   shows `Added!` when the phone is detected. If nothing appears,
   the driver, cable, or port is the problem. Do not proceed.
3. Load `vbmeta_disabled.tar` in the **AP slot** and flash it.
   Wait for PASS. (Some A71 guides put a vbmeta file on the
   USERDATA slot. That is unusual and unverified. Do not copy it.
   The AP slot is the route the A71 TWRP and GSI-fix threads use.)
4. Load the **TWRP tar in the AP slot** and flash it. Wait for
   PASS.
5. **The moment Odin shows PASS, boot straight into recovery. Do
   not let the phone boot to system.** Hold **Volume Up + Power**
   until the TWRP logo appears. (On this device the XDA guides
   say to keep the USB cable connected while doing this.) If the
   phone boots to system first, stock recovery gets restored and
   you have to flash TWRP again.
6. In TWRP, run **`multidisabler`**: Advanced, Terminal, type
   `multidisabler`. If it complains about free space on vendor,
   run it again until it prints `Finished.`
7. **Format Data:** Wipe, Format Data, type `yes`. This is a
   format, not a wipe. It removes encryption so TWRP and the ROM
   can use /data.
8. Reboot, System for a stock boot, or stay in TWRP for the next
   flash (root, GSI, UN1CA, or kernel).

## Verify

- Reboot to recovery (power off, hold Volume Up + Power). TWRP
  opens. The version is shown on the main screen: it should read
  3.7.0_11-1 (or whichever build you flashed).
- In TWRP, /data mounts and Format Data completed without errors.

## Keeping TWRP: the rules

- A full stock AP flash **replaces TWRP** with stock recovery
  (the stock AP tar contains `recovery.img` on Samsung firmware
  of this era). **TODO: confirm by listing the a71 AP tar**
  (`tar -tf AP_...tar.md5 | grep recovery`) before relying on
  this. To keep TWRP, either remove `recovery.img` from the AP
  tar before flashing (advanced: re-pack the tar and recompute
  the trailing MD5; the `.md5` suffix is only a checksum footer,
  not a signature), or flash stock and then **immediately
  re-flash TWRP before the first boot into system** (steps 2 to
  5 above, then boot straight into recovery).
- Never let a ROM's own updater touch recovery. Do not check any
  "update recovery on first boot" box. On Samsung phones that flow
  is broken and will cost you a re-flash through Odin.
- After any stock flash, re-flash TWRP before doing custom work
  again, and take a fresh TWRP backup (including EFS) once the
  phone is back on stock.
- /data decryption inside TWRP (FBE) is **unproven on this
  device**. The GSI-fix thread lists encryption as not fully
  working in this TWRP build. Test a /data backup before relying
  on it. Keep your real backups on the system side.
- Do **not** follow the vbmeta-on-USERDATA variant that appears
  in some A71 guides. It puts a vbmeta image on the userdata
  partition, which is unusual and unverified. The AP-slot route
  above is the one the A71 TWRP and GSI-fix threads use.

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
  unproven FBE decryption in this build. Format Data (step 7)
  removes encryption. If you need the data on /data, stop: back
  it up from the running system first, then format.
- **The phone boots to system after the TWRP flash even though
  you held the keys.** Keep the USB cable connected while holding
  Volume Up + Power, and release Power (not Volume Up) when the
  warning appears. If it still boots to system, re-flash from
  step 2.

## Next step

Root the phone: [root.md](root.md). Or flash something:
[flash-stock.md](flash-stock.md),
[flash-gsi.md](flash-gsi.md), [flash-un1ca.md](flash-un1ca.md),
[flash-kernel.md](flash-kernel.md).

## Sources

- TWRP unofficial, by afaneh92, latest named build
  twrp-3.7.0_11-1_afaneh92-a71: XDA thread "[RECOVERY]
  [UNOFFICIAL] TWRP for Galaxy A71 (Snapdragon)",
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-a71-snapdragon.4350893/
- twrp-3.6.2_11-3_afaneh92-a71.tar (32.3 MB), encryption bug,
  vbmeta in AP slot, multidisabler run twice: XDA thread "[ROM
  FIX] [GSI FIX] Fix for the widespread A71 problem of not being
  able to flash GSI",
  https://xdaforums.com/t/rom-fix-gsi-fix-fix-for-the-widespread-a71-problem-of-not-being-able-to-flash-gsi-gsi-wont-boot-after-flashing-gsi-boots-into-fastboot-mode.4513209/
- vbmeta on the USERDATA slot in some A71 guides: getdroidtips.com
  "Download TWRP Recovery for Samsung Galaxy A71 5G" (a71xq
  guide, same pattern). Not followed: unverified.
- No official TWRP: twrp.me has no A71 device page (the guessed
  URL 404s).
- Odin v3.14.1 SHA-256: the XDA Odin3 thread (same binary as the
  m51 record; the hash is a property of the Odin release, not of
  any phone). Odin3 v3.14.4 in the droidwin.com A71 guide.
