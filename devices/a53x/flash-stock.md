# Flash the stock ROM - Galaxy A53 5G (SM-A536B)

Return the SM-A536B to official Samsung firmware with Odin. This
file is for the SM-A536B only. Do not use it on any other model.
The A53 5G is an Exynos phone (Exynos 1280, s5e8825): the modem
and bootloader in the package are Exynos builds, and the kernel
inside is the 5.10 Exynos kernel, not a Snapdragon one.

## When to use this

- Return the phone to stock: unbrick, undo a bad flash, prepare it
  for sale or service.
- Get a known-good base before custom work (UN1CA or HyperOS).
- Fix a bootloop or a broken system when TWRP alone cannot.

Flashing stock firmware **removes root, custom ROMs, and custom
recoveries** (see "Keeping TWRP" below) and **wipes data if you
use the CSC file**. It does **not** untrip Knox. A tripped Knox
bit is permanent, and flashing stock does not restore Samsung Pay
or Secure Folder on a tripped phone.

## What you are flashing

| Field | Value |
|---|---|
| Model / region | SM-A536B / **EUX (Europe)**, CSC `A536BOXM...` (see TODO below) |
| PDA / AP | `A536BXXUOGZI3` |
| Modem / CP | TODO: not published on the records checked; expected to match the PDA string, verify from the downloaded package |
| Build number | TODO: expected form `BP2A.250605.031.A3.A536BXXUOGZI3` by analogy with earlier 2026 builds; verify from the downloaded package, do not flash on an assumed string |
| Android / One UI | Android 16 / One UI 8.0, changelist 31998945 |
| Build date | 2026-09-14 (released 2026-09-15) |
| Bootloader | **Binary 24**: after this flash, no firmware with a lower bootloader binary will install (anti-rollback) |
| Server file | TODO: exact server filename and byte size not found on the records checked |
| MD5 | TODO |
| SHA-256 | TODO |

This is the latest official firmware for EUX as of 2026-11-25:
SamDB lists `A536BXXUOGZI3` as the newest EUX build, Android 16,
released 2026-09-15 on bootloader binary 24, and SamMobile lists
the same PDA for Europe with build date 2026-09-14. The CSC
string, modem, build number, server filename, and hashes are
TODO: they were not on the public records checked. Download the
package only from Samsung's own servers (via SamFirm, samloader,
or Frija) or a trusted mirror, and **verify the hashes from the
download source before flashing**. Do not flash a file whose hash
you have not checked.

For reference, the last EUX build with a complete public record
is `A536BXXSJGZA2`: PDA `A536BXXSJGZA2`, CSC `A536BOXMJGZA2`,
modem `A536BXXSJGZA2`, build number
`BP2A.250605.031.A3.A536BXXSJGZA2`, One UI 8.0, Android 16,
security patch 2026-01-01, bootloader J (19), build date
2026-01-07, server file
`SM-A536B_5_20260109195941_pssoit9quy_fac.zip`, kernel
`5.10.237-android12-9-31999025-abA536BXXSJGZA2` (SamFrew). That
build is older than GZI3; it is listed here only as the
identifier pattern, not as the recommended flash.

## Prereqs

1. **A Windows PC.** Odin is Windows-only. On Linux, Odin4
   speaks the same protocol (named in the a53x XDA TWRP thread).
   That route is not covered step-by-step here.
2. **Samsung USB Driver** for mobile phones, installed on the PC
   (from Samsung: developer.samsung.com). Without it Odin will
   not see the phone. Close Samsung Smart Switch before flashing.
3. **Odin3 v3.14.1** (the conservative choice). Extract it into
   its own folder and keep the EXE and DLLs together. Run it as
   administrator. Odin is a leaked internal tool, not officially
   distributed by Samsung, and its binary is **never committed
   to our repos**. Do not use any file claiming to be a newer
   Odin3 than v3.14.4.
4. TODO: Odin SHA-256 not verified from a trusted source for this
   device. Verify it from the XDA Odin3 thread before opening
   it. Do not copy a hash from another device's guide.
5. **A good USB data cable** (charge-only cables will not work)
   and a USB port on the PC itself. No hubs, no front-panel
   ports.
6. **Battery above 50%, ideally full.** A dead phone mid-flash is
   how bricks happen.
7. **Back up.** Copy photos, files, and app data off the phone
   and check you can open the copies. If you use HOME_CSC your
   data should survive, but a backup is not optional.
8. **EFS backup first (TWRP users).** In TWRP, back up the EFS
   partition and keep a copy off the phone before any flashing.
   EFS holds the IMEI and modem calibration. Losing it is very
   hard to recover from.
9. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A536B** and the service
   provider software version must show **EUX**. Do not flash
   this package on any other model or region.

## The files in the firmware zip

Extract the firmware zip. Inside are five `.tar.md5` files. Odin
verifies each file's trailing MD5 before flashing.

| File | Odin slot | What it is |
|---|---|---|
| `BL_A536BXXUOGZI3_...tar.md5` | **BL** | Bootloader (Exynos sboot) |
| `AP_A536BXXUOGZI3_...tar.md5` | **AP** | System (largest file; takes minutes to load). Contains `boot.img`, `recovery.img`, `system.img`, `vendor.img` |
| `CP_A536BXXUOGZI3_...tar.md5` | **CP** | Modem / baseband (Exynos Shannon modem) |
| `CSC_OXM_A536BOXM..._...tar.md5` | **CSC** | Region data. **Wipes the phone** (factory reset) |
| `HOME_CSC_OXM_A536BOXM..._...tar.md5` | **CSC** | Same region data. **Keeps your apps and data** |

TODO: the exact CSC filenames for the GZI3 EUX package were not
on the records checked; the pattern above follows the GZA2 EUX
record (`A536BOXMJGZA2`). Confirm the filenames from the zip
you download before loading them.

Load all five files from the **same** package. Never mix files
from different builds or regions.

## Steps

1. Download the firmware and verify its hashes against the
   download source. Extract the zip. You need the five
   `.tar.md5` files.
2. Download Odin (v3.14.1 recommended), extract it, verify its
   SHA-256 once the TODO above is resolved, install the Samsung
   USB Driver, close Smart Switch.
3. Back up the phone (and EFS via TWRP, if you have it).
4. **Enter Download mode.** Power the phone fully off. Press and
   hold **Volume Up + Volume Down**, then connect the USB cable
   to the PC. A warning screen appears. Press **Volume Up** to
   continue into Download mode.
5. Open Odin **as administrator**. The `ID:COM` box turns blue
   and shows `Added!` in the log when the phone is detected. If
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
   Software information: build number must read the GZI3 build
   number from the package you flashed.

## Verify

- Settings, About phone, Software information: build number
  reads the GZI3 build.
- The phone has signal and the region features match EUX.
- If you flashed CSC (wipe), the phone boots to fresh setup. If
  you flashed HOME_CSC, your apps and data are still there.

## Keeping TWRP through a stock flash

Flashing the full stock AP **replaces TWRP** with the stock
recovery, because the stock AP tar contains `recovery.img`. This
is the one rule that matters most for this phone, and it matters
twice here: on this device Magisk also lives in recovery, so a
stock AP flash removes root as well as TWRP.

- **If you want a fully stock phone**, that is expected. Flash
  normally and TWRP is gone. Re-flash TWRP afterwards if you want
  it back (via Odin, AP slot, with the TWRP tar), then re-root
  (see [root.md](root.md)).
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
     Power, USB connected) after the TWRP flash.
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
  than the one on the phone (anti-rollback). This GZI3 package
  is bootloader binary 24. You cannot flash it over a phone
  already on a newer bootloader, and after flashing it you cannot
  go back to a lower binary.
- **Stuck on the Samsung logo or bootloop after flashing.** Boot
  into recovery (Volume Up + Power, USB connected) and wipe
  cache, then factory reset from stock recovery if needed. If it
  still will not boot, re-flash the full package with the **CSC**
  file (wipe).
- **Phone boots but has no signal or wrong region features.** The
  CSC does not match the phone. Re-flash with the correct EUX
  package.
- **TWRP is gone after the flash.** Expected. See "Keeping TWRP"
  above. Re-flash the TWRP tar via Odin.

## Sources

- Latest EUX build `A536BXXUOGZI3`, Android 16, 2026-09-15,
  bootloader binary 24: https://samdb.org/model/SM-A536B
- Same PDA for Europe, build date 2026-09-14:
  https://www.sammobile.com/samsung/Galaxy-A53-5G/firmware/SM-A536B/EUX/
- Full identifier record for the older EUX build `A536BXXSJGZA2`
  (CSC, modem, build number, file name, kernel 5.10.237,
  bootloader J/19, changelist 31998945):
  https://samfrew.com/download/Galaxy__A53__5G__/5wgv/EUX/A536BXXSJGZA2/A536BOXMJGZA2
- Changelist 31998945 shared across the 2026 builds, GZI3 for
  EUX: https://samfrew.com/firmware/model/SM-A536B/region/BTE/upload/Desc/0/10
- Download mode key combo and Odin4 on Linux: XDA thread
  "[RECOVERY][OFFICIAL] TWRP 3.7.1-12 for Galaxy A53 5G",
  https://xdaforums.com/t/recovery-unofficial-twrp-3-7-1-12-for-galaxy-a53-5g.4680051/
