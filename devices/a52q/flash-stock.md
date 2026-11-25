# Flash the stock ROM - Galaxy A52 (SM-A525F)

Return the SM-A525F to official Samsung firmware with Odin. This
file is for the SM-A525F only. Do not use it on any other model.
The firmware below is the **EUX (Europe)** region build, matching
the UN1CA target firmware for this device.

## When to use this

- Return the phone to stock: unbrick, undo a bad flash, prepare it
  for sale or service.
- Get a known-good base before custom work (UN1CA or HyperOS).
  UN1CA for this device requires Android 14 firmware (see
  [flash-un1ca.md](flash-un1ca.md)), so a stock Android 14 flash
  is the way to meet that requirement.
- Fix a bootloop or a broken system when TWRP alone cannot.

Flashing stock firmware **removes root, custom ROMs, and custom
recoveries** (see "Keeping TWRP" below) and **wipes data if you use
the CSC file**. It does **not** untrip Knox. A tripped Knox bit is
permanent, and flashing stock does not restore Samsung Pay or
Secure Folder on a tripped phone.

## What you are flashing

Latest official firmware for SM-A525F / EUX, checked 2026-11-25
against the SamMobile EUX listing (newest of 51 builds) and the
samfw record for the same build.

| Field | Value |
|---|---|
| Model / region | SM-A525F / **EUX (Europe)**, CSC `A525FOXMCFYF1` |
| PDA / AP | `A525FXXSCFYF1` |
| Modem / CP | `A525FXXSCFYF1` (CP file `CP30576548`) |
| Build number | TODO: not stated on the samfw record for this build. Confirm from the build properties after flashing and record it here. |
| Android / One UI | Android 14 / One UI 6.1 (TODO: confirm the One UI version from the build properties. The samfw record for FYF1 does not state it. The April 2024 build FXD2 on the same branch is One UI 6.1, see below.) |
| Security patch | 2025-04-01 |
| Build date | 2025-06-12 |
| Bootloader | **Bit C**: after this flash, no firmware with a bootloader bit below C will install (anti-rollback) |
| Size | 7.76 GB |
| MD5 | `77580b77fe1f0ed8462ad54205026c16` |
| SHA-256 | TODO: samfw publishes MD5 only. Compute it from the downloaded file and record it here. |
| Server file | TODO: the server zip filename was not listed on the samfw record. Record it from the downloaded file. |

Is this the latest official firmware for this region? Yes, as of
2026-11-25: the SamMobile EUX listing shows A525FXXSCFYF1 (built
12 June 2025) as the newest of 51 builds, ahead of A525FXXSBFYC1
(2025-03-07) and A525FXXSAFYB1 (2025-02-04). The file comes from
Samsung's servers via samfw. There is no Drive mirror in this
repo yet. **Verify the MD5 above before flashing.** Do not flash
a file whose hash does not match.

### Reference build: A525FXXU6FXD2 (April 2024, fully documented)

If FYF1 is not what you want, FXD2 is the older build with a
complete public record (One UI 6.1 upgrade, Android 14, patch
2024-04-01, bootloader 6, build number
`UP1A.231005.007.A525FXXU6FXD2`, kernel
`4.14.190-perf-28693687`, changelist 28693178, MD5
`fe0f4f391393c2939d3b4b1f66194ac4`, CSC `A525FOXM6FXD2`, 7.69 GB).
Note the anti-rollback rule: once the phone is on bootloader bit
C (FYF1), FXD2 (bit 6) will **not** install.

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
   Odin3 than v3.14.4. (Odin version and hash are the shared
   Samsung tool values already verified in this repo.)
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
   information: model must read **SM-A525F** and the service
   provider software version must show **EUX**. Do not flash this
   package on any other model or region.

## The 5 files in the firmware zip

Extract the firmware zip. Inside are five `.tar.md5` files. Odin
verifies each file's trailing MD5 before flashing. Child file
names and sizes below are from the samfw record for FYF1.

| File | Odin slot | What it is |
|---|---|---|
| `BL_A525FXXSCFYF1_...tar.md5` | **BL** | Bootloader (56.1 MB) |
| `AP_A525FXXSCFYF1_...tar.md5` | **AP** | System (6.5 GB, largest file; takes minutes to load). Contains `boot.img`, `recovery.img`, `system.img`, `vendor.img` (TODO: confirm the AP contents by listing the a52q AP tar) |
| `CP_A525FXXSCFYF1_...tar.md5` | **CP** | Modem / baseband (40.8 MB) |
| `CSC_OXM_A525FOXMCFYF1_...tar.md5` | **CSC** | Region data (559.3 MB). **Wipes the phone** (factory reset) |
| `HOME_CSC_OXM_A525FOXMCFYF1_...tar.md5` | **CSC** | Same region data (559.45 MB). **Keeps your apps and data** |

Load all five files from the **same** package. Never mix files from
different builds or regions.

## Steps

1. Download the firmware and verify its MD5 against the table
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
   Software information: build number must match the FYF1 build,
   and the service provider software version must show EUX.

## Verify

- Settings, About phone, Software information: build number reads
  the FYF1 build (TODO: record the exact build number string
  after the first flash of FYF1).
- The phone has signal and the region features match EUX.
- If you flashed CSC (wipe), the phone boots to fresh setup. If
  you flashed HOME_CSC, your apps and data are still there.

## Keeping TWRP through a stock flash

Flashing the full stock AP **replaces TWRP** with the stock
recovery, because the stock AP tar contains `recovery.img`. This
is the one rule that matters most for a phone with TWRP. It also
replaces a Magisk-patched recovery, so it removes root too (on
this device Magisk lives in recovery, see [root.md](root.md)).

- **If you want a fully stock phone**, that is expected. Flash
  normally and TWRP is gone. Re-flash TWRP afterwards if you want
  it back (via Odin, AP slot, with the TWRP tar), then boot
  straight into recovery.
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
     system first. Boot straight into recovery (power off,
     connect USB, hold Volume Up + Power) after the TWRP flash.
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
  download (re-check the firmware MD5), a bad cable, or the
  battery dying mid-flash. Re-enter Download mode and try again
  with a verified download.
- **`SW REV CHECK FAIL`.** The bootloader in the package is older
  than the one on the phone (anti-rollback). This FYF1 package is
  bootloader bit C. You cannot flash it over a phone already on a
  newer bootloader bit, and after flashing it you cannot go back
  to bit 6 (FXD2) or lower.
- **Stuck on the Samsung logo or bootloop after flashing.** Boot
  into recovery (power off, connect USB, hold Volume Up + Power)
  and wipe cache, then factory reset from stock recovery if
  needed. If it still will not boot, re-flash the full package
  with the **CSC** file (wipe).
- **Phone boots but has no signal or wrong region features.** The
  CSC does not match the phone. Re-flash with the correct EUX
  package.
- **TWRP is gone after the flash.** Expected. See "Keeping TWRP"
  above. Re-flash the TWRP tar via Odin.

## Sources

- Latest EUX firmware A525FXXSCFYF1 (AP, CSC, bit C, size 7.76
  GB, MD5 `77580b77fe1f0ed8462ad54205026c16`, build date
  2025-06-12, patch 2025-04-01, child file names and sizes):
  https://samfw.com/firmware/SM-A525F/EUX/A525FXXSCFYF1
- EUX listing, newest of 51 builds is A525FXXSCFYF1 (built 12 June
  2025), ahead of A525FXXSBFYC1 and A525FXXSAFYB1:
  https://www.sammobile.com/samsung/Galaxy-A52/firmware/SM-A525F/EUX/
- FXD2 reference record (One UI 6.1, build number
  `UP1A.231005.007.A525FXXU6FXD2`, kernel 4.14.190-perf, changelist
  28693178, bootloader 6):
  https://samfrew.com/download/Galaxy__A52__/dbzn/XFA/A525FXXU6FXD2/A525FOJM6FXD2
  and https://samfw.com/firmware/SM-A525F/EUX/A525FXXU6FXD2
- UN1CA target firmware pin (EUX) and SDK 34:
  `target/a52q/config.sh` lines 8 and 10 in
  salvogiangri/UN1CA branch `sixteen`.
- TODO: FYF1 build number string, changelist, One UI version,
  SHA-256, and server zip filename. All to be recorded from the
  downloaded file and the phone after the first FYF1 flash.
  TODO: confirm the AP tar contains `recovery.img` by listing it.
