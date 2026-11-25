> Mirror of the verified m51 guides. Canonical home is the [m51-hyperos repo](https://github.com/kkisdevil/m51-hyperos) (`docs/devices/m51/`); if the two copies disagree, that copy wins.

# Flash the stock ROM - Galaxy M51 (SM-M515F)

Return the SM-M515F to official Samsung firmware with Odin. This
file is for the SM-M515F only. Do not use it on any other model.
Full deep version:
[../../FLASHING-GUIDE.md](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/FLASHING-GUIDE.md).

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
| Model / region | SM-M515F / **INS (India)**, CSC `M515FODM6DXJ1` |
| PDA / AP | `M515FXXU6DXJ1` |
| Modem / CP | `M515FXXU6DXJ1` |
| Build number | `SP1A.210812.016.M515FXXU6DXJ1` |
| Android / One UI | Android 12 / One UI 4.1, patch 2024-05-01, changelist 23974102 |
| Build date | 2024-10-03 |
| Bootloader | **6**: after this flash, no firmware with bootloader 5 or lower will install (anti-rollback) |
| Server file | `SM-M515F_2_20241004032751_smm7rurrx5_fac.zip` (5,964,436,871 B) |
| MD5 | `d3afc8d09f0bf94faaeccfd29517c9df` |
| SHA-256 | `0e71ca19c9d2af6eb8b63e9882218792f855d90326893312bdfa4e1ff5ab50c5` |

This is the latest official firmware for INS, downloaded from
Samsung's servers and verified by us (all 5 files present,
trailing MD5s check, zip CRCs clean). **DXJ2 is the same build for
Latin America only**: not newer, not for INS. Get the file from our
Drive mirror `backups/m51-hyperos/firmware/` (too big for GitHub)
and **verify the hashes above before flashing**. Do not flash a
file whose hash does not match. Full fetch and verify record:
[../../FIRMWARE.md](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/FIRMWARE.md).

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
   information: model must read **SM-M515F** and the service
   provider software version must show **INS**. Do not flash this
   package on any other model or region.

## The 5 files in the firmware zip

Extract `SM-M515F_2_20241004032751_smm7rurrx5_fac.zip`. Inside are
five `.tar.md5` files. Odin verifies each file's trailing MD5
before flashing.

| File | Odin slot | What it is |
|---|---|---|
| `BL_M515FXXU6DXJ1_...tar.md5` | **BL** | Bootloader |
| `AP_M515FXXU6DXJ1_...tar.md5` | **AP** | System (largest file; takes minutes to load). Contains `boot.img`, `recovery.img`, `system.img`, `vendor.img` |
| `CP_M515FXXU6DXJ1_...tar.md5` | **CP** | Modem / baseband |
| `CSC_ODM_M515FODM6DXJ1_...tar.md5` | **CSC** | Region data. **Wipes the phone** (factory reset) |
| `HOME_CSC_ODM_M515FODM6DXJ1_...tar.md5` | **CSC** | Same region data. **Keeps your apps and data** |

Load all five files from the **same** package. Never mix files from
different builds or regions.

## Steps

1. Download the firmware (Drive link above) and verify its hashes
   against the table above. Extract the zip. You need the five
   `.tar.md5` files.
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
   `SP1A.210812.016.M515FXXU6DXJ1`.

## Verify

- Settings, About phone, Software information: build number reads
  `SP1A.210812.016.M515FXXU6DXJ1`.
- The phone has signal and the region features match INS.
- If you flashed CSC (wipe), the phone boots to fresh setup. If
  you flashed HOME_CSC, your apps and data are still there.

## Keeping TWRP through a stock flash

Flashing the full stock AP **replaces TWRP** with the stock
recovery, because the stock AP tar contains `recovery.img`. This
is the one rule that matters most for our phone.

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
     Power) after the TWRP flash.
- **Never** put any file in Odin's slots that writes the recovery
  partition unless you mean to replace TWRP. Check every tar you
  flash for a `recovery.img` entry first.
- After any stock flash, **re-flash TWRP before doing custom work
  again**, and take a fresh TWRP backup (including EFS) once the
  phone is back on stock.

## Other repos' way back (myghi63's stock-restore variant)

His guide restores stock with AP, BL, CP, and CSC in Odin and
**HOME_CSC left empty, then a data wipe after**. Or **AP-only** for
a functional stock restore without touching the other partitions.
Same result as above by a shorter route. The CSC vs HOME_CSC
choice above is ours.

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
  than the one on the phone (anti-rollback). This DXJ1 package is
  bootloader 6. You cannot flash it over a phone already on a
  newer bootloader, and after flashing it you cannot go back to
  bootloader 5 or lower.
- **Stuck on the Samsung logo or bootloop after flashing.** Boot
  into recovery (Volume Up + Power) and wipe cache, then factory
  reset from stock recovery if needed. If it still will not boot,
  re-flash the full package with the **CSC** file (wipe).
- **Phone boots but has no signal or wrong region features.** The
  CSC does not match the phone. Re-flash with the correct INS
  package.
- **TWRP is gone after the flash.** Expected. See "Keeping TWRP"
  above. Re-flash the TWRP tar via Odin.
