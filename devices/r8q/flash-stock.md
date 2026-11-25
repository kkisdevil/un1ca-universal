# Flash the stock ROM - Galaxy S20 FE (Snapdragon) (SM-G780G)

Return the SM-G780G to official Samsung firmware with Odin. This
file is for the SM-G780G only. Do not use it on any other model,
including the Exynos S20 FE (SM-G780F).

## When to use this

- Return the phone to stock: unbrick, undo a bad flash, prepare it
  for sale or service.
- Get a known-good base before custom work (UN1CA or HyperOS).
  UN1CA for r8q requires Android 13 firmware (see
  [flash-un1ca.md](flash-un1ca.md)), so this flash is the way to
  get there.
- Fix a bootloop or a broken system when TWRP alone cannot.

Flashing stock firmware **removes root, custom ROMs, and custom
recoveries** (see "Keeping TWRP" below) and **wipes data if you use
the CSC file**. It does **not** untrip Knox. A tripped Knox bit is
permanent, and flashing stock does not restore Samsung Pay or
Secure Folder on a tripped phone.

## What you are flashing

| Field | Value |
|---|---|
| Model / region | SM-G780G / **BTU (UK and Ireland)**, CSC `G780GOXMHEYJ1` |
| PDA / AP | `G780GXXSHEYJ1` |
| Modem / CP | `G780GXXSHEYJ1` |
| Build number | `TP1A.220624.014.G780GXXSHEYJ1` (expected: the `TP1A.220624.014` prefix is the Android 13 base shared by all G780G Android 13 builds; confirm on the phone after flashing) |
| Android / One UI | Android 13 / One UI 5.1, patch 2025-10-01, changelist 27100863 |
| Build date | 2025-09-30 |
| Bootloader | **H (17)**: after this flash, no firmware with a lower bootloader binary will install (anti-rollback) |
| Server file | TODO: exact BTU server filename and byte size not recorded; no BTU package has been downloaded and hashed by us |
| MD5 | TODO |
| SHA-256 | TODO |

This is the latest official firmware for this phone, the same PDA
across regions (BTU, BTB, BTE, DBT and others all list
G780GXXSHEYJ1 as latest). The BTU build is confirmed by the UN1CA
proprietary vendor releases page, which lists
`G780GXXSHEYJ1 - SM-G780G - BTU - OXM` with PDA, CSC and modem all
`G780GXXSHEYJ1` / `G780GOXMHEYJ1`. For reference only, the same
build in other regions measures about 7.2 GB: SamFrew lists the
BTE package at 7,689,991,120 bytes, and SamMobile lists the DBT
package at 7,689,991,114 bytes with MD5
`4e7f313f3e51a74ab2a9a5575daf1573`. Those are other regions, not
BTU: **do not use them as the BTU hash**. Download the BTU package
and verify its own hashes before flashing.

TODO: download the BTU package (SamFrew, SamMobile, or
`samloader-rs` from Samsung's servers, as in the porter repo's
`scripts/fetch-firmware.sh`), record its exact filename, size,
MD5 and SHA-256 here, and mirror it.

## Prereqs

1. **A Windows PC.** Odin is Windows-only. On Linux,
   `samloader-rs flash` speaks the same Odin protocol, and
   Heimdall can flash individual partitions. Those routes are not
   covered step-by-step here.
2. **Samsung USB Driver** for mobile phones, installed on the PC
   (from Samsung: developer.samsung.com). Without it Odin will not
   see the phone. Close Samsung Smart Switch before flashing.
3. **Odin3 v3.14.1** (the conservative choice). TODO: Odin SHA-256
   not verified for this guide; verify it from the XDA Odin3
   thread before opening it. The r8q All-in-One XDA thread uses
   Odin v3.14.4. Do not use any file claiming to be a newer Odin3
   than v3.14.4. Odin is a leaked internal tool, not officially
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
   information: model must read **SM-G780G**. Do not flash this
   package on any other model or region.

## The 5 files in the firmware zip

Extract the firmware zip. Inside are five `.tar.md5` files. Odin
verifies each file's trailing MD5 before flashing. Exact filenames
depend on the downloaded package; the pattern below is the
standard Samsung layout for this build.

| File | Odin slot | What it is |
|---|---|---|
| `BL_G780GXXSHEYJ1_...tar.md5` | **BL** | Bootloader |
| `AP_G780GXXSHEYJ1_...tar.md5` | **AP** | System (largest file; takes minutes to load). Contains `boot.img`, `recovery.img`, `system.img`, `vendor.img` |
| `CP_G780GXXSHEYJ1_...tar.md5` | **CP** | Modem / baseband |
| `CSC_OXM_G780GOXMHEYJ1_...tar.md5` | **CSC** | Region data. **Wipes the phone** (factory reset) |
| `HOME_CSC_OXM_G780GOXMHEYJ1_...tar.md5` | **CSC** | Same region data. **Keeps your apps and data** |

Load all five files from the **same** package. Never mix files from
different builds or regions.

TODO: confirm the exact five filenames in the BTU zip once it is
downloaded.

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
   `TP1A.220624.014.G780GXXSHEYJ1`.
10. **After a stock flash, boot the phone and complete setup before
    flashing TWRP or anything else.** If Download mode shows KG
    STATUS PRENORMAL, Odin refuses to flash anything unofficial
    until the phone has been booted and set up.

## Verify

- Settings, About phone, Software information: build number reads
  `TP1A.220624.014.G780GXXSHEYJ1`.
- The phone has signal and the region features match BTU.
- If you flashed CSC (wipe), the phone boots to fresh setup. If
  you flashed HOME_CSC, your apps and data are still there.

## Keeping TWRP through a stock flash

Flashing the full stock AP **replaces TWRP** with the stock
recovery, because the stock AP tar contains `recovery.img`. TODO:
confirm by listing the contents of the r8q AP tar; this is the
standard Samsung layout.

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
     Power, USB cable still connected) after the TWRP flash.
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
  than the one on the phone (anti-rollback). This HEYJ1 package is
  bootloader binary H (17). You cannot flash it over a phone
  already on a newer bootloader, and after flashing it you cannot
  go back to any build with a lower bootloader binary.
- **Stuck on the Samsung logo or bootloop after flashing.** Boot
  into recovery (Volume Up + Power) and wipe cache, then factory
  reset from stock recovery if needed. If it still will not boot,
  re-flash the full package with the **CSC** file (wipe).
- **Phone boots but has no signal or wrong region features.** The
  CSC does not match the phone. Re-flash with the correct BTU
  package.
- **TWRP is gone after the flash.** Expected. See "Keeping TWRP"
  above. Re-flash the TWRP tar via Odin.
- **"Only official released binaries are allowed to be flashed
  (vbmeta)".** KG STATUS is PRENORMAL. Boot the phone, complete
  setup, and retry with the patched vbmeta tar.

## Sources

- Latest firmware G780GXXSHEYJ1 (Android 13, One UI 5.1, patch
  2025-10-01, built 2025-09-30, changelist 27100863) across
  regions: https://samfrew.com/firmware/model/SM-G780G/region/BTU/upload/Desc/10/10
  and https://samfrew.com/firmware/model/SM-G780G/region/BTB/upload/Desc/0/10
- BTU build confirmed, PDA/CSC/modem all HEYJ1:
  https://github.com/UN1CA/proprietary_vendor_samsung_sm8250/releases
  (entry `G780GXXSHEYJ1 - SM-G780G - BTU - OXM`)
- DBT package size and MD5 (reference only, not BTU):
  https://www.sammobile.com/samsung/galaxy-s20-fe/firmware/SM-G780G/DBT/download/G780GXXSHEYJ1/1966720/
- Bootloader binary H (17) for HEYJ1, and anti-rollback rule:
  https://samfirm.shop/build/G780GXXU3CVI1
- UN1CA donor firmware is SM-G780G/BTU:
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/r8q/config.sh
  (line 11)
- KG PRENORMAL rule and Odin behaviour: official r8q TWRP thread,
  https://xdaforums.com/t/recovery-official-external-sd-snapdragon-twrp-3-7-1_12-2-for-samsung-galaxy-s20-fe-4g-5g.4646593/
