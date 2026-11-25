# Flash the stock ROM - Galaxy S21 Ultra 5G (SM-G998B)

Return the SM-G998B to official Samsung firmware with Odin. This
file is for the SM-G998B only. Do not use it on any other model.

## When to use this

- Return the phone to stock: unbrick, undo a bad flash, prepare it
  for sale or service.
- Get a known-good base before custom work (UN1CA or HyperOS).
  The UN1CA target firmware for this device is SM-G998B/AUT, and
  the installer requires G998BXXSJHZC2 when the rollback
  protection counter is above 19 (see [flash-un1ca.md](flash-un1ca.md)).
- Fix a bootloop or a broken system when TWRP alone cannot.

Flashing stock firmware **removes root, custom ROMs, and custom
recoveries** (see "Keeping TWRP" below) and **wipes data if you use
the CSC file**. It does **not** untrip Knox. A tripped Knox bit is
permanent, and flashing stock does not restore Samsung Pay or
Secure Folder on a tripped phone.

## What you are flashing

This is the latest official firmware for AUT (Switzerland), the
region the UN1CA target pins, as listed by SamFrew and SamMobile
on 2026-11-25. It is also the firmware the UN1CA installer
requires. The same PDA ships for many regions with different CSC
packages; the table below is the AUT / OXM package.

| Field | Value |
|---|---|
| Model / region | SM-G998B / **AUT (Switzerland)**, CSC `G998BOXMJHZC2` |
| PDA / AP | `G998BXXSJHZC2` |
| Modem / CP | `G998BXXSJHZA6` |
| Build number | `AP3A.240905.015.A2.G998BXXSJHZC2` |
| Android / One UI | Android 15 (API 35) / One UI 7.0, patch 2026-01-01, changelist 30959686 |
| Build date | 2026-03-09 |
| Upload date | 2026-03-19 (AUT listing; 2026-03-25 on other regions) |
| Bootloader | **J (19)**: after this flash, no firmware with bootloader 18 or lower will install (anti-rollback) |
| Kernel | `5.4.242-30958140-abG998BXXSJHZC2` |
| Server file | `SM-G998B_5_20260310114221_btvwlikit9_fac.zip` (9.00 GiB, 9,660,966,864 B; Samsung server file `SM-G998B_5_20260310114221_btvwlikit9_fac.zip.enc4`) |
| CRC32 (Samsung FUS) | `89A3C02F` |
| MD5 | TODO: not published on the SamFrew or SamMobile pages found. Verify from the download source before flashing and record it here. |
| SHA-256 | TODO: same as MD5. Not found in research. Record it here once verified from a downloaded copy. |

This is the latest official firmware for AUT: SamMobile lists
G998BXXSJHZC2 built 2026-03-09 as the newest AUT build, ahead of
G998BXXSJHZA6 (2026-01-21) and G998BXXSIHYK1 (2025-11-05), and
SamFrew marks it "Latest for AUT". No newer SM-G998B firmware was
found in research on 2026-11-25. The file has not been downloaded
and hash-verified by us yet: **verify the hashes above before
flashing once they are recorded, and do not flash a file whose
hash does not match**. There is no Drive mirror for this device
yet. Get the file from SamFrew, SamMobile, or Samsung's servers
via samloader.

Note: SamFrew's download page shows "11.1 GB ZIP" while the
Samsung server record lists 9.00 GiB (9,660,966,864 B). The 9.00
GiB figure is the server file size and is the one in the table.
TODO: confirm the downloaded zip size and record it here.

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
   Odin3 than v3.14.4. Shared tooling, verified in
   `../m51/flash-stock.md`.
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
   information: model must read **SM-G998B** and the service
   provider software version must show your region code. Do not
   flash this AUT package on a phone whose CSC you need to keep
   unless you understand the CSC change: flashing the AUT CSC
   changes the region configuration.

## The 5 files in the firmware zip

Extract `SM-G998B_5_20260310114221_btvwlikit9_fac.zip`. Inside are
five `.tar.md5` files. Odin verifies each file's trailing MD5
before flashing. Exact file names below are from the Samsung
server package record.

| File | Odin slot | What it is |
|---|---|---|
| `BL_G998BXXSJHZC2_G998BXXSJHZC2_MQB107295400_REV01_user_low_ship_MULTI_CERT.tar.md5` | **BL** | Bootloader |
| `AP_G998BXXSJHZC2_G998BXXSJHZC2_MQB107295400_REV01_user_low_ship_MULTI_CERT_meta_OS15.tar.md5` | **AP** | System (largest file; takes minutes to load). Contains `boot.img`, `recovery.img`, `system.img`, `vendor.img` |
| `CP_G998BXXSJHZA6_CP32677266_MQB105755821_REV01_user_low_ship_MULTI_CERT.tar.md5` | **CP** | Modem / baseband |
| `CSC_OXM_G998BOXMJHZC2_MQB107295400_REV01_user_low_ship_MULTI_CERT.tar.md5` | **CSC** | Region data. **Wipes the phone** (factory reset) |
| `HOME_CSC_OXM_G998BOXMJHZC2_MQB107295400_REV01_user_low_ship_MULTI_CERT.tar.md5` | **CSC** | Same region data. **Keeps your apps and data** |

Load all five files from the **same** package. Never mix files from
different builds or regions. Note the modem in this package is
HZA6, not HZC2: the CP file is `CP_G998BXXSJHZA6`, matching the
firmware record (Modem `G998BXXSJHZA6`).

## Steps

1. Download the firmware and verify its hashes against the table
   above once the MD5 and SHA-256 are recorded. Extract the zip.
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
   `AP3A.240905.015.A2.G998BXXSJHZC2`.

## Verify

- Settings, About phone, Software information: build number reads
  `AP3A.240905.015.A2.G998BXXSJHZC2`.
- The phone has signal and the region features match AUT (or your
  own CSC if you flashed a different region package).
- If you flashed CSC (wipe), the phone boots to fresh setup. If
  you flashed HOME_CSC, your apps and data are still there.

## Keeping TWRP through a stock flash

Flashing the full stock AP **replaces TWRP** with the stock
recovery, because the stock AP tar contains `recovery.img`. This
is the one rule that matters most for our phone.

- **If you want a fully stock phone**, that is expected. Flash
  normally and TWRP is gone. Re-flash TWRP afterwards if you want
  it back (via Odin, AP slot, with the TWRP tar, plus
  `vbmeta_disabled_R.tar` in USERDATA: see
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
- Note the p3s difference from m51: on this device the vbmeta
  file goes in the USERDATA slot, per the p3s TWRP thread. See
  [flash-twrp.md](flash-twrp.md).

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
  than the one on the phone (anti-rollback). This HZC2 package is
  bootloader 19 (J). You cannot flash it over a phone already on
  a newer bootloader, and after flashing it you cannot go back to
  bootloader 18 or lower.
- **Stuck on the Samsung logo or bootloop after flashing.** Boot
  into recovery (Volume Up + Power, with USB connected) and wipe
  cache, then factory reset from stock recovery if needed. If it
  still will not boot, re-flash the full package with the **CSC**
  file (wipe).
- **Phone boots but has no signal or wrong region features.** The
  CSC does not match the phone. Re-flash with the correct region
  package.
- **TWRP is gone after the flash.** Expected. See "Keeping TWRP"
  above. Re-flash the TWRP tar via Odin.
- **Touchscreen dead after flashing HZA6 or HZC2.** An XDA thread
  reports the touchscreen stopping after the HZA6 update
  (G998BXXSJHZA6), fixed by flashing a single vendor_boot file
  built for exactly that build. Do not flash that file on HZC2
  unless a matching HZC2 report exists. See Sources.

## TODO

- TODO: MD5 and SHA-256 of
  `SM-G998B_5_20260310114221_btvwlikit9_fac.zip`. Record them here
  from a downloaded copy before anyone flashes from this guide.
- TODO: confirm the downloaded zip byte size (SamFrew shows 11.1
  GB on its download page; the Samsung server record says 9.00
  GiB).
- TODO: confirm the AP tar contents list (`boot.img`,
  `recovery.img`, `system.img`, `vendor.img`) by listing the
  extracted AP tar. The list above follows the standard Samsung
  AP layout and the m51 record; it is not yet confirmed for this
  exact AP file.
- TODO: confirm whether the touchscreen issue reported on HZA6
  also affects HZC2.

## Sources

- SamFrew AUT record (PDA, CSC, modem, changelist, build date,
  upload date, file name, build number, kernel, bootloader J):
  https://samfrew.com/download/Galaxy__S21__Ultra__5G__/tbqu/AUT/G998BXXSJHZC2/G998BOXMJHZC2
- SamMobile AUT firmware list (latest AUT build G998BXXSJHZC2,
  2026-03-09; previous HZA6 2026-01-21, IHYK1 2025-11-05):
  https://www.sammobile.com/samsung/galaxy-s21-ultra/firmware/SM-G998B/AUT
- Samsung server package record (file names of all five tars,
  9.00 GiB size, CRC32 89A3C02F): SamFirm,
  https://samfirm.shop/build/G998BXXSJHZC2
- UN1CA target firmware and bootloader requirement: salvogiangri/
  UN1CA branch `sixteen`, `target/p3s/config.sh` line 13 and
  `target/p3s/installer/assertions.edify` lines 2 to 3, read live
  2026-11-25.
- Touchscreen issue on HZA6: XDA,
  https://xdaforums.com/t/galaxy-s21-ultra-sm-g998b-touchscreen-fix-for-g998bxxsjhza6-without-root-unlocked-bootloader-required.4809366/
- Odin steps, slots, options and keeping-TWRP rules: shared
  Samsung practice, verified in `../m51/flash-stock.md`.

## Next step

Flash TWRP: [flash-twrp.md](flash-twrp.md). Or flash UN1CA:
[flash-un1ca.md](flash-un1ca.md).
