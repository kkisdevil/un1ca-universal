# Flashing the stock firmware on the Galaxy M51 (SM-M515F)

How to return the M51 to official Samsung firmware with Odin — and
how to do it without losing TWRP. Read the whole guide before
starting. **Nothing here is flashed by us; this is a guide for a
human with the phone in hand.**

## When to use this

- Return the phone to stock (unbrick, undo a bad flash, prepare it
  for sale or service).
- Get a known-good base before custom work (UN1CA / HyperOS).
- Fix a bootloop or a broken system when TWRP alone cannot.

Flashing stock firmware **removes root, custom ROMs and custom
recoveries** (see the TWRP section below) and **wipes data if you use
the CSC file**. It does **not** untrip Knox — a tripped Knox bit is
permanent, and flashing stock does not restore Samsung Pay / Secure
Folder on a tripped phone.

## The firmware (what you are flashing)

| Field | Value |
|---|---|
| Model | SM-M515F (Galaxy M51) |
| Region / CSC | INS (India) — CSC `M515FODM6DXJ1` |
| PDA / AP | `M515FXXU6DXJ1` |
| Modem / CP | `M515FXXU6DXJ1` |
| Build number | `SP1A.210812.016.M515FXXU6DXJ1` |
| Android / One UI | Android 12 / One UI 4.1 |
| Security patch | 2024-05-01 |
| Changelist | 23974102 |
| Build date | 2024-10-03 |
| Bootloader | 6 — after this flash, no firmware with bootloader 5 or lower will install (anti-rollback) |
| Server file | `SM-M515F_2_20241004032751_smm7rurrx5_fac.zip` (~7.1 GB) |

This is the latest official firmware for INS. DXJ2 is the same build
for a different CSC group (Latin America only) — see
`docs/FIRMWARE.md` for the DXJ1-vs-DXJ2 resolution.

**Get it from:** Google Drive —
`backups/m51-hyperos/firmware/SM-M515F_2_20241004032751_smm7rurrx5_fac.zip`
(the shareable home; the file is too big for GitHub). Verify the
hashes against `docs/FIRMWARE.md` after downloading — do not flash
a file whose hash does not match.

## Prerequisites

1. **A Windows PC.** Odin is Windows-only. (Linux alternative:
   `samloader-rs flash` — same Odin protocol, command line. Not
   covered step-by-step here.)
2. **Samsung USB Driver** for mobile phones, installed on the PC
   (from Samsung: developer.samsung.com). Without it Odin will not
   see the phone. Close Samsung Smart Switch before flashing.
3. **Odin** — see the next section. Extract it into its own folder;
   keep the EXE and DLLs together. Run it as administrator.
4. **A good USB data cable** (charge-only cables will not work) and
   a USB port on the PC itself — avoid hubs and front-panel ports.
5. **Battery above 50%**, ideally full. A dead phone mid-flash is
   how bricks happen.
6. **Backup.** Copy photos, files and app data off the phone and
   check you can open the copies. If you use HOME_CSC your data
   *should* survive, but a backup is not optional.
7. **EFS backup first (TWRP users).** In TWRP, back up the EFS
   partition (and keep a copy off the phone) before any flashing.
   EFS holds the IMEI and modem calibration — losing it is very hard
   to recover from.
8. **Check the phone first.** Settings → About phone → Software
   information: model must read **SM-M515F** and the service
   provider software version must show **INS**. Do not flash this
   package on any other model or region.

## Odin — which version, where from, how to verify

Odin is **not officially distributed by Samsung**. It is a leaked
internal tool, so there is no Samsung download page, and **the Odin
binary is never committed to our repos**. Download it from one of
these community sources and verify the hash before running it:

- **Primary — Odin3 v3.14.1** (the conservative choice). The
  v3.14.4 archive is disputed (see below); v3.14.1 has no mystery
  files and is what most technicians use.
  - Size: 2,595,015 bytes
  - SHA-256: `638296a11b1bfa954991b0597214d833511b973480ae9e15e299a761fea1f794`
  - Source: the XDA thread for Odin3
    (https://forum.xda-developers.com/t/tool-utility-win-odin3-v3-14-4.4108247)
    or https://getodintool.com/ (measured checksums, checked
    2026-11-05).
- **Alternative — Odin3 v3.14.4** (highest version number, but
  disputed). The exe claims build 2020.1.17.0 yet was compiled
  2019-05-30, the same day as v3.14.1; its SS_DL.dll is identical
  to the one from v3.13.1 (2017); and the archive contains an
  unsigned networking DLL (`cpprest141_2_10.dll`) that neither the
  exe nor SS_DL.dll references. At least four different ZIPs
  labelled "Odin 3.14.4" circulate, each with a different SHA-256 —
  so a hash only identifies the archive from the source you got it
  from. XDA has threads arguing both sides ("Is Odin 3.14.4
  Hacked?" / "Odin 3.14.4 not hacked").
  - getodintool.com's archive: 4,511,538 bytes, SHA-256
    `eda427680fbd16716b8a4856fd450857d1bcc75e379ac90b9165e49d9d652828`,
    contents: `Odin3_v3.14.4.exe`, `SS_DL.dll`, `Odin3.ini`,
    `cpprest141_2_10.dll`, `README.txt`.
- **Verify before opening:** on Windows PowerShell,
  `Get-FileHash .\Odin3-v3.14.1.zip -Algorithm SHA256`, and compare
  the full result with the value above. If it differs, do not run
  the file. A matching hash identifies the archive — it is not a
  malware scan. Scan the extracted files with your security
  software and keep Windows SmartScreen checks on.
- **Do not use** any file claiming to be a newer Odin3 than
  v3.14.4 — Samsung has shared nothing newer, and such files
  should be treated with suspicion.

## The 5 files in the firmware zip

Extract `SM-M515F_2_20241004032751_smm7rurrx5_fac.zip`. Inside are
five `.tar.md5` files (Odin verifies each file's trailing MD5
before flashing):

| File | Odin slot | What it is |
|---|---|---|
| `BL_M515FXXU6DXJ1_...tar.md5` | **BL** | Bootloader |
| `AP_M515FXXU6DXJ1_...tar.md5` | **AP** | System (largest file; takes minutes to load) — contains `boot.img`, `recovery.img`, `system.img`, `vendor.img`, etc. |
| `CP_M515FXXU6DXJ1_...tar.md5` | **CP** | Modem / baseband |
| `CSC_ODM_M515FODM6DXJ1_...tar.md5` | **CSC** | Region data — **wipes the phone** (factory reset) |
| `HOME_CSC_ODM_M515FODM6DXJ1_...tar.md5` | **CSC** | Same region data — **keeps your apps and data** |

Load all five files from the **same** package. Never mix files from
different builds or regions.

## TWRP — read this before you flash

**Flashing the full stock AP replaces TWRP with the stock
recovery**, because the stock AP tar contains `recovery.img`. This
is the one rule that matters most for our phone:

- **If you want a fully stock phone**, that is expected — flash
  normally and TWRP is gone. Re-flash TWRP afterwards if you want
  it back (via Odin, AP slot, with the TWRP tar).
- **If you want to keep TWRP**, do NOT flash the stock AP as-is.
  Pick one:
  1. **Remove recovery from the AP tar (advanced).** Extract the
     AP `.tar.md5`, delete `recovery.img` from the tar, re-pack it
     and recompute the trailing MD5 (the `.md5` suffix is just a
     checksum footer Odin verifies — it is not a signature). Then
     flash the modified AP. The recovery partition is left
     untouched.
  2. **Flash stock, then immediately re-flash TWRP.** Flash the
     full stock package, and before the first boot into system,
     flash the TWRP tar via Odin (AP slot). Do not boot into the
     system first — boot straight into recovery (Volume Up +
     Power) after the TWRP flash.
- **Never** put any file in Odin's slots that writes the recovery
  partition unless you mean to replace TWRP. Check every tar you
  flash for a `recovery.img` entry first.
- After any stock flash, **re-flash TWRP before doing custom work
  again** — and take a fresh TWRP backup (including EFS) once the
  phone is back on stock.

## Step-by-step

1. Download the firmware (Drive link above) and verify its hashes
   against `docs/FIRMWARE.md`. Extract the zip — you need the five
   `.tar.md5` files.
2. Download Odin (v3.14.1 recommended), extract it, verify its
   SHA-256, install the Samsung USB Driver, close Smart Switch.
3. Back up the phone (and EFS via TWRP, if you have it).
4. **Enter Download mode.** Power the phone fully off. Press and
   hold **Volume Up + Volume Down**, then connect the USB cable to
   the PC. A warning screen appears — press **Volume Up** to
   continue into Download mode.
5. Open Odin **as administrator**. The `ID:COM` box turns blue and
   shows `Added!` in the log when the phone is detected. If
   nothing appears, the driver/cable/port is the problem — do not
   proceed.
6. Load the files into their slots: **BL** → BL file, **AP** → AP
   file (takes a few minutes to load — wait for the MD5 check to
   finish), **CP** → CP file, **CSC** → CSC *or* HOME_CSC (see the
   table above — CSC wipes, HOME_CSC keeps data).
7. Options: leave **Auto Reboot** and **F. Reset Time** ticked.
   Leave **Re-Partition unticked** (ticking it without a PIT file
   will fail or brick). Do not touch anything else.
8. Click **Start**. Do not unplug the cable, touch the phone, or
   close Odin. The flash takes several minutes; the phone reboots
   by itself when Odin shows **PASS** in green.
9. First boot after a flash can take several minutes — that is
   normal. Set the phone up, then check Settings → About phone →
   Software information: build number should read
   `SP1A.210812.016.M515FXXU6DXJ1`.

## Troubleshooting

- **Odin does not detect the phone (`ID:COM` stays empty).**
  Reinstall the Samsung USB Driver, try another USB port (on the
  PC itself, not a hub) and another data cable. Make sure the phone
  is actually in Download mode, not just charging.
- **Odin shows FAIL.** Read the exact line where the log stopped.
  Common causes: wrong model/region firmware, a corrupted download
  (re-check the firmware hashes), a bad cable, or the battery dying
  mid-flash. Re-enter Download mode and try again with a verified
  download.
- **`SW REV CHECK FAIL`.** The bootloader in the package is older
  than the one on the phone (anti-rollback). This DXJ1 package is
  bootloader 6 — you cannot flash it over a phone already on a
  newer bootloader, and after flashing it you cannot go back to
  bootloader 5 or lower.
- **Stuck on the Samsung logo / bootloop after flashing.** Boot
  into recovery (Volume Up + Power) and wipe cache, then factory
  reset from stock recovery if needed. If it still will not boot,
  re-flash the full package with the **CSC** file (wipe).
- **Phone boots but has no signal / wrong region features.** The
  CSC does not match the phone. Re-flash with the correct INS
  package.
- **TWRP is gone after the flash.** Expected — see the TWRP
  section above. Re-flash the TWRP tar via Odin.

## Linux / Mac

Odin3 is Windows-only. On Linux, `samloader-rs` (the same tool we
used to download this firmware) has a `flash` command that speaks
the Odin protocol — see `samloader --help` / the project README at
https://github.com/topjohnwu/samloader-rs. Flashing from Linux is
not covered step-by-step here and was not tested by us.

## Logger — the record of how this firmware got here

Everything about obtaining and verifying this firmware is logged,
so you can check what was done (and re-do a failed step) without
guessing.

- **What it logs:** the version check (region, tool, raw response,
  SamFrew cross-check), the download (source, size, resume,
  completion, hash computed vs expected), the verification (zip
  contents, BL/AP/CP/CSC presence, trailing-MD5 checks), and every
  Drive upload attempt (method, bytes, duration, error text,
  retry) — plus the final Drive path and hashes. Full detail:
  `scripts/firmware-logger.sh` and `scripts/fetch-firmware.sh`
  in the repo.
- **Where the log lives:** with the firmware itself —
  `backups/m51-hyperos/firmware/firmware.log` on Drive (and
  `~/workspace/firmware/m51-latest/firmware.log` on our machine).
  Lines look like
  `2026-11-24T23:56:11+05:30 [INFO] [download] message key=value`
  (IST timestamp, level, stage, message).
- **How to read it:** `grep '\[ERROR\]' firmware.log` shows
  failures; `grep '\[drive\]' firmware.log` shows the upload
  history; `grep 'verify' firmware.log` shows the verification
  record (hashes, contents, MD5 checks).
- **How to re-run a failed step:** re-running
  `bash scripts/fetch-firmware.sh` skips completed steps and
  re-does only what failed (download resumes from its `.part`
  file; Drive parts already present are not re-uploaded).
  `--check-only` re-runs just the version check;
  `--skip-drive` re-runs download + verify only.

## Sources

- Firmware record: `docs/FIRMWARE.md` in this repo.
- SamFrew DXJ1 / INS firmware page (identifiers, file name, CSC
  features): https://samfrew.com/model/SM-M515F/region/INS/
- Odin versions and checksums: https://getodintool.com/ and
  https://getodintool.com/latest/ (file-level comparison, checked
  2026-09-29 / 2026-11-05); XDA Odin3 thread:
  https://forum.xda-developers.com/t/tool-utility-win-odin3-v3-14-4.4108247
- Samsung USB Driver: developer.samsung.com
