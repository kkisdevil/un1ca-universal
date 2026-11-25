# Flash the stock ROM - Galaxy M52 5G (SM-M526B / SM-M526BR)

Return the SM-M526B / SM-M526BR to official Samsung firmware with
Odin. This file is for the SM-M526B and SM-M526BR only. Do not use
it on any other model.

## When to use this

- Return the phone to stock: unbrick, undo a bad flash, prepare it
  for sale or service.
- Get a known-good base before custom work (UN1CA or HyperOS).
- Fix a bootloop or a broken system when TWRP alone cannot.

Flashing stock firmware **removes root, custom ROMs, and custom
recoveries** (see "Keeping TWRP" below) and **wipes data if you use
the CSC file**. It does **not** untrip Knox. A tripped Knox bit is
permanent, and flashing stock does not restore Samsung Pay or
Secure Folder on a tripped phone.

## What you are flashing

Two model variants exist. Pick the row that matches your phone.
**Never flash one model's firmware on the other model.** The
UN1CA target firmware is the SM-M526BR / BTU variant; the
SM-M526B / INS variant is the usual India model.

| Field | SM-M526B / INS (India) | SM-M526BR / BTU (United Kingdom) |
|---|---|---|
| Model / region | SM-M526B / **INS**, CSC `M526BODM7CYD2` | SM-M526BR / **BTU**, CSC `M526BROXM7CYE1` |
| PDA / AP | `M526BXXS7CYD2` | `M526BRXXS7CYE1` |
| Modem / CP | `M526BXXS7CYD1` (note: the CP file in this package is CYD1, while AP and BL are CYD2) | `M526BRXXS7CYE1` |
| Build date | 2025-04-25 (samfw: 20250425174310) | 2025-05-06 (samfw: 20250506135210; SamMobile lists built 2025-05-05) |
| Android / One UI | Android 13 / One UI 5.1, patch 2025-05-01 | Android 13 / One UI 5.1, patch 2025-05-01 |
| Bootloader | **7**: after this flash, no firmware with bootloader 6 or lower will install (anti-rollback) | **7**: same anti-rollback rule |
| Full file size | 6.55 GB | 6.37 GB |
| Full file MD5 | `3ca09ef2ff847fb4b2b85ffa030a675f` | `955516316bb6715befe4d25cf5ea71d4` |

TODO: the exact build number string (for example the
`TP1A...M526BXXS7CYD2` form) and the changelist for each row were
not in the sources read; record them from the phone (Settings,
About phone, Software information) after flashing, or from the
firmware record, before treating this table as complete. The
server zip filename and its exact byte size are also TODO; only
the samfw listed size and MD5 are recorded above.

These are the latest official firmwares found on samfw for each
region as of 2026-11-25. SamMobile's BTU archive also lists
M526BRXXS7CYE1 as the newest BTU build. Re-check samfw before
downloading: a newer build may have appeared since. Get the file
from samfw (links in Sources) or SamMobile. **Verify the MD5
above before flashing.** Do not flash a file whose hash does not
match. No Drive mirror exists for this device yet.

## Prereqs

1. **A Windows PC.** Odin is Windows-only. On Linux,
   `samloader-rs flash` speaks the same Odin protocol; the
   LineageOS wiki notes the m52xq recovery is flashed with
   samloader-rs from Download mode. That route is not covered
   step-by-step here.
2. **Samsung USB Driver** for mobile phones, installed on the PC
   (from Samsung: developer.samsung.com). Without it Odin will not
   see the phone. Close Samsung Smart Switch before flashing.
3. **Odin3**. The samfw firmware pages' generic instructions name
   Odin Tool 3.13.1. The XDA TWRP thread links Odin3 without
   pinning a version. TODO: record the exact Odin version and its
   SHA-256 from the XDA Odin3 thread before flashing, and verify
   the hash. Odin is a leaked internal tool, not officially
   distributed by Samsung, and its binary is **never committed to
   our repos**.
4. **A good USB data cable** (charge-only cables will not work)
   and a USB port on the PC itself. No hubs, no front-panel ports.
5. **Battery above 50%, ideally full.** A dead phone mid-flash is
   how bricks happen.
6. **Back up.** Copy photos, files, and app data off the phone and
   check you can open the copies. If you use HOME_CSC your data
   should survive, but a backup is not optional.
7. **EFS backup first (TWRP users).** In TWRP, back up the EFS
   partition and keep a copy off the phone before any flashing.
   EFS holds the IMEI and modem calibration. Losing it is very hard
   to recover from.
8. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-M526B** or **SM-M526BR**
   and the service provider software version must show the CSC
   for your region. Do not flash a package for any other model or
   region.

## The 5 files in the firmware zip

Extract the firmware zip. Inside are five `.tar.md5` files. Odin
verifies each file's trailing MD5 before flashing. The exact child
filenames below are from the samfw listings for each build.

SM-M526B / INS, M526BXXS7CYD2:

| File | Odin slot | What it is |
|---|---|---|
| `AP_M526BXXS7CYD2_M526BXXS7CYD2_MQB95444063_REV00_user_low_ship_MULTI_CERT_meta_OS13.tar.md5` (5.84 GB) | **AP** | System (largest file; takes minutes to load). Contains `boot.img`, `recovery.img`, `system.img`, `vendor.img` |
| `BL_M526BXXS7CYD2_M526BXXS7CYD2_MQB95444063_REV00_user_low_ship_MULTI_CERT.tar.md5` (78.17 MB) | **BL** | Bootloader |
| `CP_M526BXXS7CYD1_CP29933498_MQB95329490_REV00_user_low_ship_MULTI_CERT.tar.md5` (54.86 MB) | **CP** | Modem / baseband |
| `CSC_ODM_M526BODM7CYD2_MQB95444063_REV00_user_low_ship_MULTI_CERT.tar.md5` (268 MB) | **CSC** | Region data. **Wipes the phone** (factory reset) |
| `HOME_CSC_ODM_M526BODM7CYD2_MQB95444063_REV00_user_low_ship_MULTI_CERT.tar.md5` (268.01 MB) | **CSC** | Same region data. **Keeps your apps and data** |

SM-M526BR / BTU, M526BRXXS7CYE1:

| File | Odin slot | What it is |
|---|---|---|
| `AP_M526BRXXS7CYE1_M526BRXXS7CYE1_MQB95839104_REV00_user_low_ship_MULTI_CERT_meta_OS13.tar.md5` (5.54 GB) | **AP** | System (largest file; takes minutes to load) |
| `BL_M526BRXXS7CYE1_M526BRXXS7CYE1_MQB95839104_REV00_user_low_ship_MULTI_CERT.tar.md5` (78.17 MB) | **BL** | Bootloader |
| `CP_M526BRXXS7CYE1_CP30134056_MQB95839104_REV00_user_low_ship_MULTI_CERT.tar.md5` (54.86 MB) | **CP** | Modem / baseband |
| `CSC_OXM_M526BROXM7CYE1_MQB95839104_REV00_user_low_ship_MULTI_CERT.tar.md5` (324.77 MB) | **CSC** | Region data. **Wipes the phone** (factory reset) |
| `HOME_CSC_OXM_M526BROXM7CYE1_MQB95839104_REV00_user_low_ship_MULTI_CERT.tar.md5` (324.8 MB) | **CSC** | Same region data. **Keeps your apps and data** |

Load all five files from the **same** package. Never mix files from
different builds or regions.

## Steps

1. Download the firmware for your model and region (links in
   Sources) and verify its MD5 against the table above. Extract
   the zip. You need the five `.tar.md5` files.
2. Download Odin, extract it, verify its SHA-256 (TODO, see
   Prereqs), install the Samsung USB Driver, close Smart Switch.
3. Back up the phone (and EFS via TWRP, if you have it).
4. **Enter Download mode.** Power the phone fully off. Press and
   hold **Volume Up + Volume Down**, then connect the USB cable to
   the PC. A warning screen appears. Press **Volume Up** to
   continue into Download mode.
5. Open Odin **as administrator**. The `ID:COM` box turns blue and
   shows `Added!` in the log when the phone is detected. If
   nothing appears, the driver, cable, or port is the problem. Do
   not proceed.
6. Load the files into their slots: **BL** goes to the BL file,
   **AP** goes to the AP file (takes a few minutes to load: wait
   for the MD5 check to finish), **CP** goes to the CP file,
   **CSC** goes to CSC *or* HOME_CSC (CSC wipes, HOME_CSC keeps
   data).
7. Options: leave **Auto Reboot** and **F. Reset Time** ticked.
   Leave **Re-Partition unticked** (ticking it without a PIT file
   will fail or brick). Do not touch anything else.
8. Click **Start**. Do not unplug the cable, touch the phone, or
   close Odin. The flash takes several minutes. The phone reboots
   by itself when Odin shows **PASS** in green.
9. First boot after a flash can take several minutes. That is
   normal. Set the phone up, then check Settings, About phone,
   Software information: the build number must match the PDA you
   flashed (`M526BXXS7CYD2` or `M526BRXXS7CYE1`).

## Verify

- Settings, About phone, Software information: build number reads
  the PDA you flashed.
- The phone has signal and the region features match your CSC.
- If you flashed CSC (wipe), the phone boots to fresh setup. If
  you flashed HOME_CSC, your apps and data are still there.

## Keeping TWRP through a stock flash

Flashing the full stock AP **replaces TWRP** with the stock
recovery, because the stock AP tar contains `recovery.img`. TODO:
confirm this for the m52xq AP tar by listing the tar contents
before flashing; it has not been checked for this device yet. If
it holds, the rules are:

- **If you want a fully stock phone**, that is expected. Flash
  normally and TWRP is gone. Re-flash TWRP afterwards if you want
  it back (via Odin, AP slot, with the TWRP tar).
- **If you want to keep TWRP**, do NOT flash the stock AP as-is.
  Pick one:
  1. **Remove recovery from the AP tar (advanced).** Extract the
     AP `.tar.md5`, delete `recovery.img` from the tar, re-pack it
     and recompute the trailing MD5 (the `.md5` suffix is just a
     checksum footer Odin verifies: it is not a signature). Then
     flash the modified AP. The recovery partition is left
     untouched.
  2. **Flash stock, then immediately re-flash TWRP.** Flash the
     full stock package, and before the first boot into system,
     flash the TWRP tar via Odin (AP slot). Do not boot into the
     system first. Boot straight into recovery (Volume Up +
     Power, with USB connected) after the TWRP flash.
- **Never** put any file in Odin's slots that writes the recovery
  partition unless you mean to replace TWRP. Check every tar you
  flash for a `recovery.img` entry first.
- After any stock flash, **re-flash TWRP before doing custom work
  again**, and take a fresh TWRP backup (including EFS) once the
  phone is back on stock.

## Troubleshooting

- **Odin does not detect the phone (`ID:COM` stays empty).**
  Reinstall the Samsung USB Driver, try another USB port (on the
  PC itself, not a hub) and another data cable. Make sure the
  phone is actually in Download mode, not just charging.
- **Odin shows FAIL.** Read the exact line where the log stopped.
  Common causes: wrong model or region firmware, a corrupted
  download (re-check the firmware MD5), a bad cable, or the
  battery dying mid-flash. Re-enter Download mode and try again
  with a verified download.
- **`SW REV CHECK FAIL`.** The bootloader in the package is older
  than the one on the phone (anti-rollback). These packages are
  bootloader 7. You cannot flash them over a phone already on a
  newer bootloader, and after flashing one you cannot go back to
  bootloader 6 or lower.
- **Stuck on the Samsung logo or bootloop after flashing.** Boot
  into recovery (Volume Up + Power) and wipe cache, then factory
  reset from stock recovery if needed. If it still will not boot,
  re-flash the full package with the **CSC** file (wipe).
- **Phone boots but has no signal or wrong region features.** The
  CSC does not match the phone. Re-flash with the correct package
  for your model and region.
- **TWRP is gone after the flash.** Expected. See "Keeping TWRP"
  above. Re-flash the TWRP tar via Odin.

## Sources

- samfw, SM-M526B / INS / M526BXXS7CYD2,
  https://samfw.com/firmware/SM-M526B/INS/M526BXXS7CYD2 (PDA,
  CSC M526BODM7CYD2, Android 13, bit 7, 6.55 GB, MD5
  3ca09ef2ff847fb4b2b85ffa030a675f, build date 20250425174310,
  patch 2025-05-01, child filenames and sizes). Read via search
  results 2026-11-25.
- samfw, SM-M526BR / BTU / M526BRXXS7CYE1,
  https://samfw.com/firmware/SM-M526BR/BTU/M526BRXXS7CYE1 (PDA,
  CSC M526BROXM7CYE1, Android 13, bit 7, 6.37 GB, MD5
  955516316bb6715befe4d25cf5ea71d4, build date 20250506135210,
  patch 2025-05-01, child filenames and sizes). Read via search
  results 2026-11-25.
- SamMobile, latest SM-M526BR BTU firmware,
  https://www.sammobile.com/samsung/galaxy-m52/firmware/SM-M526BR/BTU/
  (latest is M526BRXXS7CYE1, Android 13, built 2025-05-05).
  Read via search results 2026-11-25.
- SamFrew, SM-M526B INS page (newer firmware for INS:
  M526BXXS7CYD2, Apr 24, 2025), corroborates the INS latest.
  Read via search results 2026-11-25.
- deviceinfo.app Galaxy M52 5G page,
  https://www.deviceinfo.app/devices/samsung/galaxy-m52-5g/
  (newest Android seen Android 13 / One UI 5.1, newest patch May
  2025). Read via search results 2026-11-25.
- Odin Tool 3.13.1 named in the samfw firmware pages' generic
  install instructions. Odin version and SHA-256 for this device
  are TODO, as noted above.
