# Flash the stock ROM - Galaxy A71 (SM-A715F)

Flash the official Samsung firmware on the SM-A715F. This file is
for the SM-A715F only. Do not use it on any other model. Do not
use it on the Galaxy A71 5G (SM-A716, codename a71xq): that is a
different phone with its own firmware.

## When to use this

- The phone is bricked or bootlooping and TWRP cannot fix it.
- You want a known-good base before unlocking, rooting, flashing
  a GSI, or flashing UN1CA.
- You want to undo a bad flash and go back to stock.
- You want to undo a custom ROM entirely.

A stock flash **removes root, any custom ROM, and TWRP** (see
"Keeping TWRP" below). It does **not** untrip Knox: once Knox is
tripped it stays tripped.

## What you are flashing

| Field | Value |
|---|---|
| Model / region | SM-A715F, OXM multi-CSC (the UN1CA target region is ROM, which is in OXM) |
| PDA / AP | A715FXXSBDXB1 |
| Modem / CP | A715FXXSBDXB1 |
| CSC | A715FOXMBDXB1 (OXM package) |
| Build number | TODO: the exact build-number string (for example TP1A...) was not recorded for this build |
| Android / One UI | Android 13, One UI 5.1, patch 2024-02-01, changelist 27100863 |
| Build date | 2024-02-29 (XEF build; XSG build date 2024-03-05) |
| Bootloader | 11 (Samfw "BIT B"). After flashing this build you cannot flash any firmware with a lower bootloader. |
| Server file | TODO: the exact server filename and byte size were not recorded. The full firmware zip has not been downloaded or verified by us. |
| MD5 | `3b12a176188a7e605456c7efd7cb378d` (OXM package, 6.5 GB) |
| SHA-256 | TODO: not published by the listing and not verified by us. Download via samloader-rs and verify, the way the m51 DXJ1 record was made. |

The OXM package is the same file for every OXM region (XEF, SER,
NEE, XEH, SEB all share MD5 `3b12a176188a7e605456c7efd7cb378d`).
The XSG (United Arab Emirates) package is a different file:
CSC A715FOJMBDXB1, MD5 `f0b5e5bae103136ba481781a1736cc16`, 5.77 GB.
Use the package for your region. Flashing another region's
firmware changes the CSC (preloaded apps, carrier settings, and
sometimes the build number).

**Is this the latest official firmware?** A715FXXSBDXB1 is the
latest build found on Samfw and SamMobile as of 2026-11-25:
Android 13, patch 2024-02-01. Earlier builds: A715FXXU8DWC2
(build 2023-03-20; ZTM Brazil MD5
`06559e7b34de7e95385a357e4271b6b5`, 5.74 GB; COM Colombia MD5
`83e0b2339c593719bd8370a48e2b6e91`, 5.87 GB) and A715FXXU8DWB5
(build 2023-02-23; XEF/XEZ/CAU share MD5
`6590e684d2a937806955eccbe8124980`, 6.32 GB). No DWD/DWE/DWF
builds were found. The A71's last official Android is 13 / One UI
5.1. No file has been downloaded or verified by us: the values
above come from the Samfw/SamMobile listings, not from a local
download.

**Where is the file?** Download it from Samsung's servers with
samloader-rs (no IMEI needed) or from Samfw/SamMobile. There is
**no Drive mirror** for the a71 firmware. TODO: download the DXB1
zip, verify MD5/SHA-256, and mirror it to Drive the way the m51
DXJ1 firmware was mirrored.

## Prereqs

1. **Back up everything** and back up EFS in TWRP if it is
   already installed. A stock flash with the CSC file wipes data.
2. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself. No hubs, no front-panel ports.
3. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A715F**. Do not flash this
   on any other model.
4. A Windows PC with the **Samsung USB Driver** installed (from
   Samsung: developer.samsung.com) and Samsung Smart Switch
   closed. **Odin3 v3.14.1** (2,595,015 B, SHA-256
   `638296a11b1bfa954991b0597214d833511b973480ae9e15e299a761fea1f794`,
   from the XDA Odin3 thread or https://getodintool.com/). Verify
   with PowerShell before opening it:
   `Get-FileHash .\Odin3-v3.14.1.zip -Algorithm SHA256`.
   Odin is Windows-only. On Linux, `samloader-rs flash` speaks
   the same Odin protocol. Odin is a leaked internal tool, not
   officially distributed by Samsung, and its binary is never
   committed to our repos. Do not use any file claiming to be a
   newer Odin3 than v3.14.4. Odin3 v3.14.4 is disputed (same
   compile date as v3.14.1, older DLL, an unsigned DLL no
   component references, four different ZIPs circulating). We do
   not recommend it. Note: the droidwin.com A71 guide uses
   Odin3 v3.14.4. We still recommend v3.14.1 for the reasons
   above.
5. The **stock firmware zip** (see the table above).

## The files in the firmware zip

The zip extracts to five `.tar.md5` files (verify the exact
filenames for the DXB1 package before flashing; the names below
are the standard Samsung pattern):

- `BL_A715FXXSBDXB1_...tar.md5`  -  Bootloader. **BL slot.**
- `AP_A715FXXSBDXB1_...tar.md5`  -  Android system. **AP slot.**
- `CP_A715FXXSBDXB1_...tar.md5`  -  Modem. **CP slot.**
- `CSC_...tar.md5`  -  CSC, **wipes data**. **CSC slot.**
- `HOME_CSC_...tar.md5`  -  CSC, **keeps data**. **CSC slot.**

The CP file is the modem. It is in the same package as the AP.
**TODO: the exact five filenames for the DXB1 package have not
been verified by us** (the AP child file name is known from
Samfw; the BL/CP/CSC/HOME_CSC names follow the standard pattern
but were not listed).

## Steps

1. Extract the firmware zip to the five `.tar.md5` files.
2. Boot into Download mode: power off, hold **Volume Up +
   Volume Down**, connect USB, press **Volume Up** at the
   warning.
3. Open Odin **as administrator**. The `ID:COM` box turns blue
   and shows `Added!` when the phone is detected. If nothing
   appears, the driver, cable, or port is the problem. Do not
   proceed.
4. Load BL, AP, CP, and CSC (or HOME_CSC) into their slots.
   **CSC wipes data. HOME_CSC keeps data.** Use CSC for a clean
   install (the right choice when going back to stock from a
   custom ROM), HOME_CSC when you only want to repair the system
   and keep your data.
5. Make sure **Auto Reboot** and **F. Reset Time** are ticked and
   **Re-Partition is UNticked**. Never tick Re-Partition.
6. Press Start. Wait for the MD5 check to finish, then for the
   flash, then for **PASS**.
7. The phone reboots. First boot after a full stock flash takes
   a few minutes. Let it finish.
8. Check Settings, About phone: the build number should match
   the firmware you flashed. Make a call and check signal.

## Verify

- Settings, About phone: the build number matches the firmware
  you flashed.
- Mobile signal works, calls work, data works.
- Wi-Fi connects.
- The phone reports the right region (CSC) in Settings.

## Keeping TWRP through a stock flash

A full stock AP flash **replaces TWRP** with stock recovery (the
stock AP tar contains `recovery.img` on Samsung firmware of
this era). **TODO: confirm by listing the a71 AP tar**
(`tar -tf AP_...tar.md5 | grep recovery`) before relying on
this. To keep TWRP, either remove `recovery.img` from the AP
tar before flashing (advanced: re-pack the tar and recompute
the trailing MD5; the `.md5` suffix is only a checksum footer,
not a signature), or flash stock and then **immediately
re-flash TWRP before the first boot into system** (see
[flash-twrp.md](flash-twrp.md), then boot straight into
recovery with Volume Up + Power).

## Troubleshooting

- **Odin does not detect the phone.** Reinstall the Samsung USB
  Driver, try another port (on the PC itself, not a hub) and
  another data cable. Confirm the phone is in Download mode.
- **Odin shows FAIL.** Do not panic. Check the Odin log (the
  failure line is at the bottom). Common causes: the wrong
  firmware for the model, or a bad download. Re-download and
  verify the MD5.
- **`SW REV CHECK FAIL` or `SW REV CHECK FAIL (BOOTLOADER)
  DEVICE: 11, BINARY: 8`.** Anti-rollback: the phone has
  bootloader 11 and you tried to flash a build with bootloader
  8 (for example DWC2 or DWB5). You cannot downgrade the
  bootloader. Flash a build with bootloader 11 (DXB1) instead.
- **The phone bootloops or is stuck on the logo after flashing.**
  Boot into stock recovery (power off, hold Volume Up + Power)
  and factory reset. If that does not help, flash again with the
  CSC file (not HOME_CSC) so data is wiped clean.
- **No signal or wrong region features.** You flashed another
  region's firmware. The CSC changed. Flash the firmware for
  your region.
- **TWRP is gone after the flash.** Expected: the stock AP
  replaced it. Re-flash TWRP from
  [flash-twrp.md](flash-twrp.md) before doing custom work again.

## Sources

- Latest build A715FXXSBDXB1 (Android 13, patch 2024-02-01,
  changelist 27100863, built 2024-02-29): sammobile.com
  (XNF/EVR/SER/XXV/NEE/XEF/DTM/XEH/MOT/SEB listings, all
  2026-11-25) and samfw.com,
  https://samfw.com/firmware/SM-A715F/XSG/A715FXXSBDXB1
  (XSG: CSC A715FOJMBDXB1, MD5
  `f0b5e5bae103136ba481781a1736cc16`, 5.77 GB, build date
  20240305134931). OXM MD5
  `3b12a176188a7e605456c7efd7cb378d` shared by SER, NEE, XEF,
  XEH, SEB listings (6.5 GB).
- Earlier builds DWC2 (2023-03-20) and DWB5 (2023-02-23, One UI
  5.1) with MD5s: samfw.com listings, 2026-11-25.
- Bootloader 11: samfw.com XSG listing, field "BIT
  (BINARY/U/SW REV.) B".
- AP child filename pattern:
  `AP_A715FXXSBDXB1_A715FXXSBDXB1_MQB77793475_REV00_user_low_ship_MULTI_CERT_meta_OS13.tar.md5.zip`
  (5.45 GB): samfw.com XSG listing.
- Odin v3.14.1 SHA-256: the XDA Odin3 thread (same binary as the
  m51 record; the hash is a property of the Odin release, not of
  any phone). Odin3 v3.14.4 in the droidwin.com A71 guide.
- A71's last official Android is 13 / One UI 5.1:
  thecustomrom.com "Samsung Galaxy A71 (a71) unofficial
  crDroid 12.14" (Nov 23, 2026) and Samfw listings.
- The stock flash procedure (Download mode keys, Odin slots,
  Re-Partition warning, CSC vs HOME_CSC) is the standard Samsung
  procedure as documented in the m51 record; the a71-specific
  values above are from the Samfw/SamMobile listings.
