# Flash TWRP - Galaxy M52 5G (SM-M526B / SM-M526BR)

Flash the custom recovery on the SM-M526B / SM-M526BR and keep it.
This file is for the SM-M526B and SM-M526BR only. Do not use it on
any other model.

## What TWRP is

TWRP is a custom recovery: the menu you boot into to install zips,
make backups, and wipe. Everything in this folder is flashed
through it. Every other procedure in this folder assumes it.

## Availability: unofficial only

There is **no official TWRP build for the m52xq**. A search of
twrp.me for this device returned no official device page. The
recovery for this phone is unofficial, by PauloWesley.

## Verified build

TWRP **3.7.0** for m52xq, from the XDA thread
"[RECOVERY][UNOFFICIAL] TWRP 3.7.0 for Galaxy M52 5G":
https://xdaforums.com/t/recovery-unofficial-twrp-3-7-0-for-galaxy-m52-5g.4538691/

- Kernel source:
  https://github.com/BlackMesa123/android_kernel_samsung_sm7325/tree/sep-14/twrp-12.1
  (Android 12.1 base).
- Device tree:
  https://github.com/paulowesll/android_device_samsung_m52xq-twrp
  (branch `twrp-12.1`).
- The image has **not** been verified against a reference build by
  us. No file-by-file check, fingerprint, build date, or hash for
  the TWRP tar is recorded here. TODO: download the tar from the
  XDA thread, record its exact filename, size and hash, and check
  the version string shown on the TWRP main screen after flashing.

## Prereqs

1. **Unlocked bootloader.** Do
   [unlock-bootloader.md](unlock-bootloader.md) first.
2. **Back up everything** and back up EFS in TWRP if it is already
   installed. Flashing TWRP itself does not wipe data, but the
   Format Data step below does.
3. **Log out of Google and Samsung accounts** before wiping, or
   Factory Reset Protection can lock you out afterwards.
4. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself. No hubs, no front-panel ports.
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-M526B** or **SM-M526BR**
   and the service provider software version must show the CSC
   for your region.

## What you need

- A Windows PC with the **Samsung USB Driver** installed (from
  Samsung: developer.samsung.com) and Samsung Smart Switch closed.
- **Odin3**. The XDA TWRP thread links Odin3 without pinning a
  version. The samfw firmware pages' generic instructions name
  Odin Tool 3.13.1. TODO: record the exact Odin version and its
  SHA-256 from the XDA Odin3 thread before flashing, and verify
  the hash. Odin is Windows-only. On Linux, `samloader-rs flash`
  speaks the same Odin protocol; the LineageOS wiki notes the
  m52xq recovery is flashed with samloader-rs from Download mode.
  Odin is a leaked internal tool, not officially distributed by
  Samsung, and its binary is never committed to our repos.
- `vbmeta_disabled_R.tar`: a disabled vbmeta, so the unsigned TWRP
  can boot. Named in the published m52xq guides below.
- The **TWRP tar** for m52xq, from the XDA thread above.
- `multidisabler`: run from TWRP's terminal (see step 7). It
  stops stock from re-encrypting or re-locking things after the
  flash. One published m52xq guide also mentions flashing a
  multidisabler zip; the terminal method is the one written out
  step by step in that guide, so it is the one used here.

## Steps

1. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
2. Open Odin **as administrator**. The `ID:COM` box turns blue and
   shows `Added!` when the phone is detected. If nothing appears,
   the driver, cable, or port is the problem. Do not proceed.
3. Flash `vbmeta_disabled_R.tar` in the **USERDATA** slot and click
   Start. This is the slot the published m52xq guide
   (getdroidtips) uses for the disabled vbmeta on this device.
   Note: this differs from the usual AP-slot vbmeta flash used on
   some other Samsung phones. TODO: confirm the USERDATA slot
   against the XDA thread's first post before flashing, since the
   thread itself could not be opened directly during research.
4. The device will boot into recovery mode prompting you to wipe
   data. Wipe data and reboot to Download mode again.
5. Open Odin and load the **TWRP tar in the AP slot** and flash
   it. Wait for PASS.
6. **The moment Odin shows PASS, boot straight into recovery. Do
   not let the phone boot to system.** While the phone is still
   plugged into the PC, hold **Volume Up + Power** until the TWRP
   logo appears. If the phone boots to system first, stock
   recovery gets restored and you have to flash TWRP again.
7. In TWRP, disable encryption with multidisabler: go to Advanced,
   Terminal, type `multidisabler`. If the vendor complains about
   free space, it will attempt to resize the vendor and ask you
   to run multidisabler again. Type `multidisabler` again until
   it reports `Finished.`
8. **Format Data:** Wipe, Format Data, type `yes`. This is a
   format, not a wipe. It removes encryption so TWRP and the ROM
   can use /data.
9. Reboot, System for a stock boot, or stay in TWRP for the next
   flash (root, GSI, UN1CA, or kernel).

## Verify

- Reboot to recovery (power off, hold Volume Up + Power, with USB
  connected). TWRP **3.7.0** opens. The version is shown on the
  main screen.
- In TWRP, /data mounts and Format Data completed without errors.

## Keeping TWRP: the rules

- A full stock AP flash is expected to **replace TWRP** with stock
  recovery, because Samsung stock AP tars contain `recovery.img`.
  TODO: confirm this for the m52xq AP tar by listing the tar
  contents before flashing; it has not been checked for this
  device yet. If it holds, the keep-TWRP routes are:
  1. Remove `recovery.img` from the AP tar before flashing
     (advanced: re-pack the tar and recompute the trailing MD5;
     the `.md5` suffix is only a checksum footer, not a
     signature), or
  2. Flash stock and then **immediately re-flash TWRP before the
     first boot into system** (steps 2 to 6 above, then boot
     straight into recovery).
- Never let a ROM's own updater touch recovery. Do not check any
  "update recovery on first boot" box. TODO: confirm whether this
  device has a broken recovery-update flow; it has not been
  verified on the m52xq.
- After any stock flash, re-flash TWRP before doing custom work
  again, and take a fresh TWRP backup (including EFS) once the
  phone is back on stock.
- /data decryption inside TWRP (FBE) is **unproven on this
  device**. Test a /data backup before relying on it. Keep your
  real backups on the system side.
- Do **not** follow a vbmeta-on-USERDATA variant blindly on other
  devices. On this device the USERDATA slot for
  `vbmeta_disabled_R.tar` is what the published m52xq guide
  uses, but it is still TODO to confirm it against the XDA
  thread's first post.

## Troubleshooting

- **Odin does not see the phone.** Reinstall the Samsung USB
  Driver, try another port (on the PC itself, not a hub) and
  another data cable. Confirm the phone is in Download mode, not
  just charging.
- **TWRP is gone after a boot.** You booted to system first.
  Re-flash from step 2 and boot straight to recovery this time.
- **Stuck on the Samsung logo after flashing.** Boot into recovery
  and Format Data again.
- **TWRP asks for a password or cannot mount /data.** That is the
  unproven FBE decryption. Format Data (step 8) removes
  encryption. If you need the data on /data, stop: back it up from
  the running system first, then format.

## Next step

Root the phone: [root.md](root.md). Or flash something:
[flash-stock.md](flash-stock.md),
[flash-gsi.md](flash-gsi.md), [flash-un1ca.md](flash-un1ca.md),
[flash-kernel.md](flash-kernel.md).

## Sources

- XDA thread "[RECOVERY][UNOFFICIAL] TWRP 3.7.0 for Galaxy M52
  5G", https://xdaforums.com/t/recovery-unofficial-twrp-3-7-0-for-galaxy-m52-5g.4538691/
  (TWRP 3.7.0, PauloWesley; unlock wipes data; Knox bit blown;
  Download mode key combination; reboot to recovery holding
  Power + Volume Up while plugged in; Format Data; kernel source
  BlackMesa123 android_kernel_samsung_sm7325 tree sep-14/twrp-12.1).
  Read via search results 2026-11-25; the thread itself could not
  be opened directly (XDA returned 403 to curl and the browser
  fetch was rate-limited), so the vbmeta slot and the exact
  first-post steps are TODO to re-check, as noted above.
- GetDroidTips, "Download TWRP Recovery for Samsung Galaxy M52
  5G",
  https://www.getdroidtips.com/twrp-recovery-galaxy-m52-5g/
  (vbmeta_disabled_R.tar in the USERDATA slot; TWRP tar in the AP
  slot; recovery key combo Volume Up + Power + USB connected;
  multidisabler in Advanced Terminal, run twice until
  `Finished.`; Wipe, Format Data, type `yes`; developer
  PauloWesley).
- TWRP device tree,
  https://github.com/paulowesll/android_device_samsung_m52xq-twrp
  (branch `twrp-12.1`).
- LineageOS wiki, m52xq info page,
  https://wiki.lineageos.org/devices/m52xq/ (not an A/B device;
  recovery partition `recovery`; recovery flashed with
  samloader-rs from Download mode).
- No official twrp.me device page for the m52xq was found in
  search on 2026-11-25; TWRP for this device is unofficial only.
