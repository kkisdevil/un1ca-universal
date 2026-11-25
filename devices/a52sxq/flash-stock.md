# Flash the stock ROM - Galaxy A52s 5G (SM-A528B)

Return the SM-A528B to official Samsung firmware with Odin. This
file is for the SM-A528B only. Do not use it on any other model.
The region covered here is **BTU (UK unbranded)**, because that is
the region of the UN1CA target firmware (upstream
`target/a52sxq/config.sh` line 13: `SM-A528B/BTU/...`). If your
phone is another CSC, use that CSC's package, not this one.

## When to use this

- Return the phone to stock: unbrick, undo a bad flash, prepare it
  for sale or service.
- Get a known-good base before custom work (UN1CA or HyperOS).
  The UN1CA XDA thread requires an Android 14 bootloader before
  flashing UN1CA.
- Fix a bootloop or a broken system when TWRP alone cannot.

Flashing stock firmware **removes root, custom ROMs, and custom
recoveries** (see "Keeping TWRP" below) and **wipes data if you use
the CSC file**. It does **not** untrip Knox. A tripped Knox bit is
permanent, and flashing stock does not restore Samsung Pay or
Secure Folder on a tripped phone.

## What you are flashing

| Field | Value |
|---|---|
| Model / region | SM-A528B / **BTU (UK unbranded)**, CSC `A528BOXMBGYI3` |
| PDA / AP | `A528BXXSBGYI3` |
| Modem / CP | `A528BXXSBGYI3` |
| Build number | `UP1A.231005.007.A528BXXSBGYI3` |
| Android / One UI | Android 14 / One UI 6.1, security patch 2025-09-01, changelist 28579955 |
| Build date | 2025-09-11 |
| Bootloader | **B (11)**: after this flash, no firmware with bootloader A (10) or lower will install (anti-rollback) |
| Server file | TODO: exact server filename and byte size for the BTU GYI3 package |
| MD5 | TODO |
| SHA-256 | TODO |

How each value was checked: the PDA, CSC, modem, build date, and
security patch for BTU GYI3 come from a Chimera log of an SM-A528B
with Sales Code BTU running A528BXXSBGYI3 (PDA, phone, and CSC
versions all GYI3, build date Thu Sep 11 17:07:54 KST 2025,
Android 14 UP1A.231005.007, SDK 34). The changelist 28579955 and
the Sep 11 2025 build date are confirmed across SamFrew listings
for the same PDA in many regions. The bootloader binary B (11)
comes from samfirm.shop: newer SM-A528B builds use bootloader
binary B (11), latest A528BXXSBGYI4, and a phone already on binary
B cannot flash binary A builds such as A528BXXUAGXK8. The build
number string follows the standard Samsung pattern
(UP1A.231005.007 + PDA) and matches the same pattern recorded for
the SIO GYA2 build; it was not read off a BTU phone in this
session, so treat it as to be confirmed on first flash.

This is the latest official firmware for BTU found in this
research, as of 2026-11-25. Note the naming: some regions list
A528BXXSBGYI4 as latest (for example PNT, CHO, ARO), while BTU and
most European regions list A528BXXSBGYI3. GYI4 is a regional
variant of the same September 2025 release, not a newer Android
version. Do not flash GYI4 on a BTU phone on the assumption it is
newer. TODO: download the BTU GYI3 package (from Samsung servers
via samloader, or a firmware mirror), record the exact server
filename, byte size, MD5, and SHA-256, and verify the hashes
before flashing. No Drive mirror exists for this device in this
repo yet.

## Prereqs

1. **A Windows PC.** Odin is Windows-only. On Linux,
   `samloader-rs flash` speaks the same Odin protocol. That route
   is not covered step-by-step here.
2. **Samsung USB Driver** for mobile phones, installed on the PC
   (from Samsung: developer.samsung.com). Without it Odin will not
   see the phone. Close Samsung Smart Switch before flashing.
3. **Odin3 v3.14.1** (the conservative choice). Extract it into
   its own folder and keep the EXE and DLLs together. Run it as
   administrator. Odin is a leaked internal tool, not officially
   distributed by Samsung, and its binary is **never committed to
   our repos**. TODO: verify the Odin ZIP SHA-256 from a trusted
   source in this session. Do not copy any hash from another
   device's guide without checking it. Do not use any file
   claiming to be a newer Odin3 than v3.14.4.
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
   information: model must read **SM-A528B** and the service
   provider software version must show **BTU** (or your own CSC
   if you are using another region's package). Do not flash this
   package on any other model or region.

## The 5 files in the firmware zip

A Samsung firmware zip for this device contains five `.tar.md5`
files. The exact filenames for the BTU GYI3 package are TODO
(record them when the package is downloaded); the pattern below
is the standard Samsung pattern, confirmed in structure by the
SamFrew download page for the SIO GYA2 build, which lists BL, AP,
CP, CSC, and HOME_CSC files. Odin verifies each file's trailing
MD5 before flashing.

| File | Odin slot | What it is |
|---|---|---|
| `BL_A528BXXSBGYI3_...tar.md5` | **BL** | Bootloader |
| `AP_A528BXXSBGYI3_...tar.md5` | **AP** | System (largest file; takes minutes to load). Contains `boot.img`, `recovery.img`, `system.img`, `vendor.img` |
| `CP_A528BXXSBGYI3_...tar.md5` | **CP** | Modem / baseband |
| `CSC_OXM_A528BOXMBGYI3_...tar.md5` | **CSC** | Region data. **Wipes the phone** (factory reset) |
| `HOME_CSC_OXM_A528BOXMBGYI3_...tar.md5` | **CSC** | Same region data. **Keeps your apps and data** |

Load all five files from the **same** package. Never mix files from
different builds or regions. Note the CSC prefix OXM is the
multi-CSC set that contains BTU; TODO: confirm the exact CSC
filename prefix in the downloaded BTU package, since it may read
`CSC_OXM_` or `CSC_BTU_` depending on the mirror.

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
   `UP1A.231005.007.A528BXXSBGYI3`.

## Verify

- Settings, About phone, Software information: build number reads
  `UP1A.231005.007.A528BXXSBGYI3`.
- The phone has signal and the region features match BTU.
- If you flashed CSC (wipe), the phone boots to fresh setup. If
  you flashed HOME_CSC, your apps and data are still there.

## Keeping TWRP through a stock flash

Flashing the full stock AP **replaces TWRP** with the stock
recovery, because the stock AP tar contains `recovery.img`. TODO:
confirm by listing the BTU GYI3 AP tar in this session; this is
standard Samsung behaviour, stated here on that basis.

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
  download (re-check the firmware hashes), a bad cable, or the
  battery dying mid-flash. Re-enter Download mode and try again
  with a verified download.
- **`SW REV CHECK FAIL`.** The bootloader in the package is older
  than the one on the phone (anti-rollback). This GYI3 package is
  bootloader B (11). You cannot flash it over a phone already on
  a newer bootloader, and after flashing it you cannot go back to
  bootloader A (10) or lower. The older A528BXXUAGXK8 build is
  bootloader A (10): it cannot be flashed on a phone already on
  GYI3.
- **Stuck on the Samsung logo or bootloop after flashing.** Boot
  into recovery (Volume Up + Power, with USB connected) and wipe
  cache, then factory reset from stock recovery if needed. If it
  still will not boot, re-flash the full package with the **CSC**
  file (wipe).
- **Phone boots but has no signal or wrong region features.** The
  CSC does not match the phone. Re-flash with the correct BTU
  package.
- **TWRP is gone after the flash.** Expected. See "Keeping TWRP"
  above. Re-flash the TWRP tar via Odin.

## Sources

- SamFrew SM-A528B firmware listings (A528BXXSBGYI3, Android 14,
  build Sep 11 2025, changelist 28579955, across regions):
  https://samfrew.com/devices/galaxy-a52s-5g/sm-a528b
- SamFrew SIO A528BXXSAGYA2 download record (BL/AP/CP/CSC/
  HOME_CSC file structure, bootloader A (10), kernel 5.4.254):
  https://samfrew.com/download/Galaxy__A52s__5G__/kjen/SIO/A528BXXSAGYA2/A528BOXMAGYA2
- samfirm.shop A528BXXUAGXK8 record (bootloader binary A (10),
  newer builds use binary B (11), latest A528BXXSBGYI4):
  https://samfirm.shop/build/A528BXXUAGXK8
- Chimera log for SM-A528B BTU on A528BXXSBGYI3 (PDA, phone, CSC
  A528BOXMBGYI3, build date Sep 11 2025, security patch
  2025-09-01): https://www.martview-forum.com/threads/samsung-a52s-5g-sm-a528b-bypass-knoxguard-android-14.167037/
- SamFirms ILP GYI3 listing (7.32 GB, updated 2025-09-30, for
  size comparison only; not the BTU package):
  https://samfirms.com/firmware/SM-A528B/ILP
- Upstream `target/a52sxq/config.sh` line 13 (BTU target
  firmware): https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/a52sxq/config.sh
- TODO: BTU GYI3 server filename, byte size, MD5, SHA-256.
  TODO: exact CSC filename prefix in the BTU package. TODO:
  confirm the AP tar contains recovery.img by listing it.
  TODO: confirm the build number string on a BTU phone after
  flashing.
