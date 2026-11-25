# Flash the stock ROM - Galaxy S21+ 5G (SM-G996B)

Return the SM-G996B to official Samsung firmware with Odin. This
file is for the SM-G996B only. Do not use it on any other model.

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

Newest firmware record found for this device (checked 2026-11-25).
It is a SER (Russia) record; the UN1CA target firmware for this
device uses CSC AUT, so read the region note below before flashing
this package on an AUT phone.

| Field | Value |
|---|---|
| Model / region | SM-G996B / **SER** |
| PDA / AP | `G996BXXSJHZC2` |
| CSC | `G996BOXMJHZC2` |
| Modem / CP | `G996BXXSJHZA6` |
| Bootloader | `G996BXXSJHZC2` (same string as the PDA) |
| Android / One UI | Android 15 / One UI 7 (AP tar name carries `meta_OS15`) |
| Build number | TODO: not found in any source so far; do not guess the `SP1A...` style string |
| Security patch | TODO: not stated for HZC2 in any source found so far |
| Changelist | TODO |
| Build date | 2026-03-09 (SamMobile listing for this PDA) |
| Server file | `SM-G996B_5_20260310093132_5uqwgs1etf_fac.zip` (9,073,922,311 B) |
| SHA-256 | `343dd2d806cdd394b3af8b676b1c3ad61071a04af86dbc55159937f3440f0af6` |
| MD5 | TODO: no MD5 for the zip was published in the sources found |

The file, its byte size, its SHA-256, and its five entries come
from a third-party mirror record (klikcloud) of the Samsung server
file, verified_at 2026-11-05. The PDA and build date are
corroborated by SamMobile, which lists G996BXXSJHZC2 built
2026-03-09 and G996BXXSJHZA6 built 2026-01-21 for this model.
**Verify the SHA-256 above before flashing.** Do not flash a file
whose hash does not match. There is no Drive mirror in this repo
yet for t2s firmware.

Region note: this record is SER, not AUT. Flashing a SER CSC
package on an AUT phone changes the region software. If the phone
is an AUT phone (the UN1CA target firmware is AUT), TODO: find
and record the AUT HZC2 package before flashing stock on it, or
confirm that the SER package is acceptable for it. The newest AUT
record found on SamFW in search was G996BXXUAGXDA (Android 14,
One UI 6.1, build 2024-04-18, patch 2024-04-01), which is far
older than HZC2; do not flash that as "latest".

For reference, the SamFW-verified One UI 7 record for several
regions (SEB Baltic, O2C, TPL, XME, LUX) is PDA
`G996BXXUEHYD5`, CSC `G996BOXMEHYD5`, Android 15, 8.45 GB, MD5
`3b801b70898a042530265631c0320734`, build date 20250415205051,
security patch 2025-04-01, bootloader bit E. That build is older
than HZC2. Do not treat HYD5 as the latest.

Anti-rollback: TODO, the binary (bit) value of HZC2 was not stated
in any source found. HYD5 is bit E. Do not state a bit value for
HZC2 until SamFW or SamMobile lists it. The general rule stands:
you cannot flash a package older than the bootloader already on
the phone, and after flashing HZC2 you cannot go back to an older
bootloader. The UN1CA installer assertion (see flash-un1ca.md)
requires bootloader G996BXXSJHZC2 when the phone's rollback
protection value is above 19, which is consistent with HZC2
being the current required base.

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
   Odin3 than v3.14.4. (Shared Samsung tooling, cited from the
   m51 docs.)
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
   information: model must read **SM-G996B** (or SM-G996B/DS).
   Do not flash this package on any other model or on a region
   you have not thought through (see the region note above).

## The 5 files in the firmware zip

Extract `SM-G996B_5_20260310093132_5uqwgs1etf_fac.zip`. Inside are
five `.tar.md5` files. Odin verifies each file's trailing MD5
before flashing.

| File | Odin slot | What it is | Size (B) |
|---|---|---|---|
| `BL_G996BXXSJHZC2_G996BXXSJHZC2_MQB107295216_REV01_user_low_ship_MULTI_CERT.tar.md5` | **BL** | Bootloader | 9,758,833 |
| `AP_G996BXXSJHZC2_G996BXXSJHZC2_MQB107295216_REV01_user_low_ship_MULTI_CERT_meta_OS15.tar.md5` | **AP** | System (largest file; takes minutes to load). Contains `boot.img`, `recovery.img`, `system.img`, `vendor.img` | 9,847,982,203 |
| `CP_G996BXXSJHZA6_CP32677257_MQB105755316_REV01_user_low_ship_MULTI_CERT.tar.md5` | **CP** | Modem / baseband | 41,656,430 |
| `CSC_OXM_G996BOXMJHZC2_MQB107295216_REV01_user_low_ship_MULTI_CERT.tar.md5` | **CSC** | Region data. **Wipes the phone** (factory reset) | 645,836,904 |
| `HOME_CSC_OXM_G996BOXMJHZC2_MQB107295216_REV01_user_low_ship_MULTI_CERT.tar.md5` | **CSC** | Same region data. **Keeps your apps and data** | 645,785,709 |

Load all five files from the **same** package. Never mix files from
different builds or regions. TODO: the claim that the AP tar
contains `recovery.img` is the standard Samsung layout and has
not yet been checked by listing this exact t2s AP tar; verify it
before relying on the "Keeping TWRP" section.

## Steps

1. Download the firmware and verify its SHA-256 against the table
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
   Software information: build number must match the HZC2 build
   you flashed.

## Verify

- Settings, About phone, Software information: build number reads
  the HZC2 build. TODO: record the exact build number string
  once a phone has flashed HZC2.
- The phone has signal and the region features match the CSC you
  flashed.
- If you flashed CSC (wipe), the phone boots to fresh setup. If
  you flashed HOME_CSC, your apps and data are still there.

## Keeping TWRP through a stock flash

Flashing the full stock AP **replaces TWRP** with the stock
recovery, because the stock AP tar contains `recovery.img`. This
is the one rule that matters most for our phone, subject to the
TODO in "The 5 files" above.

- **If you want a fully stock phone**, that is expected. Flash
  normally and TWRP is gone. Re-flash TWRP afterwards if you want
  it back (via Odin, AP slot, with the TWRP tar, plus the vbmeta
  step from flash-twrp.md).
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
  download (re-check the firmware SHA-256), a bad cable, or the
  battery dying mid-flash. Re-enter Download mode and try again
  with a verified download.
- **`SW REV CHECK FAIL`.** The bootloader in the package is older
  than the one on the phone (anti-rollback). You cannot flash it
  over a phone already on a newer bootloader, and after flashing
  HZC2 you cannot go back to an older bootloader.
- **Stuck on the Samsung logo or bootloop after flashing.** Boot
  into recovery (Volume Up + Power, with USB connected) and wipe
  cache, then factory reset from stock recovery if needed. If it
  still will not boot, re-flash the full package with the **CSC**
  file (wipe).
- **Phone boots but has no signal or wrong region features.** The
  CSC does not match the phone. Re-flash with the correct package
  for the phone's region.
- **TWRP is gone after the flash.** Expected. See "Keeping TWRP"
  above. Re-flash the TWRP tar via Odin.

## Sources

- Newest firmware record (SER, HZC2, file, bytes, SHA-256, five
  entries with sizes): klikcloud firmware-info.json:
  https://www.klikcloud.ru/en/file/88453-firmware-info
- PDA and build date corroboration: SamMobile Galaxy S21+
  SM-G996B firmware listing:
  https://www.sammobile.com/samsung/galaxy-s21-plus/firmware/SM-G996B/COA/
  (G996BXXSJHZC2 built 2026-03-09; G996BXXSJHZA6 built
  2026-01-21).
- Older One UI 7 record (HYD5, SEB): SamFW:
  https://www.samfw.com/firmware/SM-G996B/SEB/G996BXXUEHYD5
  (PDA G996BXXUEHYD5, CSC G996BOXMEHYD5, Android 15, 8.45 GB,
  MD5 3b801b70898a042530265631c0320734, build 20250415205051,
  patch 2025-04-01, bit E).
- Older AUT record (GXDA): SamFW:
  https://www.samfw.com/firmware/SM-G996B/AUT/G996BXXUAGXDA
  (Android 14, build 20240418164730, patch 2024-04-01).
- Odin3 v3.14.1 size and SHA-256, slot table, and guide
  structure: [../m51/flash-stock.md](../m51/flash-stock.md)
  (shared Samsung tooling and practice, not m51 values).
- Bootloader assertion: upstream UN1CA
  `target/t2s/installer/assertions.edify` (verbatim, supplied
  with this task): SM-G996B requires bootloader G996BXXSJHZC2
  when ro.boot.rp is above 19.

## TODO

- Build number string, security patch date, and changelist for
  HZC2.
- MD5 of the HZC2 zip.
- Binary (bit) value of HZC2 for the anti-rollback rule.
- AUT HZC2 package (the UN1CA target region), or confirmation
  that SER is acceptable on an AUT phone.
- Confirm the HZC2 AP tar contains `recovery.img`.
- Exact build number string shown after flashing HZC2.
- A Drive mirror path for t2s firmware in this repo.
