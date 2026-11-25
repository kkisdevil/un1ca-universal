# Flash the stock ROM - Galaxy S22+ (Snapdragon) (SM-S906E)

Return the Snapdragon Galaxy S22+ (g0q) to official Samsung
firmware with Odin. This file is for **SM-S906E** only (TUR
region, OXM multi-CSC). Do not use it on any other model or
region. SM-S906B is the Exynos model (g0s) and nothing here
applies to it. For other g0q models (SM-S906N, SM-S9060), get
that model's own firmware package; do not flash this one.

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
| Model / region | SM-S906E / **TUR (Turkiye)**, CSC `S906EOXMEGZH4` (OXM multi-CSC) |
| PDA / AP | `S906EXXSEGZH4` |
| Modem / CP | `S906EXXSEGZH4` (CP tar carries modem version CP35959092) |
| Build number | TODO (the previous build GZB6 was `BP2A.250605.031.A3.S906EXXSDGZB6`; the GZH4 build number was not verified) |
| Android / One UI | Android 16 / One UI 8.0, patch 2026-08-05, changelist 31998945 |
| Build date | 2026-08-18 |
| Bootloader | **E (14)**: after this flash, no firmware with a lower bootloader binary will install (anti-rollback) |
| Server file | TODO (the TUR GZH4 zip filename was not verified; the XXV region file for the same build is `SM-S906E_5_20260819224931_zua5zujj3g_fac.zip`) |
| MD5 | TODO |
| SHA-256 | TODO |

This is the latest official firmware for SM-S906E as of the
research date (2026-11-25): build S906EXXSEGZH4, Android 16,
released 2026-09-07 with the August 2026 security patch, seen at
the top of the SamFrew firmware lists for every SM-S906E region
checked. **The TUR-specific zip filename and hashes are still
TODO.** The last fully verified TUR record is the previous build
**GZB6**: PDA `S906EXXSDGZB6`, CSC `S906EOXMDGZB6`, build
`BP2A.250605.031.A3.S906EXXSDGZB6`, built 2026-02-13, patch
2026-02-05, kernel `5.10.236-android12-9-31998796-abS906EXXSDGZB6`,
file `SM-S906E_5_20260215040411_2dgujw8ra0_fac.zip`. Do not flash a
file whose hash does not match. There is no Drive mirror for this
device yet.

## Prereqs

1. **A Windows PC.** Odin is Windows-only. On Linux,
   `samloader-rs flash` speaks the same Odin protocol. That route
   is not covered step-by-step here.
2. **Samsung USB Driver** for mobile phones, installed on the PC
   (from Samsung: developer.samsung.com). Without it Odin will not
   see the phone. Close Samsung Smart Switch before flashing.
3. **Odin3 v3.14.1** (the conservative choice, and the version the
   S22+ root guide uses). SHA-256: TODO (verify from a trusted
   source; do not copy another device's hash). Extract it into its
   own folder and keep the EXE and DLLs together. Run it as
   administrator. Odin is a leaked internal tool, not officially
   distributed by Samsung, and its binary is **never committed to
   our repos**. Do not use any file claiming to be a newer Odin3
   than v3.14.4.
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
   information: model must read **SM-S906E**. Do not flash this
   package on any other model or region.

## The 5 files in the firmware zip

The file entries below come from the firmware record for the
S906EXXSEGZH4 build (XXV region listing; the tar names are the
same across OXM regions, only the zip filename differs). Odin
verifies each file's trailing MD5 before flashing.

| File | Odin slot | What it is |
|---|---|---|
| `BL_S906EXXSEGZH4_S906EXXSEGZH4_MQB113580553_REV00_user_low_ship_MULTI_CERT.tar.md5` (113,469,553 B) | **BL** | Bootloader |
| `AP_S906EXXSEGZH4_S906EXXSEGZH4_MQB113580553_REV00_user_low_ship_MULTI_CERT_meta_OS16.tar.md5` | **AP** | System (largest file; takes minutes to load). Contains `boot.img`, `system.img`, `vendor.img` |
| `CP_S906EXXSEGZH4_CP35959092_MQB113580553_REV00_user_low_ship_MULTI_CERT.tar.md5` | **CP** | Modem / baseband |
| `CSC_OXM_S906EOXMEGZH4_MQB113580553_REV00_user_low_ship_MULTI_CERT.tar.md5` | **CSC** | Region data. **Wipes the phone** (factory reset) |
| `HOME_CSC_OXM_S906EOXMEGZH4_MQB113580553_REV00_user_low_ship_MULTI_CERT.tar.md5` | **CSC** | Same region data. **Keeps your apps and data** |

Load all five files from the **same** package. Never mix files from
different builds or regions. TODO: confirm from a TUR zip that
its five tar names match the ones above, and confirm whether the
g0q AP tar contains `recovery.img`.

## Steps

1. Download the firmware and verify its hashes against the table
   above. Extract the zip. You need the five `.tar.md5` files.
2. Download Odin (v3.14.1 recommended), extract it, verify its
   SHA-256, install the Samsung USB Driver, close Smart Switch.
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
   Software information: build number must read the GZH4 build
   number (TODO in the table above).

## Verify

- Settings, About phone, Software information: build number reads
  the GZH4 build number.
- The phone has signal and the region features match TUR.
- If you flashed CSC (wipe), the phone boots to fresh setup. If
  you flashed HOME_CSC, your apps and data are still there.

## Keeping TWRP through a stock flash

TODO: confirm whether the stock g0q AP tar contains
`recovery.img`. On Samsung phones it normally does, which would
mean a full stock AP flash replaces TWRP. Until that is confirmed
from a g0q AP listing, treat a full stock flash as replacing
TWRP, and use one of these routes if you want to keep it:

1. **Remove recovery from the AP tar (advanced).** Extract the
   AP `.tar.md5`, delete `recovery.img` from the tar, re-pack it
   and recompute the trailing MD5 (the `.md5` suffix is just a
   checksum footer Odin verifies: it is not a signature). Then
   flash the modified AP. The recovery partition is left
   untouched.
2. **Flash stock, then immediately re-flash TWRP.** Flash the
   full stock package, and before the first boot into system,
   flash the TWRP tar via Odin (AP slot). Do not boot into the
   system first. Boot straight into recovery (Volume Up + Power
   with USB connected) after the TWRP flash.

Note: route 2 is blocked today because no working TWRP tar exists
for g0q (see [flash-twrp.md](flash-twrp.md)).

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
  bootloader binary E (14). You cannot flash it over a phone
  already on a newer bootloader binary, and after flashing it you
  cannot go back to a lower binary.
- **Stuck on the Samsung logo or bootloop after flashing.** Boot
  into recovery (Volume Up + Power with USB connected) and wipe
  cache, then factory reset from stock recovery if needed. If it
  still will not boot, re-flash the full package with the **CSC**
  file (wipe).
- **Phone boots but has no signal or wrong region features.** The
  CSC does not match the phone. Re-flash with the correct TUR
  package.
- **TWRP is gone after the flash.** Expected if the AP tar
  contains recovery.img (TODO to confirm). See "Keeping TWRP"
  above. Re-flash the TWRP tar via Odin once a working build
  exists.

## Sources

- Latest build S906EXXSEGZH4 (Android 16, built 2026-08-18, patch
  2026-08-05, changelist 31998945, bootloader binary E (14),
  released 2026-09-07): SamFrew firmware lists,
  https://samfrew.com/firmware/model/SM-S906E/upload/Desc/0/10
  and SamFirm,
  https://samfirm.shop/model/SM-S906E?region=PSP
- TUR GZB6 record (PDA S906EXXSDGZB6, CSC S906EOXMDGZB6, build
  number BP2A.250605.031.A3.S906EXXSDGZB6, file
  SM-S906E_5_20260215040411_2dgujw8ra0_fac.zip, kernel
  5.10.236-android12-9-31998796-abS906EXXSDGZB6, bootloader D
  (13)): SamFrew,
  https://samfrew.com/download/Galaxy__S22+__/47wa/TUR/S906EXXSDGZB6/S906EOXMDGZB6
- Five tar entries for the GZH4 build (BL size 113,469,553 B, AP
  `_meta_OS16` name, CP35959092 modem): firmware record,
  https://www.klikcloud.ru/en/file/88517-firmware-info (XXV
  region listing for the same build).
- Bootloader binary rule (5th character from the end; newer builds
  use binary E (14)): SamFirm build pages, for example
  https://samfirm.shop/build/S906EXXU2AVF1
- Odin3 v3.14.1 and Download mode combo for the S22+: AndroidBiits
  S22+ root guide,
  https://androidbiits.com/root-samsung-galaxy-s22-plus-sm-s906b-sm-s906e-sm-s906n-easily/
- Recovery combo (Volume Up + Power with USB connected): XDA TWRP
  thread,
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-s22-snapdragon.4453813/
  and the S22+ hard-reset guide,
  https://androidbiits.com/hard-reset-samsung-galaxy-s22-plus-sm-s906e-easily/

## TODO

- TUR GZH4 zip filename, MD5, SHA-256, and build number: fetch
  the TUR package (Frija, SamFirm, or SamFrew) and record them.
- Confirm the five tar names from a TUR zip.
- Confirm whether the g0q AP tar contains `recovery.img`.
- Verify the Odin3 v3.14.1 SHA-256 from a trusted source.
- No Drive mirror exists for this device's firmware yet.
