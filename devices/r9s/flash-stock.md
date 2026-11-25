# Flash the stock ROM - Galaxy S21 FE 5G (SM-G990E)

Return the SM-G990E to official Samsung firmware with Odin. This
file is for the SM-G990E only (Exynos S21 FE 5G, codename r9s). Do
not use it on the Snapdragon FE (SM-G990B, SM-G990B2, SM-G990U) or
any other model. Flashing the wrong model's firmware can brick the
phone.

## When to use this

- Return the phone to stock: unbrick, undo a bad flash, prepare it
  for sale or service.
- Get a known-good base before custom work (UN1CA or HyperOS).
  Note: UN1CA needs the last **Android 15** bootloader (GYI3),
  not the newest Android 16 firmware. See the GYI3 table below.
- Fix a bootloop or a broken system when the recovery alone cannot.

Flashing stock firmware **removes root, custom ROMs, and custom
recoveries** (see "Keeping TWRP" below) and **wipes data if you use
the CSC file**. It does **not** untrip Knox. A tripped Knox bit is
permanent, and flashing stock does not restore Samsung Pay or
Secure Folder on a tripped phone.

## What you are flashing

Two firmware records matter for this device. The first is the
fully verified THL (Thailand) Android 16 package. The second is
the last Android 15 bootloader build, which is the base UN1CA
requires. Do not mix them up.

### Record 1: THL Android 16 (fully verified on SamFW)

| Field | Value |
|---|---|
| Model / region | SM-G990E / **THL (Thailand)**, CSC `G990EOLMJHYJ4` |
| PDA / AP | `G990EXXSJHYJ4` |
| Modem / CP | `G990EXXSJHYJ3` |
| Build number | TODO: exact build number string (SamFW does not list it; read it from Settings after flashing or from the AP tar) |
| Android / One UI | Android 16 / One UI 8.0, patch 2025-10-01 |
| Build date | 2025-10-18 06:45:31 |
| Bootloader | **J** (SamFW BIT J; newer than the GYI3 level 18 below, so GYI3 cannot be flashed after this one) |
| Server file | TODO: exact Samsung server filename (SamFW lists only the child files; the full zip name was not recorded) |
| Size | 7.78 GB full files |
| MD5 | `54449862540380e6cac4cda14b275ae7` |
| SHA-256 | TODO: SamFW publishes MD5 only; compute and record the SHA-256 after downloading |

### Record 2: last Android 15 bootloader (the UN1CA base)

| Field | Value |
|---|---|
| Model / region | SM-G990E / **THL / MYM (Thailand)**, CSC `G990EOLMIGYI3` |
| PDA / AP | `G990EXXSIGYI3` |
| Modem / CP | `G990EXXSIGYI1` |
| Build number | `AP3A.240905.015.A2.G990EXXSIGYI3` |
| Android / One UI | Android 15 / One UI 7.0, patch 2025-09-01, changelist 30959686 |
| Build date | 2025-09-05 |
| Bootloader | **I (18)**: after this flash, no firmware with bootloader 17 or lower will install (anti-rollback) |
| Server file | `SM-G990E_4_20250909170851_0kizfvc8wi_fac.zip` (MYM package) |
| Kernel | `5.4.242-30976065-abG990EXXSIGYI3` |
| MD5 | TODO for the THL/MYM zip (the DOR package MD5 is `7cf482abf4e94e5dc16922d4d6f44443`, 8,236,868,822 B; the FWD package MD5 is `1ec31af5279a8488c2b50fbdc58fb75b`, 8,201,087,888 B; same PDA, different CSC, so do not use those hashes for the THL zip) |
| SHA-256 | TODO |

### Newer builds (not fully verified here)

SamMobile lists **G990EXXSPHZK2, built 2026-11-10, Android 16**
as the newest SM-G990E build, for Philippines (Open Line) (XTC),
Malaysia, Thailand, and Philippines (Globe). TODO: the CSC,
modem, bootloader level, hashes and file size for the Thailand
(PHZK2) package were not recorded in this pass; confirm them on
SamMobile or SamFW before flashing PHZK2. Do not flash PHZK2 on
the strength of the PDA string alone.

SamMobile also lists India (INS) on **G990EXXSNHZF5**, dated
2026-10-30. TODO: CSC, modem, bootloader level and hashes for the
INS package were not recorded in this pass.

This record was checked 2026-11-25 on SamMobile
(https://www.sammobile.com/samsung/firmware/SM-G990E/) and SamFW
(THL JHYJ4 page). Firmware keeps moving: re-check the listing
before you download, and verify the hash of whatever you download
before flashing.

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
   Odin3 than v3.14.4. (Shared tooling, cited from the m51 docs.)
4. **A good USB data cable** (charge-only cables will not work)
   and a USB port on the PC itself. No hubs, no front-panel ports.
5. **Battery above 50%, ideally full.** A dead phone mid-flash is
   how bricks happen.
6. **Back up.** Copy photos, files, and app data off the phone and
   check you can open the copies. If you use HOME_CSC your data
   should survive, but a backup is not optional.
7. **EFS backup first (recovery users).** In the custom recovery,
   back up the EFS partition and keep a copy off the phone before
   any flashing. EFS holds the IMEI and modem calibration. Losing
   it is very hard to recover from.
8. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G990E** and the service
   provider software version must show your region. Do not flash
   a package for any other model or region.
9. **Decide which record you need.** For UN1CA, flash the GYI3
   (Android 15) package, not the newest Android 16 package: UN1CA
   requires the last Android 15 bootloader, and Android 16 removes
   the bootloader unlock option. For a plain return to stock, use
   the newest package for your region.

## The 5 files in the firmware zip

The JHYJ4 (THL) package on SamFW lists these five child files.
Odin verifies each file's trailing MD5 before flashing.

| File | Odin slot | What it is |
|---|---|---|
| `AP_G990EXXSJHYJ4_G990EXXSJHYJ4_MQB102475392_REV01_user_low_ship_MULTI_CERT_meta_OS16.tar.md5.zip` (7.5 GB, contains the AP tar) | **AP** | System (largest file; takes minutes to load). Contains `boot.img`, `recovery.img`, `system.img`, `vendor.img` (standard Samsung AP contents; TODO: confirm by listing this AP tar) |
| `BL_G990EXXSJHYJ4_G990EXXSJHYJ4_MQB102475392_REV01_user_low_ship_MULTI_CERT.tar.md5.zip` (8.1 MB) | **BL** | Bootloader |
| `CP_G990EXXSJHYJ3_CP31876234_MQB102447260_REV01_user_low_ship_MULTI_CERT.tar.md5.zip` (32.53 MB) | **CP** | Modem / baseband |
| `CSC_OLM_G990EOLMJHYJ4_MQB102475392_REV01_user_low_ship_MULTI_CERT.tar.md5.zip` (91.77 MB) | **CSC** | Region data. **Wipes the phone** (factory reset) |
| `HOME_CSC_OLM_G990EOLMJHYJ4_MQB102475392_REV01_user_low_ship_MULTI_CERT.tar.md5.zip` (91.94 MB) | **CSC** | Same region data. **Keeps your apps and data** |

Load all five files from the **same** package. Never mix files from
different builds or regions. (The GYI3 package has the same five
files with GYI3 names; TODO: record its exact child filenames.)

## Steps

1. Download the firmware (SamFW or SamMobile link above) and verify
   its MD5 against the table above. Extract the zip. You need the
   five `.tar.md5` files.
2. Download Odin (v3.14.1 recommended), extract it, verify its
   SHA-256, install the Samsung USB Driver, close Smart Switch.
3. Back up the phone (and EFS via the custom recovery, if you have
   it).
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
   Software information: build number must read the PDA you
   flashed (for example `AP3A.240905.015.A2.G990EXXSIGYI3` for
   the GYI3 package).

## Verify

- Settings, About phone, Software information: build number reads
  the PDA you flashed.
- The phone has signal and the region features match your region.
- If you flashed CSC (wipe), the phone boots to fresh setup. If
  you flashed HOME_CSC, your apps and data are still there.

## Keeping TWRP through a stock flash

Flashing the full stock AP **replaces the custom recovery** with
the stock recovery, because the stock AP tar contains
`recovery.img` (standard Samsung behaviour; TODO: confirm by
listing this AP tar). This is the one rule that matters most.

- **If you want a fully stock phone**, that is expected. Flash
  normally and the custom recovery is gone. Re-flash it afterwards
  if you want it back (via Odin, AP slot, with the recovery tar).
- **If you want to keep the recovery**, do NOT flash the stock AP
  as-is. Pick one:
  1. **Remove recovery from the AP tar (advanced).** Extract the
     AP `.tar.md5`, delete `recovery.img` from the tar, re-pack it
     and recompute the trailing MD5 (the `.md5` suffix is just a
     checksum footer Odin verifies: it is not a signature). Then
     flash the modified AP. The recovery partition is left
     untouched.
  2. **Flash stock, then immediately re-flash the recovery.** Flash
     the full stock package, and before the first boot into system,
     flash the recovery tar via Odin (AP slot). Do not boot into the
     system first. Boot straight into recovery (Volume Up + Power,
     USB connected) after the recovery flash.
- **Never** put any file in Odin's slots that writes the recovery
  partition unless you mean to replace the recovery. Check every
  tar you flash for a `recovery.img` entry first.
- After any stock flash, **re-flash the recovery before doing
  custom work again**, and take a fresh backup (including EFS)
  once the phone is back on stock.

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
  than the one on the phone (anti-rollback). The GYI3 package is
  bootloader 18: you cannot flash it over a phone already on a
  newer bootloader (for example JHYJ4, bit J), and after flashing
  it you cannot go back to bootloader 17 or lower. If you need
  GYI3 for UN1CA but the phone is already on Android 16, you
  cannot downgrade the bootloader: TODO, no downgrade path was
  found in this pass.
- **Stuck on the Samsung logo or bootloop after flashing.** Boot
  into recovery (Volume Up + Power) and wipe cache, then factory
  reset from stock recovery if needed. If it still will not boot,
  re-flash the full package with the **CSC** file (wipe).
- **Phone boots but has no signal or wrong region features.** The
  CSC does not match the phone. Re-flash with the correct package
  for your region.
- **Custom recovery is gone after the flash.** Expected. See
  "Keeping TWRP" above. Re-flash the recovery tar via Odin.

## Next step

Flash a custom recovery: [flash-twrp.md](flash-twrp.md). Or flash
UN1CA (needs the GYI3 base): [flash-un1ca.md](flash-un1ca.md).

## Sources

- THL JHYJ4 record (PDA, CSC, CP, Android 16, bit J, build date,
  patch level, MD5, size, child filenames and sizes):
  https://samfw.com/firmware/SM-G990E/THL/G990EXXSJHYJ4
- Latest build listing (G990EXXSPHZK2, 2026-11-10, Android 16,
  Thailand/Malaysia/Philippines; India G990EXXSNHZF5,
  2026-10-30): https://www.sammobile.com/samsung/firmware/SM-G990E/
  (read live 2026-11-25).
- GYI3 record (PDA, CSC, modem, build number, kernel, changelist,
  build date, patch, bootloader I (18), server filename):
  https://samfrew.com/download/Galaxy__S21__FE__5G__/hqik/MYM/G990EXXSIGYI3/G990EOLMIGYI3
  and SamMobile DOR/FWD GYI3 pages (MD5s and sizes quoted there).
- GYI3 as the last Android 15 bootloader for the S21 FE:
  ExtremeROM wiki Build Guide,
  https://github.com/ExtremeXT/ExtremeROM/wiki/Build-Guide
- Shared Samsung flash flow (Odin steps, slots, Re-Partition
  rule, keep-recovery routes): `../m51/flash-stock.md` in this
  repo.
