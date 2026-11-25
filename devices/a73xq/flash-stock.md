# Flash the stock ROM - Galaxy A73 5G (SM-A736B)

Return the SM-A736B to official Samsung firmware with Odin. This
file is for the SM-A736B only. Do not use it on any other model.

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
| Model / region | SM-A736B / **XME (Malaysia)**, CSC `A736BOLMCGZK3` |
| PDA / AP | `A736BXXSCGZK3` |
| Modem / CP | `A736BXXSCGZK3` |
| Build number | `BP2A.250605.031.A3.A736BXXSCGZK3` |
| Android / One UI | Android 16 / One UI 8.0, patch 2026-11-05, changelist 32144845 |
| Build date | 2026-11-09 |
| Bootloader | **C (12)**: after this flash, no firmware with bootloader 11 or lower will install (anti-rollback) |
| Server file | `SM-A736B_5_20261111014000_xdnr6nmbid_fac.zip` (10.3 GB ZIP, per SamFrew) |
| MD5 | TODO (not published on the SamFrew page read) |
| SHA-256 | TODO (not published on the SamFrew page read) |

This is the latest official firmware for XME found on 2026-11-25:
SamFrew lists CGZK3 (build 2026-11-09, upload 2026-11-18, patch
2026-11-05) as the current XME build, newer than the earlier
GZB2 build (patch 2026-02-05, MD5
`dfaf3164926c476c67c4fc2dcdc1ef40`, which is **not** the latest
and must not be flashed as if it were). The kernel in this build
is `5.4.289-qgki-32200428-abA736BXXSCGZK3`, and the vendor base
is Android 11. The file has not been downloaded or hash-checked
in this project; **verify the hashes before flashing** once you
have a source that publishes them. There is no firmware record
doc or Drive mirror for this phone in this project yet.

Note on regions: the UN1CA target firmware for this phone is also
XME (`SM-A736B/XME/352828291234563`), so XME is the region this
folder tracks. If your phone is a different region, download that
region's build instead and do not use the table above. A SamMobile
listing for XME shows an older build, A736BXXSAGZA1 (patch
2026-01-01); CGZK3 supersedes it.

## Prereqs

1. **A Windows PC.** Odin is Windows-only. On Linux,
   `samloader-rs flash` speaks the same Odin protocol; the
   LineageOS wiki for a73xq documents flashing firmware with
   samloader-rs. That route is not covered step-by-step here.
2. **Samsung USB Driver** for mobile phones, installed on the PC
   (from Samsung: developer.samsung.com). Without it Odin will not
   see the phone. Close Samsung Smart Switch before flashing.
3. **Odin3 v3.14.1** (the conservative choice used in the a73xq
   guides). Extract it into its own folder and keep the EXE and
   DLLs together. Run it as administrator. Odin is a leaked
   internal tool, not officially distributed by Samsung, and its
   binary is **never committed to our repos**. Odin3 v3.14.4 is
   disputed (same compile date as v3.14.1, older DLL, an unsigned
   DLL no component references, four different ZIPs circulating).
   We do not recommend it. Do not use any file claiming to be a
   newer Odin3 than v3.14.4.
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
   information: model must read **SM-A736B** and the service
   provider software version must show **XME** (or your own
   region, if you are flashing a different region's build). Do not
   flash this package on any other model or region.

## The 5 files in the firmware zip

Extract `SM-A736B_5_20261111014000_xdnr6nmbid_fac.zip`. Inside are
five `.tar.md5` files. Odin verifies each file's trailing MD5
before flashing. The exact filenames below follow the standard
Samsung naming for this build; the AP filename is confirmed in
the SamFrew child-file listing for the older GZB2 build, and the
same pattern applies to CGZK3.

| File | Odin slot | What it is |
|---|---|---|
| `BL_A736BXXSCGZK3_...tar.md5` | **BL** | Bootloader |
| `AP_A736BXXSCGZK3_...tar.md5` | **AP** | System (largest file; takes minutes to load). Contains `boot.img`, `recovery.img`, `system.img`, `vendor.img` |
| `CP_A736BXXSCGZK3_...tar.md5` | **CP** | Modem / baseband |
| `CSC_OLM_A736BOLMCGZK3_...tar.md5` | **CSC** | Region data. **Wipes the phone** (factory reset) |
| `HOME_CSC_OLM_A736BOLMCGZK3_...tar.md5` | **CSC** | Same region data. **Keeps your apps and data** |

Load all five files from the **same** package. Never mix files from
different builds or regions.

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
   Software information: build number must read
   `BP2A.250605.031.A3.A736BXXSCGZK3`.

## Verify

- Settings, About phone, Software information: build number reads
  `BP2A.250605.031.A3.A736BXXSCGZK3`.
- The phone has signal and the region features match XME.
- If you flashed CSC (wipe), the phone boots to fresh setup. If
  you flashed HOME_CSC, your apps and data are still there.

## Keeping TWRP through a stock flash

Flashing the full stock AP **replaces TWRP** with the stock
recovery, because the stock AP tar contains `recovery.img`. This
phone is not an A/B device, so recovery lives in its own
partition and the stock AP overwrites it.

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
     Power, while connected to a PC via USB) after the TWRP flash.
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
  than the one on the phone (anti-rollback). This CGZK3 package is
  bootloader C (12). You cannot flash it over a phone already on
  a newer bootloader, and after flashing it you cannot go back to
  bootloader 11 or lower.
- **Stuck on the Samsung logo or bootloop after flashing.** Boot
  into recovery (Volume Up + Power, while connected to a PC via
  USB) and wipe cache, then factory reset from stock recovery if
  needed. If it still will not boot, re-flash the full package
  with the **CSC** file (wipe).
- **Phone boots but has no signal or wrong region features.** The
  CSC does not match the phone. Re-flash with the correct XME
  package.
- **TWRP is gone after the flash.** Expected. See "Keeping TWRP"
  above. Re-flash the TWRP tar via Odin.

## Sources

- SamFrew, SM-A736B XME A736BXXSCGZK3 (PDA, CSC, modem, build
  date, patch, bootloader C (12), build number, kernel, file
  name, 10.3 GB):
  https://samfrew.com/download/Galaxy__A73__5G__/tstz/XME/A736BXXSCGZK3/A736BOLMCGZK3
- Samfw, SM-A736B XME A736BXXSBGZB2 (older build, MD5
  `dfaf3164926c476c67c4fc2dcdc1ef40`, for the superseded-build
  note): https://samfw.com/firmware/SM-A736B/XME/A736BXXSBGZB2
- SamMobile, SM-A736B XME A736BXXSAGZA1 (older build, patch
  2026-01-01):
  https://www.sammobile.com/samsung/galaxy-a73/firmware/SM-A736B/XME/download/A736BXXSAGZA1/1978662/
- LineageOS wiki, a73xq (samloader-rs firmware flashing):
  https://wiki.lineageos.org/devices/a73xq/fw_update/
- UN1CA target firmware XME:
  `target/a73xq/config.sh` line 13,
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/a73xq/config.sh

## TODO

- TODO: MD5 and SHA-256 for the CGZK3 zip were not published on
  the SamFrew page read on 2026-11-25. Get them from the download
  source and verify before flashing. Do not flash an unchecked
  10.3 GB download.
- TODO: Odin3 v3.14.1 SHA-256 was not verified from a trusted
  source in this session.
- TODO: the exact five `.tar.md5` filenames inside the CGZK3 zip
  have not been confirmed against a downloaded copy (the pattern
  is standard Samsung naming; only the GZB2 AP filename was seen
  in a child-file listing).
- TODO: no firmware record doc or Drive mirror exists for this
  phone in this project yet.
