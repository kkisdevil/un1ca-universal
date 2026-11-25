# Flash TWRP - Galaxy S22+ (Snapdragon) (SM-S906E)

Flash the custom recovery on the Snapdragon Galaxy S22+ (g0q).
This file is for **SM-S906E, SM-S906N, SM-S9060** only. Do not use
it on any other model. SM-S906B is the Exynos model (g0s) and
nothing here applies to it.

## Status: no verified TWRP download exists today

Read this first, because it changes what this file can promise.

- There is **no official TWRP** for g0q. No device page for the
  S22+ was found on twrp.me (a search for the g0q page returned no
  twrp.me result, and a direct fetch of the twrp.me S22+ page
  failed). Do not assume an official build exists.
- The only TWRP for this device is the **unofficial** XDA thread
  "[CLOSED][RECOVERY][UNOFFICIAL] TWRP for Galaxy S22+
  (Snapdragon)", and that thread is **closed** (locked by a
  moderator on Dec 27, 2023). In the thread's first post the
  download links for the TWRP tar and the kernel are **struck
  through**, so the files the thread points to are no longer
  available from it.
- **No TWRP version, build date, or verified image exists for g0q
  in the sources read.** Until a working TWRP tar is found and
  checked, every procedure in this repo that needs TWRP (root
  Method B and C, UN1CA, custom kernel, full GSI flash) is
  blocked. The DSU trial in [flash-gsi.md](flash-gsi.md) does not
  need TWRP and can still run.

## What TWRP is

TWRP is a custom recovery: the menu you boot into to install zips,
make backups, and wipe. Everything else in this repo is flashed
through it, so finding a working build is the first unblocking job
for this device.

## What the XDA thread says (the only record)

- Supported models: Galaxy S22+ **S906E / S906N / S9060**.
- TWRP tar goes in Odin's **AP slot**. `vbmeta_disabled_R.tar`
  goes in Odin's **USERDATA slot**. (That USERDATA placement is
  unusual in general, but it is what this device's own thread
  instructs. It is not copied from any other device's guide.)
- Reboot to recovery with **Volume Up + Power, with the USB cable
  connected**.
- Disable encryption in TWRP: Advanced, Terminal, type
  `multidisabler`. If vendor complains about free space, it tries
  to resize vendor and asks you to run multidisabler again. Run it
  a second time until it prints `Finished`. Then Wipe, Format
  Data, type `yes`, and reboot to recovery.
- Then flash a custom kernel and the Magisk APK in TWRP, and
  reboot to system.
- Known bug: **encryption not fully working**.
- Note 1 in the thread: you need a **custom permissive kernel to
  boot with R/W vendor**.
- Note 2 in the thread: if you bootloop on the Samsung logo,
  reboot to TWRP and wipe metadata from the Advanced Wipe
  section.

## Verified build

TODO. No version number, build date, Android base, or kernel
version was found for a g0q TWRP build. The thread title only says
"Team Win Recovery Project 3.x". Do not write a version here
until a real file is in hand and checked.

## Prereqs

1. **Unlocked bootloader.** Do
   [unlock-bootloader.md](unlock-bootloader.md) first. US models
   (SM-S906U, SM-S906U1, SM-S906W) cannot unlock and cannot use
   this file.
2. **Back up everything** and back up EFS in TWRP if it is already
   installed. Flashing TWRP itself does not wipe data, but the
   Format Data step below does.
3. **Log out of Google and Samsung accounts** before wiping, or
   Factory Reset Protection can lock you out afterwards.
4. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself. No hubs, no front-panel ports.
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-S906E** (or SM-S906N, or
   SM-S9060).

## What you need

- A Windows PC with the **Samsung USB Driver** installed (from
  Samsung: developer.samsung.com) and Samsung Smart Switch closed.
- **Odin3 v3.14.1**. That is the version the S22+ root guide uses.
  SHA-256: TODO (verify from a trusted source; do not copy another
  device's hash). Odin is Windows-only. On Linux, `samloader-rs
  flash` speaks the same Odin protocol. Odin is a leaked internal
  tool, not officially distributed by Samsung, and its binary is
  never committed to our repos.
- `vbmeta_disabled_R.tar`: a disabled vbmeta, so the unsigned TWRP
  can boot. Named in the XDA TWRP thread below. Source link: TODO
  (the thread's download links are struck through).
- The **TWRP tar** for g0q, from the XDA thread
  "[CLOSED][RECOVERY][UNOFFICIAL] TWRP for Galaxy S22+
  (Snapdragon)":
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-s22-snapdragon.4453813/
  Source link: TODO (the thread's download links are struck
  through; no verified mirror was found).
- `multidisabler`: run from TWRP's own terminal on this device
  (see Steps), not flashed as a zip. It stops stock from
  re-encrypting things after the flash.

## Steps

These are the XDA thread's steps, written out. They cannot be
run end to end until a TWRP tar is found.

1. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
2. Open Odin **as administrator**. The `ID:COM` box turns blue and
   shows `Added!` when the phone is detected. If nothing appears,
   the driver, cable, or port is the problem. Do not proceed.
3. Load the **TWRP tar in the AP slot** and
   `vbmeta_disabled_R.tar` in the **USERDATA slot**, and flash.
   Wait for PASS.
4. **The moment Odin shows PASS, boot straight into recovery. Do
   not let the phone boot to system.** Hold **Volume Up + Power
   with the USB cable connected** until the TWRP logo appears. If
   the phone boots to system first, stock recovery gets restored
   and you have to flash TWRP again.
5. In TWRP, run **`multidisabler`** from Advanced, Terminal. Run
   it a second time if it asks. Wait for `Finished`.
6. **Format Data:** Wipe, Format Data, type `yes`. This is a
   format, not a wipe. It removes encryption so TWRP and the ROM
   can use /data.
7. Reboot to recovery, then reboot to System for a stock boot, or
   stay in TWRP for the next flash (root, GSI, UN1CA, or kernel).

## Verify

- Reboot to recovery (power off, hold Volume Up + Power with USB
  connected). TWRP opens. The version is shown on the main
  screen. TODO: record the version number once a real build is
  flashed.
- In TWRP, /data mounts and Format Data completed without errors.

## Keeping TWRP: the rules

- TODO: verify whether the stock g0q AP tar contains
  `recovery.img`. On Samsung phones it normally does, which would
  mean a full stock AP flash replaces TWRP, but that was not
  confirmed from a g0q AP listing. Until it is confirmed, treat a
  full stock flash as replacing TWRP, and re-flash TWRP before the
  first boot into system (steps 2 to 4 above, then boot straight
  into recovery).
- Never let a ROM's own updater touch recovery.
- After any stock flash, re-flash TWRP before doing custom work
  again, and take a fresh TWRP backup (including EFS) once the
  phone is back on stock.
- /data decryption inside TWRP is **not working** on this device
  (the thread lists "Encryption not fully working" as a bug).
  Format Data (step 6) removes encryption. If you need the data on
  /data, stop: back it up from the running system first, then
  format.

## Troubleshooting

- **Odin does not see the phone.** Reinstall the Samsung USB
  Driver, try another port (on the PC itself, not a hub) and
  another data cable. Confirm the phone is in Download mode, not
  just charging.
- **TWRP is gone after a boot.** You booted to system first.
  Re-flash from step 2 and boot straight to recovery this time.
- **Stuck on the Samsung logo after flashing.** Boot into recovery
  and wipe metadata from Advanced Wipe (the thread's Note 2),
  then Format Data again.
- **TWRP asks for a password or cannot mount /data.** That is the
  broken encryption on this device. Format Data (step 6) removes
  encryption.
- **"Custom Binary (Recovery) Blocked by OEM Lock" in Download
  mode.** The bootloader is not unlocked. Do
  [unlock-bootloader.md](unlock-bootloader.md) first: in Download
  mode, long-press Volume Up to unlock, do not just press it to
  enter.
- **No TWRP download can be found.** That is the current state of
  this device. Do not flash a TWRP tar for another codename (g0s,
  r0q, b0q) on g0q. Finding a working g0q build is an open task.

## Next step

Root the phone: [root.md](root.md). Or flash something:
[flash-stock.md](flash-stock.md),
[flash-gsi.md](flash-gsi.md), [flash-un1ca.md](flash-un1ca.md),
[flash-kernel.md](flash-kernel.md). All of those except the stock
flash and the DSU trial need a working TWRP first.

## Sources

- XDA thread "[CLOSED][RECOVERY][UNOFFICIAL] TWRP for Galaxy S22+
  (Snapdragon)" (supported models S906E/S906N/S9060, AP slot for
  the TWRP tar, USERDATA slot for vbmeta_disabled_R.tar, recovery
  combo with USB connected, multidisabler from the terminal run
  twice, Format Data yes, encryption bug, permissive kernel note,
  metadata wipe note, thread closed Dec 27, 2023, download links
  struck through, S906U1 not unlockable):
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-s22-snapdragon.4453813/
- No official TWRP: a web search for the g0q page on twrp.me
  returned no twrp.me result, and a direct fetch of
  https://twrp.me/samsung/samsunggalaxys22plus.html failed.
- Odin3 v3.14.1 as the version used for the S22+: AndroidBiits,
  "How to Root Samsung Galaxy S22 Plus (SM-S906B, SM-S906E,
  SM-S906N)",
  https://androidbiits.com/root-samsung-galaxy-s22-plus-sm-s906b-sm-s906e-sm-s906n-easily/
- "Custom Binary (Recovery) Blocked by OEM Lock" and the fix
  (long-press Volume Up in Download mode to unlock): replies in
  the XDA TWRP thread above.

## TODO

- Find a working TWRP tar for g0q and record its version, build
  date, source link, and SHA-256. The XDA thread's links are
  dead.
- Find a working `vbmeta_disabled_R.tar` source and record it.
- Verify the Odin3 v3.14.1 SHA-256 from a trusted source.
- Verify whether the stock g0q AP tar contains `recovery.img`.
- Verify the "boot straight into recovery" timing on this device
  once a real TWRP build is flashed.
