# Flash the stock ROM - Galaxy S22 Ultra (SM-S908E)

Return the Galaxy S22 Ultra (Snapdragon), codename `b0q`, to
official Samsung firmware with Odin. This file is for the
SM-S908E only. Do not use it on any other model. The other
Snapdragon S22 Ultra models (SM-S908N, SM-S9080) use their own
firmware; the Exynos model (SM-S908B) is a different phone.

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

| Field | Value |
|---|---|
| Model / region | SM-S908E / **INS (India)**, CSC `S908EOXMEGZH4` |
| PDA / AP | `S908EXXSEGZH4` |
| Modem / CP | `S908EXXSEGZH4` |
| Build number | `BP2A.250605.031.A3.S908EXXSEGZH4` |
| Android / One UI | Android 16 / One UI 8.0, patch 2026-08-05, changelist 31998945 |
| Build date | 2026-08-18 |
| Bootloader | **E (14)**: after this flash, no firmware with bootloader D (13) or lower will install (anti-rollback) |
| Server file | TODO: exact server filename and byte size |
| MD5 | TODO |
| SHA-256 | TODO |

This is the latest official firmware for INS as of 2026-11-25,
per the SamFrew INS firmware list (newer than the January 2026
`S908EXXSCGZA2` build, bootloader C (12)). The bootloader letter
E (14) is read from the version string: SamFrew records C as 12
for `S908EXXSCGZA2` and D as 13 for `S908EXXSDGZB6`, so the E in
`S908EXXSEGZH4` is 14. **The file itself has not been downloaded
or verified by us.** Get it from SamFrew
(https://samfrew.com/firmware/model/SM-S908E/region/INS/upload/Desc/0/10)
or from Samsung's own servers, and **verify its hashes before
flashing**. Do not flash a file whose hash does not match. There
is no firmware record doc for this device yet.

For reference, the fully detailed earlier INS build is
`S908EXXSCGZA2` (One UI 8.0, Android 16, patch 2026-01-01, built
2026-01-13, changelist 31998945, bootloader C (12), CSC
`S908EOXMCGZA2`, build number
`BP2A.250605.031.A3.S908EXXSCGZA2`, kernel
`5.10.236-android12-9-31998796-abS908EXXSCGZA2`, server file
`SM-S908E_5_20260114205611_m3ocl6yk2k_fac.zip`).
Source: https://samfrew.com/download/Galaxy__S22__Ultra__/45va/INS/S908EXXSCGZA2/S908EOXMCGZA2

## Prereqs

1. **A Windows PC.** Odin is Windows-only. On Linux,
   `samloader-rs flash` speaks the same Odin protocol. That route
   is not covered step-by-step here.
2. **Samsung USB Driver** for mobile phones, installed on the PC
   (from Samsung: developer.samsung.com). Without it Odin will not
   see the phone. Close Samsung Smart Switch before flashing.
3. **Odin3.** TODO: record the Odin version and SHA-256 verified
   from a trusted source for this device. The S22 Ultra guides
   name Odin3 v3.14.4, but no hash for it has been verified here.
   Do not copy another device's hash. Verify before opening it,
   in PowerShell:
   `Get-FileHash .\Odin3-v3.14.4.zip -Algorithm SHA256` (once the
   expected hash is recorded). Extract it into its own folder and
   keep the EXE and DLLs together. Run it as administrator. Odin
   is a leaked internal tool, not officially distributed by
   Samsung, and its binary is **never committed to our repos**.
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
   information: model must read **SM-S908E** and the service
   provider software version must show **INS**. Do not flash this
   package on any other model or region.

## The 5 files in the firmware zip

Extract the firmware zip. Inside are five `.tar.md5` files. Odin
verifies each file's trailing MD5 before flashing. TODO: confirm
the exact filenames once the `S908EXXSEGZH4` zip is downloaded;
the table below is the standard Samsung layout for this build.

| File | Odin slot | What it is |
|---|---|---|
| `BL_S908EXXSEGZH4_...tar.md5` | **BL** | Bootloader |
| `AP_S908EXXSEGZH4_...tar.md5` | **AP** | System (largest file; takes minutes to load). Contains `boot.img`, `recovery.img`, `system.img`, `vendor.img` |
| `CP_S908EXXSEGZH4_...tar.md5` | **CP** | Modem / baseband |
| `CSC_OXM_S908EOXMEGZH4_...tar.md5` | **CSC** | Region data. **Wipes the phone** (factory reset) |
| `HOME_CSC_OXM_S908EOXMEGZH4_...tar.md5` | **CSC** | Same region data. **Keeps your apps and data** |

Load all five files from the **same** package. Never mix files from
different builds or regions.

## Steps

1. Download the firmware (SamFrew link above) and verify its
   hashes against the table above. Extract the zip. You need the
   five `.tar.md5` files.
2. Download Odin, extract it, verify its SHA-256, install the
   Samsung USB Driver, close Smart Switch.
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
   Software information: build number must read
   `BP2A.250605.031.A3.S908EXXSEGZH4`.

## Verify

- Settings, About phone, Software information: build number reads
  `BP2A.250605.031.A3.S908EXXSEGZH4`.
- The phone has signal and the region features match INS.
- If you flashed CSC (wipe), the phone boots to fresh setup. If
  you flashed HOME_CSC, your apps and data are still there.

## Keeping TWRP through a stock flash

Flashing the full stock AP **replaces TWRP** with the stock
recovery, because the stock AP tar contains `recovery.img`. This
is the one rule that matters most.

- **If you want a fully stock phone**, that is expected. Flash
  normally and TWRP is gone. Re-flash TWRP afterwards if you want
  it back (via Odin, AP slot, with the TWRP tar, plus the disabled
  vbmeta in the USERDATA slot: see
  [flash-twrp.md](flash-twrp.md)).
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
     flash the TWRP tar via Odin (AP slot, vbmeta in USERDATA).
     Do not boot into the system first. Boot straight into
     recovery (Volume Up + Power, with USB connected) after the
     TWRP flash.
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
  download (re-check the firmware hashes), a bad cable, or the
  battery dying mid-flash. Re-enter Download mode and try again
  with a verified download.
- **`SW REV CHECK FAIL`.** The bootloader in the package is older
  than the one on the phone (anti-rollback). This GZH4 package is
  bootloader E (14). You cannot flash it over a phone already on
  a newer bootloader, and after flashing it you cannot go back to
  bootloader D (13) or lower.
- **Stuck on the Samsung logo or bootloop after flashing.** Boot
  into recovery (Volume Up + Power, with USB connected) and wipe
  cache, then factory reset from stock recovery if needed. If it
  still will not boot, re-flash the full package with the **CSC**
  file (wipe).
- **Phone boots but has no signal or wrong region features.** The
  CSC does not match the phone. Re-flash with the correct INS
  package.
- **TWRP is gone after the flash.** Expected. See "Keeping TWRP"
  above. Re-flash the TWRP tar via Odin.

## Sources

- Latest INS firmware (`S908EXXSEGZH4`, CSC `S908EOXMEGZH4`,
  patch 2026-08-05, built 2026-08-18, changelist 31998945):
  SamFrew INS firmware list
  https://samfrew.com/firmware/model/SM-S908E/region/INS/upload/Desc/0/10
  and S-Update
  https://s-update.samsungvn.com/devices/SM-S908E
- Full detail record for the earlier `S908EXXSCGZA2` build
  (PDA/CSC/modem, build number, kernel, server filename,
  bootloader C (12), GZB6 bootloader D (13)):
  https://samfrew.com/download/Galaxy__S22__Ultra__/45va/INS/S908EXXSCGZA2/S908EOXMCGZA2
- Odin slot layout and CSC vs HOME_CSC: SamFrew install guide on
  the same page, and the standard Samsung firmware layout.
- Server filename, MD5, SHA-256 for `S908EXXSEGZH4`, and the
  Odin version and hash: TODO, pending a firmware download.
