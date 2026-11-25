# Flash the stock ROM - Galaxy S22 (SM-S901E)

Return the SM-S901E to official Samsung firmware with Odin. This
file is for the Galaxy S22 (Snapdragon), codename `r0q`, models
SM-S901E, SM-S901N, and SM-S9010 only. Do not use it on the Exynos
Galaxy S22 (SM-S901B, codename `r0s`) or on the US models
SM-S901U, SM-S901U1, and SM-S901W with firmware for another model.
Flash only firmware for your own exact model and region.

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
| Model / region | SM-S901E / **OXM multi-CSC** (includes TUR, the UN1CA target region; see note below) |
| PDA / AP | `S901EXXSEGZH4` |
| Modem / CP | `S901EXXSEGZH4` |
| CSC | `S901EOXMEGZH4` |
| Build number | TODO: not yet verified for this build (pattern suggests `BP2A.250605.031.A3.S901EXXSEGZH4`, unconfirmed) |
| Android / One UI | Android 16 / One UI 8.0, patch 2026-08-05, changelist 31998945 |
| Build date | 2026-08-18 |
| Bootloader | **E (14)**: after this flash, no firmware with bootloader D or lower will install (anti-rollback) |
| Server file | TODO: exact server filename and byte size not yet recorded for this build |
| MD5 | TODO |
| SHA-256 | TODO |

This is the latest S901E build found in the firmware records
checked 2026-11-25: SamFrew lists `S901EXXSEGZH4` (Android 16,
Aug 18, 2026, changelist 31998945) as the newest build for many
S901E regions (including COO, STH, CDR, THL, CHX, PNT, CHT, CHL,
XTC, XFE, NPL), and the INS record gives the CSC
`S901EOXMEGZH4`, modem `S901EXXSEGZH4`, security patch 2026-08-05,
and size 9,683,601,232 B. **TUR check still owed:** the last build
explicitly listed under region TUR on SamFrew is the older
`S901EXXUCGYJ1` (Android 16, build 2025-10-16, CSC
`S901EOXMCGYJ1`, 9,678,613,808 B, bootloader C (12)). Confirm
whether `S901EXXSEGZH4` is released for TUR before flashing it on
a TUR phone, and record the downloaded file's name, size, MD5,
and SHA-256 here. Do not flash a file whose hash does not match a
recorded value. No Drive mirror for this firmware exists in this
project yet.

## Prereqs

1. **A Windows PC.** Odin is Windows-only. On Linux,
   `samloader-rs flash` speaks the same Odin protocol, and
   Heimdall 2.1.0 is another route. Those routes are not covered
   step-by-step here.
2. **Samsung USB Driver** for mobile phones, installed on the PC
   (from Samsung: developer.samsung.com). Without it Odin will not
   see the phone. Close Samsung Smart Switch before flashing.
3. **Odin3 v3.14.1** (the conservative choice). Size 2,595,015
   bytes, SHA-256
   `638296a11b1bfa954991b0597214d833511b973480ae9e15e299a761fea1f794`,
   verified against the checksum published by
   https://getodintool.com/ (file check November 5, 2026). Verify
   before opening it, in PowerShell:
   `Get-FileHash .\Odin3-v3.14.1.zip -Algorithm SHA256`.
   Extract it into its own folder and keep the EXE and DLLs
   together. Run it as administrator. Odin is a leaked internal
   tool, not officially distributed by Samsung, and its binary is
   **never committed to our repos**. Odin3 v3.14.4 is disputed
   (the XDA patched-Odin thread states all v3.14.4 builds are
   fake). We do not recommend it. Do not use any file claiming to
   be a newer Odin3 than v3.14.4.
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
   information: model must read **SM-S901E** (or SM-S901N or
   SM-S9010) and the firmware you downloaded must be for that
   exact model and region.

## The files in the firmware zip

A Samsung firmware zip for this device contains five `.tar.md5`
files:

| File | Odin slot | What it is |
|---|---|---|
| `BL_...tar.md5` | BL | Bootloader |
| `AP_...tar.md5` | AP | System, vendor, boot, recovery |
| `CP_...tar.md5` | CP | Modem (baseband) |
| `CSC_...tar.md5` | CSC | Region data. **Wipes data.** |
| `HOME_CSC_...tar.md5` | CSC | Region data. **Keeps data.** |

Use CSC for a clean flash (unbrick, return to stock, change
region data). Use HOME_CSC only when you want to keep your data
and you are already on a compatible build. Never load CSC and
HOME_CSC at the same time: the CSC slot takes one file.

## Steps

1. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
2. Open Odin **as administrator**. The `ID:COM` box turns blue and
   shows `Added!` when the phone is detected. If nothing appears,
   the driver, cable, or port is the problem. Do not proceed.
3. Load BL, AP, CP, and CSC (or HOME_CSC) into the slots with the
   same names. Wait for Odin to check the MD5 of each file before
   pressing Start.
4. Odin options: leave **Auto Reboot** and **F. Reset Time**
   ticked. Leave **Re-Partition** unticked. Never tick it unless a
   guide for this exact device tells you to and supplies a PIT
   file.
5. Click Start and wait for PASS. The phone reboots by itself.
   First boot takes several minutes.
6. Check Settings, About phone, Software information: the build
   number must match the firmware you flashed
   (`S901EXXSEGZH4` or the TUR build you used instead).

## Verify

- Build number in Settings matches the flashed firmware.
- The phone has signal and the region features match your CSC.
- `adb shell getprop ro.boot.bootloader` shows the new bootloader
  version (E for `S901EXXSEGZH4`).

## Keeping TWRP through a stock flash

- A full stock AP flash **replaces TWRP** with stock recovery (the
  stock AP tar contains `recovery.img`). TODO: confirm
  `recovery.img` is present in an actual r0q AP tar. To keep
  TWRP, either remove `recovery.img` from the AP tar before
  flashing (advanced: re-pack the tar and recompute the trailing
  MD5; the `.md5` suffix is only a checksum footer, not a
  signature), or flash stock and then **immediately re-flash TWRP
  before the first boot into system** (see
  [flash-twrp.md](flash-twrp.md), then boot straight into
  recovery).
- Recovery key combination: power off, hold **Volume Up + Power**
  (with USB connected, per the r0q XDA TWRP thread).

## Troubleshooting

- **Odin does not detect the phone.** Reinstall the Samsung USB
  Driver, try another port (on the PC itself, not a hub) and
  another data cable. Confirm the phone is in Download mode, not
  just charging.
- **Odin shows FAIL.** Check the firmware is for your exact model
  (SM-S901E, not SM-S901B or SM-S901U). Check the files loaded
  into the right slots. Try another USB port and cable.
- **`SW REV CHECK FAIL`.** Anti-rollback: you tried to flash
  firmware with a bootloader older than the one on the phone. The
  phone on `S901EXXSEGZH4` (bootloader E, 14) will not accept
  bootloader D or lower. Flash the same or a newer build.
- **Stuck on logo or bootloop after flashing.** Boot into stock
  recovery (Volume Up + Power) and factory reset from there.
- **No signal or wrong region features.** You flashed the wrong
  CSC. Re-flash with the CSC for your region.
- **TWRP is gone after the flash.** Expected: the stock AP
  replaces it. Re-flash TWRP before the first boot into system
  (see "Keeping TWRP" above).

## Sources

- Latest build `S901EXXSEGZH4`, build date, changelist, regions:
  SamFrew SM-S901E firmware lists,
  https://samfrew.com/firmware/model/SM-S901E/region/COO/upload/Desc/0/10
  and https://samfrew.com/firmware/model/SM-S901E/upload/Desc/80/10
  (checked 2026-11-25)
- INS record (CSC `S901EOXMEGZH4`, modem, patch 2026-08-05,
  size 9,683,601,232 B, release Sep 8, 2026):
  https://samsungcarecentre.com/downloads/samsung/galaxy-s22/firmware/stock-rom-s901exxsegzh4/
- TUR record (last TUR-listed build `S901EXXUCGYJ1`, Oct 16,
  2025, 9,678,613,808 B):
  https://samfrew.com/download/Galaxy__S22__/8zqm/TUR/S901EXXUCGYJ1/S901EOXMCGYJ1
- Zip contents (BL, AP, CP, CSC, HOME_CSC) and install steps:
  SamFrew firmware page,
  https://samfrew.com/download/Galaxy__S22__/jbfj/XAC/S901WVLSAGZE3/S901WOYVAGZE3
- Odin3 v3.14.1 size and SHA-256: https://getodintool.com/
  (file check November 5, 2026). v3.14.4 fake warning: XDA
  patched-Odin thread, https://xdaforums.com/t/3762572
- TODO: TUR availability of `S901EXXSEGZH4`, the exact server
  filename, the build number string, and the MD5/SHA-256 of a
  downloaded copy are all still owed. No firmware has been
  downloaded or flashed by us.
