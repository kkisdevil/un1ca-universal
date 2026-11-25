# Flash the stock ROM - Galaxy A72 (SM-A725F)

Return the SM-A725F to official Samsung firmware with Odin. This
file is for the SM-A725F only. Do not use it on any other model.

## When to use this

- Return the phone to stock: unbrick, undo a bad flash, prepare it
  for sale or service.
- Get a known-good base before custom work (UN1CA or HyperOS).
  UN1CA 3.2.1 requires Android 14 firmware (see flash-un1ca.md),
  and this build is Android 14.
- Fix a bootloop or a broken system when TWRP alone cannot.

Flashing stock firmware **removes root, custom ROMs, and custom
recoveries** (see "Keeping TWRP" below) and **wipes data if you use
the CSC file**. It does **not** untrip Knox. A tripped Knox bit is
permanent, and flashing stock does not restore Samsung Pay or
Secure Folder on a tripped phone.

## What you are flashing

The reference firmware is the BTU (United Kingdom) package, which
is the region the upstream UN1CA target is built against
(`target/a72q/config.sh` line 8:
`TARGET_FIRMWARE="SM-A725F/BTU/353546291234560"`).

| Field | Value |
|---|---|
| Model / region | SM-A725F / **BTU (United Kingdom)**, CSC `A725FOXMBFYC1` |
| PDA / AP | `A725FXXSBFYC1` |
| Modem / CP | `A725FXXSBFYC1` |
| Build number | `UP1A.231005.007.A725FXXSBFYC1` |
| Android / One UI | Android 14 (API 34) / One UI 6.1, patch 2025-03-01, changelist 28693178 |
| Build date | 2025-03-05 (SamFrew) / 2025-03-10 (SamMobile BTU listing; see note below) |
| Bootloader | **B (11)**: after this flash, no firmware with bootloader A (10) or lower will install (anti-rollback) |
| Server file | `SM-A725F_4_20250310135841_keaogmkx0f_fac.zip` (7.6 GB, 8,161,213,706 B) |
| MD5 | `7cd2189d2a7f2b2a496990eb9a92be46` (SamMobile; see note below) |
| SHA-256 | TODO: not published by the sources above; compute it after downloading and record it here |

This is the latest official firmware for BTU: SamMobile lists 28
BTU builds, newest first, with A725FXXSBFYC1 at the top, and no
newer SM-A725F build exists in any region in the SamFrew listing
either (checked 2026-11-25). The same PDA ships for 57 countries
under 93 CSC codes, so the build is current well beyond BTU.

Notes and conflicts to resolve before flashing:

- Build date: SamFrew gives 2025-03-05, SamMobile's BTU page
  gives 2025-03-10, for the same file
  `SM-A725F_4_20250310135841_keaogmkx0f_fac.zip`. The filename
  timestamp (2025-03-10 13:58:41) matches SamMobile. Treat
  2025-03-10 as the package build date and 2025-03-05 as the
  system build date inside it, until a live `*#1234#` read
  settles it. TODO: confirm from a live phone.
- MD5: SamMobile publishes
  `7cd2189d2a7f2b2a496990eb9a92be46` for this BTU zip. Samfw
  publishes a different MD5 (`049973c4df75629eecacf24cc6267c10`)
  for what it lists as the same BTU build. The two sites may
  package the zip differently. Verify the hash against the site
  you downloaded from, and record the SHA-256 of the file you
  actually flash. TODO: download once, hash it, and record the
  result here.
- The firmware has **not** been downloaded or verified by us yet.
  There is no Drive mirror. TODO: download the BTU zip, verify
  hashes, and record the mirror path.

Other regions, same PDA (for phones that are not BTU):

| Region | CSC | Server file |
|---|---|---|
| INS (India) | `A725FODMBFYC1` | `SM-A725F_4_20250318224511_68olvptvhr_fac.zip` (7.357 GiB) |
| OJM (Middle East / Africa group) | `A725FOJMBFYC1` | `SM-A725F_4_20250310175511_bcn7it9qdc_fac.zip` (6.647 GiB) |
| OLM (South East Asia group) | `A725FOLMBFYC1` | see SamMobile XNF listing, MD5 `3c78c383d9ad4731e045ecda80aed8bf` |

Flash the package that matches your phone's region. Never mix
files from different builds or regions.

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
   Odin3 than v3.14.4.
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
   information: model must read **SM-A725F**. Check the service
   provider software version and the CSC (dial `*#1234#`) and
   flash the package for that region. Do not flash the BTU
   package on a phone from another region unless you accept the
   region change.

## The 5 files in the firmware zip

Extract `SM-A725F_4_20250310135841_keaogmkx0f_fac.zip`. Inside are
five `.tar.md5` files. Odin verifies each file's trailing MD5
before flashing. Exact child filenames for the BTU build, from the
Samfw listing:

| File | Odin slot | What it is |
|---|---|---|
| `BL_A725FXXSBFYC1_A725FXXSBFYC1_MQB93349949_REV00_user_low_ship_MULTI_CERT.tar.md5` (55.71 MB) | **BL** | Bootloader |
| `AP_A725FXXSBFYC1_A725FXXSBFYC1_MQB93349949_REV00_user_low_ship_MULTI_CERT_meta_OS14.tar.md5` (6.31 GB) | **AP** | System (largest file; takes minutes to load). Contains `boot.img`, `recovery.img`, `system.img`, `vendor.img` |
| `CP_A725FXXSBFYC1_CP29311295_MQB93349949_REV00_user_low_ship_MULTI_CERT.tar.md5` (40.81 MB) | **CP** | Modem / baseband |
| `CSC_OXM_A725FOXMBFYC1_MQB93349949_REV00_user_low_ship_MULTI_CERT.tar.md5` (575.74 MB) | **CSC** | Region data. **Wipes the phone** (factory reset) |
| `HOME_CSC_OXM_A725FOXMBFYC1_MQB93349949_REV00_user_low_ship_MULTI_CERT.tar.md5` (575.7 MB) | **CSC** | Same region data. **Keeps your apps and data** |

Load all five files from the **same** package. Never mix files from
different builds or regions.

## Steps

1. Download the firmware and verify its hashes against the table
   above. Extract the zip. You need the five files listed above.
2. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
3. Open Odin **as administrator**. The `ID:COM` box turns blue
   and shows `Added!` when the phone is detected. If nothing
   appears, the driver, cable, or port is the problem. Do not
   proceed.
4. Load BL into BL, AP into AP, CP into CP, and CSC (or HOME_CSC)
   into CSC. Wait for Odin to finish checking each file's MD5
   before clicking Start. The AP file is 6.31 GB and takes
   minutes to load.
5. Leave **Auto Reboot** and **F. Reset Time** ticked. Leave
   **Re-Partition** unticked. Never tick Re-Partition without a
   PIT file.
6. Click **Start**. Wait for PASS. Do not touch the cable or the
   phone until Odin says PASS.
7. The phone reboots. First boot takes several minutes.
8. Check: Settings, About phone, Software information. Build
   number must read `UP1A.231005.007.A725FXXSBFYC1` and the
   Android security patch level must read 2025-03-01.

## Verify

- Build number `UP1A.231005.007.A725FXXSBFYC1`, Android 14, One UI
  6.1, patch 2025-03-01.
- The phone has signal and the region features match the CSC you
  flashed (check `*#1234#`: AP, CP and CSC all read FYC1).
- TODO: confirm the AP tar contains `recovery.img` by listing the
  extracted AP tar on a live download; the 6.31 GB AP follows the
  standard Samsung layout, but it has not been listed by us yet.

## Keeping TWRP through a stock flash

- A full stock AP flash **replaces TWRP** with stock recovery
  (the stock AP tar contains `recovery.img` in the standard
  Samsung layout). To keep TWRP, either remove `recovery.img`
  from the AP tar before flashing (advanced: re-pack the tar and
  recompute the trailing MD5; the `.md5` suffix is only a checksum
  footer, not a signature), or flash stock and then **immediately
  re-flash TWRP before the first boot into system**
  ([flash-twrp.md](flash-twrp.md) steps 2 to 5, then boot straight
  into recovery with Volume Up + Power).
- After any stock flash, re-flash TWRP before doing custom work
  again, and take a fresh TWRP backup (including EFS) once the
  phone is back on stock.

## Troubleshooting

- **Odin does not detect the phone.** Reinstall the Samsung USB
  Driver, try another port (on the PC itself, not a hub) and
  another data cable. Confirm the phone is in Download mode.
- **Odin shows FAIL.** Check you loaded the right files in the
  right slots, from one package, and that each file's MD5 checked
  out. Re-download a file whose hash does not match. Try another
  USB port and cable.
- **`SW REV CHECK FAIL`.** You tried to flash a bootloader older
  than the one on the phone. After FYC1 (bootloader B, 11), no
  firmware with bootloader A (10) or lower will install. Flash
  FYC1 or newer only.
- **Stuck on logo or bootloop after flashing.** Boot into stock
  recovery (power off, hold Volume Up + Power) and factory reset
  from there. If it still will not boot, re-flash with the CSC
  file (not HOME_CSC) so the phone is fully wiped.
- **No signal or wrong region features.** You flashed the wrong
  region package. Check `*#1234#`, then flash the package for
  your phone's region.
- **TWRP is gone after the flash.** Expected: the stock AP
  replaced it. Re-flash TWRP before the first boot into system
  (see "Keeping TWRP" above).

## Sources

- SamMobile, BTU firmware page:
  https://www.sammobile.com/samsung/galaxy-a72/firmware/SM-A725F/BTU/download/A725FXXSBFYC1/1914787/
  (PDA A725FXXSBFYC1, CSC A725FOXMBFYC1, Android 14, build
  2025-03-10, changelist 28693178, 7.6 GB / 8,161,213,706 B, MD5
  `7cd2189d2a7f2b2a496990eb9a92be46`; latest of 28 BTU builds).
- SamFrew, SM-A725F firmware records:
  https://samfrew.com/download/Galaxy__A72__/3tpt/SEK/A725FXXSBFYC1/A725FOXMBFYC1
  (build date 2025-03-05, kernel
  `4.14.190-perf-28694960-abA725FXXSBFYC1`, bootloader B (11)).
- Samfw, BTU child files:
  https://samfw.com/firmware/SM-A725F/BTU/A725FXXSBFYC1
  (exact child filenames and sizes; conflicting MD5
  `049973c4df75629eecacf24cc6267c10`, see the note in the table).
- SamFirm build record: https://samfirm.shop/build/A725FXXSBFYC1
  (bootloader raised A (10) to B (11) from FXL2, no way back).
- INS variant: SamFirm record (CSC `A725FODMBFYC1`, file
  `SM-A725F_4_20250318224511_68olvptvhr_fac.zip`, 7.357 GiB).
- Upstream target config:
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/a72q/config.sh
  line 8 (BTU target firmware).
