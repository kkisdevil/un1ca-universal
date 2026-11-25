# Unlock the bootloader - Galaxy S20 FE (Snapdragon) (SM-G780G)

Unlock the bootloader once. It wipes the phone. This file is for
the SM-G780G only. Do not use it on any other model, including the
Exynos S20 FE (SM-G780F), which is a different device.

Note: the upstream UN1CA r8q target also accepts the 5G siblings
G781B, G781N and G7810 (see
`target/r8q/installer/assertions.edify`), but this guide covers
the SM-G780G only. US carrier models (for example Verizon
G781V/U/U1 variants) have locked bootloaders that cannot be
unlocked, so they cannot follow this guide at all.

## What unlocking costs

Read this before you start. There is no undo for the first two
items.

- The phone **wipes itself** once, during the unlock.
- Knox trips **permanently**. The Knox fuse changes from 0x0 to
  0x1 and cannot be returned. Samsung Pay and Secure Folder never
  come back. Flashing stock firmware does not untrip Knox.
- Widevine is expected to drop to L3 (no HD playback in apps that
  require L1). This is standard Samsung behaviour after Knox
  trips; it has not been separately verified on an r8q.
- Banking apps and Play Integrity can fail on an unlocked phone.
  UN1CA ships a Play Integrity Fix, but that is no guarantee for
  any particular app.
- You must **never relock the bootloader** with TWRP, Magisk, or
  any custom image installed. That bricks the phone.
- **Unlock while still on stock Android 13.** One UI 8 removes
  the OEM Unlocking toggle from Developer options in every
  region, so once the phone is on UN1CA (One UI 8) the toggle is
  gone. Do the unlock first, on the stock ROM.

## Prereqs

1. **Back up everything.** Photos, files, app data. Copy them off
   the phone and check you can open the copies. The unlock wipes
   the phone. The XDA All-in-One guide for this phone recommends
   Samsung Smart Switch or Google Drive for the backup.
2. **Back up EFS first if TWRP is already installed.** In TWRP,
   back up the EFS partition and keep a copy off the phone. EFS
   holds the IMEI and modem calibration. Losing it is very hard to
   recover from.
3. **Log out of Google and Samsung accounts** before unlocking, or
   Factory Reset Protection can lock you out of your own phone
   afterwards.
4. **Battery above 50%, ideally full.** A dead phone mid-flash is
   how bricks happen.
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G780G**. The service
   provider software version shows the CSC; the UN1CA donor
   region for this phone is **BTU** (UK and Ireland, unbranded).
   Do not unlock or flash anything in this repo on any other
   model.
6. A good USB data cable (charge-only cables will not work) and a
   USB port on the PC itself. No hubs, no front-panel ports.

## Steps

1. Do everything in Prereqs above first: backup, EFS, log out of
   accounts.
2. Enable Developer options: Settings, About phone, Software
   information, tap Build number 7 times. Then turn on **OEM
   unlocking** and **USB debugging**.
3. Power the phone fully off. Press and hold **Volume Up + Volume
   Down**, then connect the USB cable to the PC. A warning screen
   appears. Press **Volume Up** to continue into Download mode.
4. In Download mode, **long-press Volume Up** to unlock the
   bootloader. Confirm on screen. The phone wipes itself and
   reboots.
5. Set the phone up minimally (or skip setup). You only need adb
   working for the next steps.
6. Check: Settings, Developer options, **OEM unlocking** should
   now show as unlocked or greyed out, or read "Bootloader
   already unlocked".

## Verify

- Settings, Developer options: OEM unlocking shows as unlocked or
  greyed out.
- Boot into Download mode again (power off, hold Volume Up +
  Volume Down, connect USB). The screen shows the bootloader lock
  state (OEM Lock OFF).

## Troubleshooting

- **OEM unlocking is greyed out or missing.** The phone is likely
  carrier-locked, or the 7-day waiting period applies (Samsung
  enforces a wait after first setup on some firmwares). Wait it
  out. There is no supported bypass. US carrier models cannot be
  unlocked at all.
- **KG STATUS shows PRENORMAL in Download mode.** Odin will
  refuse to flash anything while this shows. Boot the phone into
  the system and complete setup first, then try again. The Magisk
  documentation (quoted in the r8q TWRP thread) says prenormal
  clears after 168 hours of uptime.
- **The phone asks for a Google or Samsung account after the
  wipe.** That is Factory Reset Protection. You logged out too
  late, or not at all. Sign in with the account that was on the
  phone before the wipe.
- **The phone bootloops after the unlock wipe.** Boot into stock
  recovery (power off, hold Volume Up + Power) and factory reset
  from there. If it still will not boot, flash the stock firmware:
  [flash-stock.md](flash-stock.md).

## Next step

Flash TWRP: [flash-twrp.md](flash-twrp.md).

## Sources

- XDA All-in-One guide for the Galaxy S20 FE, tested on SM-G780G
  (unlock, Knox fuse 0x0 to 0x1, backup advice, key combos):
  https://xdaforums.com/t/all-in-one-how-to-unlock-lock-bootloader-root-install-custom-recovery-rom-fix-bootloops-reflash-stock-rom-on-samsung-galaxy-s20-fe.4753793/
- Root and unlock guide for the S20 FE (Download mode combo,
  long-press Volume Up to unlock, OEM unlocking greyed out check):
  https://www.ytechb.com/how-to-root-samsung-galaxy-s20-fe-and-unlock-bootloader/
- US Snapdragon variants have locked bootloaders:
  https://www.androidinfotech.com/43848-root-samsung-galaxy-s20-fe-android-13-sm-g780f-g-magisk/
- UN1CA FAQ (3.x stays on Android 16 / One UI 8.0):
  https://github.com/salvogiangri/UN1CA/discussions/629
- One UI 8 removes the OEM Unlocking toggle in every region:
  https://flashouselab.net/en/2026/11/samsung-oem-unlocking-gone-android-16
- r8q target model coverage (G780G, G7810, G781B, G781N):
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/r8q/installer/assertions.edify
- UN1CA donor firmware is SM-G780G/BTU:
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/r8q/config.sh
  (line 11)
