# Flash the stock ROM - Galaxy S21 5G (SM-G991B)

Return the SM-G991B to official Samsung firmware with Odin. This
file is for the SM-G991B only. Do not use it on any other model.

## When to use this

- Return the phone to stock: unbrick, undo a bad flash, prepare it
  for sale or service.
- Get a known-good base before custom work (UN1CA or HyperOS).
  UN1CA for this device requires an Android 15 bootloader, so a
  stock flash to an Android 15 build is the way to get there.
- Fix a bootloop or a broken system when TWRP alone cannot.

Flashing stock firmware **removes root, custom ROMs, and custom
recoveries** (see "Keeping TWRP" below) and **wipes data if you use
the CSC file**. It does **not** untrip Knox. A tripped Knox bit is
permanent, and flashing stock does not restore Samsung Pay or
Secure Folder on a tripped phone.

## What you are flashing

The target-region build for this folder is **AUT (Switzerland)**,
the region the UN1CA target firmware names
(`SM-G991B/AUT/350261971234566`). Flash the build for your own
phone's region if it is not AUT; never flash another region's CSC
on a phone you want to keep region-correct.

| Field | Value |
|---|---|
| Model / region | SM-G991B / **AUT (Switzerland)**, CSC `G991BOXMJHZA6` |
| PDA / AP | `G991BXXSJHZA6` |
| Modem / CP | `G991BXXSJHZA6` |
| Build number | `AP3A.240905.015.A2.G991BXXSJHZA6` |
| Android / One UI | Android 15 / One UI 7.0, patch 2026-01-01, changelist 30959686 |
| Build date | 2026-01-21 (upload 2026-01-29) |
| Bootloader | **J (19)**: after this flash, no firmware with bootloader binary below 19 will install (anti-rollback) |
| Server file | `SM-G991B_5_20260121165440_6g9g44m6tz_fac.zip` (10.4 GB, as listed by SamFrew) |
| MD5 | TODO: not published on the SamFrew record; verify from the downloaded file before flashing |
| SHA-256 | TODO: same as MD5 |

This is the latest AUT build found on SamFrew on 2026-11-25. It
has **not** been downloaded and hash-verified by us. TODO:
download it, verify its hashes, and fill in the MD5 and SHA-256
above. Do not flash a file whose hash does not match.

Newer builds exist for other regions, and they matter for the
UN1CA bootloader rule (see below):

- `G991BXXSJHZC2` (Android 15, patch 2026-01-01, binary 19):
  build date 2026-03-10, for XXV (Vietnam) with MD5
  `790db2d27f821c24a7fcdcfb28f7078b` and 8.44 GB, and for COO/COB/
  PNT with MD5 `e50cfa1ab112560d1b5342f6f51f5041`. No AUT HZC2
  record was found in search on 2026-11-25. TODO: check whether
  AUT received HZC2.
- `G991BXXUJHZF2` (Android 15, binary 19): the newest build
  overall per samdb.org, released 2026-07-03 for XID. TODO:
  check whether AUT received it.

The UN1CA installer assertion names **G991BXXSJHZC2** as the
required bootloader for SM-G991B when `ro.boot.rp` is above 19
(see [flash-un1ca.md](flash-un1ca.md)). If you are preparing
the phone for UN1CA, the HZC2 bootloader is the one the
installer checks for. The AUT HZA6 build above is binary 19,
the same binary as HZC2, but it is not the build the assertion
names. TODO: confirm from the installer whether HZA6 satisfies
the assertion or whether HZC2 must be flashed first.

## Prereqs

1. **A Windows PC.** Odin is Windows-only. On Linux,
   `samloader-rs flash` speaks the same Odin protocol. That route
   is not covered step-by-step here.
2. **Samsung USB Driver** for mobile phones, installed on the PC
   (from Samsung: developer.samsung.com). Without it Odin will not
   see the phone. Close Samsung Smart Switch before flashing.
3. **Odin3 v3.14.1** (the conservative choice). Size 2,595,015
   bytes, SHA-256
   `638296a11b1bfa954991b0597214d833511b973480ae9e15e299a761fea1f794`,
   from the XDA Odin3 thread or https://getodintool.com/. Verify
   before opening it, in PowerShell:
   `Get-FileHash .\Odin3-v3.14.1.zip -Algorithm SHA256`.
   Extract it into its own folder and keep the EXE and DLLs
   together. Run it as administrator. Odin is a leaked internal
   tool, not officially distributed by Samsung, and its binary is
   **never committed to our repos**. Odin3 v3.14.4 is disputed
   (same compile date as v3.14.1, older DLL, an unsigned DLL no
   component references, four different ZIPs circulating). We do
   not recommend it. Do not use any file claiming to be a newer
   Odin3 than v3.14.4. (Odin version and hash reused from the m51
   docs, which verified them; the hash is for the Odin tool
   itself, not for this device.)
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
   information: model must read **SM-G991B** and the service
   provider software version must show **AUT**. Do not flash this
   package on any other model or region.

## The 5 files in the firmware zip

Extract the firmware zip. Inside are five `.tar.md5` files. Odin
verifies each file's trailing MD5 before flashing. The exact
child filenames for the AUT HZA6 package are TODO: fill them in
from the downloaded zip. The verified filename pattern below
comes from the XXV HZC2 package on SamFW; the AUT HZA6 files
follow the same pattern with HZA6 in place of HZC2 and the OXM
CSC in place of the XXV one.

| File | Odin slot | What it is |
|---|---|---|
| `AP_G991BXXSJHZA6_...tar.md5` (pattern: `AP_G991BXXSJHZC2_G991BXXSJHZC2_MQB107294787_REV01_user_low_ship_MULTI_CERT_meta_OS15.tar.md5.zip`, 7.34 GB) | **AP** | System (largest file; takes minutes to load). Contains `boot.img`, `recovery.img`, `system.img`, `vendor.img` |
| `BL_G991BXXSJHZA6_...tar.md5` (pattern: `BL_G991BXXSJHZC2_G991BXXSJHZC2_MQB107294787_REV01_user_low_ship_MULTI_CERT.tar.md5.zip`, 8.14 MB) | **BL** | Bootloader |
| `CP_G991BXXSJHZA6_...tar.md5` (pattern: `CP_G991BXXSJHZA6_CP32677249_MQB105755308_REV01_user_low_ship_MULTI_CERT.tar.md5.zip`, 32.57 MB) | **CP** | Modem / baseband. Note: the XXV HZC2 package ships the HZA6 modem, so the CP version can differ from the AP version |
| `CSC_OXM_G991BOXMJHZA6_...tar.md5` (pattern: `CSC_OXM_G991BOXMJHZC2_MQB107294787_REV01_user_low_ship_MULTI_CERT.tar.md5.zip`, 504.8 MB) | **CSC** | Region data. **Wipes the phone** (factory reset) |
| `HOME_CSC_OXM_G991BOXMJHZA6_...tar.md5` (pattern: `HOME_CSC_OXM_G991BOXMJHZC2_MQB107294787_REV01_user_low_ship_MULTI_CERT.tar.md5.zip`, 504.87 MB) | **CSC** | Same region data. **Keeps your apps and data** |

Load all five files from the **same** package. Never mix files from
different builds or regions.

## Steps

1. Download the firmware and verify its hashes against the table
   above (TODO: hashes still to be filled in). Extract the zip.
   You need the five `.tar.md5` files.
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
   `AP3A.240905.015.A2.G991BXXSJHZA6`.

## Verify

- Settings, About phone, Software information: build number reads
  `AP3A.240905.015.A2.G991BXXSJHZA6`.
- The phone has signal and the region features match AUT.
- If you flashed CSC (wipe), the phone boots to fresh setup. If
  you flashed HOME_CSC, your apps and data are still there.

## Keeping TWRP through a stock flash

Flashing the full stock AP **replaces TWRP** with the stock
recovery, because the stock AP tar contains `recovery.img`. TODO:
confirm by listing the o1s AP tar contents before stating this
as verified for this device. The keep-TWRP routes, if confirmed,
are the same as on other Samsung devices:

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
     system first. Boot straight into recovery (connect USB, hold
     Volume Up + Power) after the TWRP flash.
- **Never** put any file in Odin's slots that writes the recovery
  partition unless you mean to replace TWRP. Check every tar you
  flash for a `recovery.img` entry first.
- After any stock flash, **re-flash TWRP before doing custom work
  again**, and take a fresh TWRP backup (including EFS) once the
  phone is back on stock.
- Note the warning in [flash-twrp.md](flash-twrp.md): after an
  Odin firmware update, re-flash TWRP with vbmeta disabled or
  the phone may not start.

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
  than the one on the phone (anti-rollback). This HZA6 package is
  bootloader binary 19 (J). You cannot flash it over a phone
  already on a newer bootloader binary, and after flashing it you
  cannot go back to binary 18 or lower.
- **Stuck on the Samsung logo or bootloop after flashing.** Boot
  into recovery (connect USB, hold Volume Up + Power) and wipe
  cache, then factory reset from stock recovery if needed. If it
  still will not boot, re-flash the full package with the **CSC**
  file (wipe).
- **Phone boots but has no signal or wrong region features.** The
  CSC does not match the phone. Re-flash with the correct AUT
  package.
- **TWRP is gone after the flash.** Expected. See "Keeping TWRP"
  above. Re-flash the TWRP tar via Odin.

## Sources

- AUT HZA6 build (PDA, CSC, modem, Android 15, One UI 7.0,
  patch 2026-01-01, build date 2026-01-21, upload 2026-01-29,
  changelist 30959686, build number, kernel 5.4.242-30958140,
  bootloader J (19), server filename, 10.4 GB): SamFrew,
  https://samfrew.com/download/Galaxy__S21__5G__/dlnl/AUT/G991BXXSJHZA6/G991BOXMJHZA6
- HZC2 XXV record (PDA, CSC, binary J, MD5
  `790db2d27f821c24a7fcdcfb28f7078b`, 8.44 GB, build date
  20260310113440, child filenames and sizes):
  https://samfw.com/firmware/SM-G991B/XXV/G991BXXSJHZC2
- HZC2 COO/COB/PNT record (MD5
  `e50cfa1ab112560d1b5342f6f51f5041`):
  https://samfw.com/firmware/SM-G991B/COO/G991BXXSJHZC2
- Newest build overall G991BXXUJHZF2 (XID, 2026-07-03, binary
  19): https://samdb.org/model/SM-G991B
- UN1CA target region AUT and HZC2 bootloader assertion:
  upstream `salvogiangri/UN1CA` branch `sixteen`,
  `target/o1s/config.sh` and
  `target/o1s/installer/assertions.edify`, read live 2026-11-25.
- Odin steps and slot table shape: m51 docs
  (`../m51/flash-stock.md`); device values are this device's own.
