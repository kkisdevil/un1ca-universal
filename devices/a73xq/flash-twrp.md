# Flash TWRP - Galaxy A73 5G (SM-A736B)

Flash the custom recovery on the SM-A736B and keep it. This file
is for the SM-A736B only. Do not use it on any other model.

## What TWRP is

TWRP is a custom recovery: the menu you boot into to install zips,
make backups, and wipe. Everything else in this folder is flashed
through it. Every other procedure in this folder assumes it.

## Official or unofficial

**Unofficial only.** No official TWRP page for the A73 5G was
found on twrp.me (a site-restricted search returned no result),
and the XDA thread is titled "[RECOVERY][UNOFFICIAL] TWRP
3.7.0-12 for Galaxy A73 5G". There is also a LineageOS recovery
for this phone (LineageOS supports a73xq officially, maintained
by Simon1511), but this folder uses TWRP because the UN1CA, GSI,
and kernel procedures here are written for TWRP. If you prefer
LineageOS recovery, follow the LineageOS wiki install guide
instead; do not mix the two recoveries in one procedure.

## Verified build

TWRP **3.7.0-12** (unofficial) for a73xq, from the XDA thread
linked below. Last edited 2023-05-11; changelog entry of the same
date adds support for Android 13 decryption with no password.
Kernel tree:
https://github.com/samsung-778/android_kernel_samsung_sm7325/tree/twrp-12.1
(Android 12.1 base). The thread credits the TWRP team, the
Samsung open source kernel, and BlackMesa123 for the device tree
and kernel of the Galaxy A52s.

**Not verified by us.** The image has not been checked
file-by-file against a reference build in this project, and no
fingerprint or build identifier of a verified image exists here.
The build is from May 2023, so it predates the current stock
firmware (Android 16, bootloader C, 12). See the troubleshooting
section before flashing it on a phone running current firmware.

## Prereqs

1. **Unlocked bootloader.** Do
   [unlock-bootloader.md](unlock-bootloader.md) first.
2. **Back up everything** and back up EFS in TWRP if it is already
   installed. Flashing TWRP itself does not wipe data, but the
   Format Data step below does.
3. **Log out of Google and Samsung accounts** before wiping, or
   Factory Reset Protection can lock you out afterwards.
4. **Battery above 50%, ideally full.** GetDroidTips says about
   60% for this phone. A good USB data cable and a USB port on
   the PC itself. No hubs, no front-panel ports.
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A736B** and the service
   provider software version must show your region code.

## What you need

- A Windows PC with the **Samsung USB Driver** installed (from
  Samsung: developer.samsung.com) and Samsung Smart Switch closed.
- **Odin3 v3.14.1** (the conservative choice used in the a73xq
  guides). Odin is Windows-only. On Linux, `samloader-rs flash`
  speaks the same Odin protocol; the LineageOS wiki for a73xq
  also documents flashing firmware with samloader-rs. Odin is a
  leaked internal tool, not officially distributed by Samsung,
  and its binary is never committed to our repos. Do not use any
  file claiming to be a newer Odin3 than v3.14.4. Odin3 v3.14.4 is
  disputed (same compile date as v3.14.1, older DLL, an unsigned
  DLL no component references, four different ZIPs circulating).
  We do not recommend it.
- `vbmeta_disabled.tar` (also named `vbmeta_disabled_R.tar` in
  the GetDroidTips guide): a disabled vbmeta, so the unsigned
  TWRP can boot. Named in the XDA TWRP thread.
- The **TWRP tar** for a73xq, from the XDA thread
  "[RECOVERY][UNOFFICIAL] TWRP 3.7.0-12 for Galaxy A73 5G":
  https://forum.xda-developers.com/t/recovery-unofficial-twrp-3-7-0-12-for-galaxy-a73-5g.4505971/
  (the thread also links a GitHub Action TWRP builder release
  by nguyenhung9xdev2022 for a73xq).
- `multidisabler`, named in the same guides. It stops stock from
  re-encrypting or re-locking things after the flash. The
  GetDroidTips guide runs it twice from Advanced, Terminal, and
  the XDA thread's install flow ends with a Format Data.

## Steps

1. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
2. Open Odin **as administrator**. The `ID:COM` box turns blue and
   shows `Added!` when the phone is detected. If nothing appears,
   the driver, cable, or port is the problem. Do not proceed.
3. Flash the disabled vbmeta first, then the TWRP tar in the **AP
   slot**. Wait for PASS after each flash. The GetDroidTips guide
   for this phone puts `vbmeta_disabled_R.tar` in the **USERDATA
   slot**; that is unusual and unverified, and this folder does
   not recommend it. The XDA thread itself says to select the
   TWRP tar in Odin without naming the vbmeta slot in the text
   that could be read here.
4. **The moment Odin shows PASS, boot straight into recovery. Do
   not let the phone boot to system.** While still plugged into
   the PC, hold **Volume Up + Power** until the TWRP logo
   appears. If the phone boots to system first, stock recovery
   gets restored and you have to flash TWRP again.
5. In TWRP, run **`multidisabler`**: Advanced, Terminal, type
   `multidisabler`, run it, and run it again until it reports
   finished (the GetDroidTips guide runs it twice).
6. **Format Data:** Wipe, Format Data, type `yes`. This is a
   format, not a wipe. It removes encryption so TWRP and the ROM
   can use /data. The XDA thread says to format data again after
   TWRP first boots, before booting into system.
7. Reboot, System for a stock boot, or stay in TWRP for the next
   flash (root, GSI, UN1CA, or kernel).

## Verify

- Reboot to recovery (power off, hold Volume Up + Power while
  connected to a PC via USB). TWRP **3.7.0-12** opens. The version
  is shown on the main screen.
- In TWRP, /data mounts and Format Data completed without errors.

## Keeping TWRP: the rules

- A full stock AP flash **replaces TWRP** with stock recovery
  (the stock AP tar contains `recovery.img`; the a73xq is not an
  A/B device, so its recovery image goes to the recovery
  partition). To keep TWRP, either remove `recovery.img` from
  the AP tar before flashing (advanced: re-pack the tar and
  recompute the trailing MD5; the `.md5` suffix is only a checksum
  footer, not a signature), or flash stock and then **immediately
  re-flash TWRP before the first boot into system** (steps 2 to 4
  above, then boot straight into recovery).
- Never let a ROM's own updater touch recovery.
- After any stock flash, re-flash TWRP before doing custom work
  again, and take a fresh TWRP backup (including EFS) once the
  phone is back on stock.
- /data decryption inside TWRP: the May 2023 changelog says this
  build supports Android 13 decryption with no password, but
  decryption on current Android 16 firmware is **unproven**.
  Test a /data backup before relying on it. Keep your real
  backups on the system side.

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
  unproven decryption on current firmware. Format Data (step 6)
  removes encryption. If you need the data on /data, stop: back
  it up from the running system first, then format. XDA thread
  comments also report that this recovery has trouble with f2fs
  and encryption on newer One UI versions, and one commenter
  warns against using an Android 12 bootloader on One UI 5 to
  work around it. Do not downgrade the bootloader to fix TWRP.
- **TWRP was built in 2023 and the phone is on Android 16.**
  That is a real risk, not a formality. If TWRP 3.7.0-12 will not
  boot or cannot decrypt on bootloader C firmware, stop and
  report it; do not flash an older bootloader. A newer TWRP or
  the LineageOS recovery may be needed, and neither is verified
  in this folder yet.

## Next step

Root the phone: [root.md](root.md). Or flash something:
[flash-stock.md](flash-stock.md),
[flash-gsi.md](flash-gsi.md), [flash-un1ca.md](flash-un1ca.md),
[flash-kernel.md](flash-kernel.md).

## Sources

- XDA thread, TWRP 3.7.0-12 unofficial for a73xq (version,
  changelog, kernel tree, install steps):
  https://forum.xda-developers.com/t/recovery-unofficial-twrp-3-7-0-12-for-galaxy-a73-5g.4505971/
- GetDroidTips, TWRP for Galaxy A73 5G (developer
  nguyenhung9x2018, vbmeta USERDATA claim, multidisabler steps):
  https://www.getdroidtips.com/twrp-recovery-galaxy-a73-5g/
- LineageOS wiki, a73xq (recovery boot mode, samloader-rs):
  https://wiki.lineageos.org/devices/a73xq/
- thecustomrom.com, a73xq (LineageOS official, maintainer
  Simon1511, not an A/B device):
  https://thecustomrom.com/devices/samsung/a73xq
- No official twrp.me device page for the A73 5G was found
  (site-restricted search on 2026-11-25 returned no result).

## TODO

- TODO: Odin3 v3.14.1 SHA-256 was not verified from a trusted
  source in this session. Verify it independently before use;
  the m51 hash was deliberately not copied here.
- TODO: the exact Odin slot for the disabled vbmeta on this
  phone is not established. The XDA thread text readable here
  does not name it, and the GetDroidTips USERDATA-slot claim is
  unusual and unverified. Verify against a real Odin run.
- TODO: TWRP 3.7.0-12 has not been verified against a reference
  build, and has not been tested on current Android 16 /
  bootloader C firmware.
- TODO: confirm whether the stock AP tar for the current CGZK3
  firmware contains `recovery.img` (expected yes, not checked
  against a downloaded copy).
