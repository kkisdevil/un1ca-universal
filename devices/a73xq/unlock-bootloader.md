# Unlock the bootloader - Galaxy A73 5G (SM-A736B)

Unlock the bootloader once. It wipes the phone. This file is for
the SM-A736B only. Do not use it on any other model.

## What unlocking costs

Read this before you start. There is no undo for the first two
items.

- The phone **wipes itself** once, during the unlock.
- Knox trips **permanently**. Samsung Pay and Secure Folder never
  come back. Flashing stock firmware does not untrip Knox. The XDA
  TWRP thread for this phone states the Knox warranty bit is blown
  once a custom binary is flashed and cannot be reset in any way.
- Widevine drops to L3 (no HD Netflix and no HD playback in apps
  that require L1). This is the standard Samsung consequence of an
  unlocked bootloader; it has not been measured on this exact phone
  in this project, so treat it as expected, not proven here.
- Banking apps and Play Integrity can fail on an unlocked phone.
- You must **never relock the bootloader** with TWRP, Magisk, or
  any custom image installed. That bricks the phone.
- The international SM-A736B has a flexible bootloader that can be
  unlocked. Do not try this on a US carrier variant with a locked
  bootloader; those have no unlock route in the sources found.

## Prereqs

1. **Back up everything.** Photos, files, app data. Copy them off
   the phone and check you can open the copies. The unlock wipes
   the phone.
2. **Back up EFS first if TWRP is already installed.** In TWRP,
   back up the EFS partition and keep a copy off the phone. EFS
   holds the IMEI and modem calibration. Losing it is very hard to
   recover from. (If TWRP is not installed yet, this step does not
   apply; do it after [flash-twrp.md](flash-twrp.md) before any
   further flashing.)
3. **Log out of Google and Samsung accounts** before unlocking, or
   Factory Reset Protection can lock you out of your own phone
   afterwards.
4. **Battery above 50%, ideally full.** A dead phone mid-flash is
   how bricks happen.
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A736B** and the service
   provider software version must show your region code (the
   UN1CA target firmware for this phone is XME, Malaysia; the
   latest stock record in this folder is also XME). Do not unlock
   or flash anything in this repo on any other model.
6. A good USB data cable (charge-only cables will not work) and a
   USB port on the PC itself. No hubs, no front-panel ports.

## Steps

1. Do everything in Prereqs above first: backup, log out of
   accounts.
2. Enable Developer options: Settings, About phone, Software
   information, tap Build number 7 times. Then turn on **OEM
   unlocking** and **USB debugging**.
3. Power the phone fully off. Press and hold **Volume Up + Volume
   Down**, then connect the USB cable to the PC. A warning screen
   appears. Press **Volume Up** to continue into Download mode.
   (This key combination is the one given in the XDA TWRP thread
   for this phone, and it matches the LineageOS wiki entry for
   a73xq: hold Volume Up + Volume Down, then connect the USB
   cable.)
4. In Download mode, **long-press Volume Up** to unlock the
   bootloader. Confirm on screen. The phone wipes itself and
   reboots.
5. Set the phone up minimally (or skip setup). You only need adb
   working for the next steps.
6. Check: Settings, Developer options, **OEM unlocking** should now
   show as unlocked or greyed out. `adb reboot bootloader` then
   `fastboot oem device-info` is not available on Samsung. The
   Download mode screen itself shows the lock state.

## Verify

- Settings, Developer options: OEM unlocking shows as unlocked or
  greyed out.
- Boot into Download mode again (power off, hold Volume Up +
  Volume Down, connect USB). The screen shows the bootloader as
  unlocked.

## Troubleshooting

- **OEM unlocking is greyed out or missing.** The phone is likely
  carrier-locked, or the 7-day waiting period applies (Samsung
  enforces a wait after first setup on some firmwares). Wait it
  out. There is no supported bypass. Note: the LineageOS wiki page
  for a73xq carries a warning that an official method of unlocking
  the bootloader is not available and unofficial methods are not
  recommended or supported by LineageOS. The Samsung standard
  OEM-unlocking plus Download-mode flow above is the one the XDA
  TWRP thread for this phone documents, and it is the flow this
  folder uses. If your phone shows no OEM unlocking toggle at all,
  stop and do not force it.
- **The phone asks for a Google or Samsung account after the
  wipe.** That is Factory Reset Protection. You logged out too
  late, or not at all. Sign in with the account that was on the
  phone before the wipe.
- **The phone bootloops after the unlock wipe.** Boot into stock
  recovery (power off, hold Volume Up + Power while connected to
  a PC via USB) and factory reset from there. If it still will
  not boot, flash the stock firmware:
  [flash-stock.md](flash-stock.md).

## Next step

Flash TWRP: [flash-twrp.md](flash-twrp.md).

## Sources

- XDA TWRP thread for this phone (unlock steps, Knox warning):
  https://forum.xda-developers.com/t/recovery-unofficial-twrp-3-7-0-12-for-galaxy-a73-5g.4505971/
- LineageOS wiki, a73xq (boot modes, unlock warning):
  https://wiki.lineageos.org/devices/a73xq/
- Model and region check: Settings, About phone, Software
  information on the phone itself; UN1CA target firmware
  `SM-A736B/XME/352828291234563` in
  `target/a73xq/config.sh` line 13 of
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/a73xq/config.sh

## TODO

- TODO: Widevine L3 after unlock has not been measured on this
  exact phone in this project.
- TODO: confirm whether the 7-day OEM-unlock waiting period
  applies to current A736B firmware (bootloader C, 12).
