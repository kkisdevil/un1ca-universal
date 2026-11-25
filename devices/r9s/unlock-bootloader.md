# Unlock the bootloader - Galaxy S21 FE 5G (SM-G990E)

Unlock the bootloader once. It wipes the phone. This file is for
the SM-G990E only (Exynos S21 FE 5G, codename r9s). Do not use it
on the Snapdragon FE (SM-G990B, SM-G990B2, SM-G990U) or any other
model.

## Read this first: One UI 8 removes the unlock option

Samsung removed the bootloader unlock option on devices that took
the One UI 8 (Android 16) update. A phone already on One UI 8 has
no OEM unlocking toggle to turn on, and there is no supported way
to unlock it afterwards. This is confirmed by the ExtremeROM build
guide ("As of September 2025, Samsung has removed the option to
unlock the bootloader on any device that got the OneUi 8 update",
listing the Galaxy S21 FE) and by an XDA thread where a G990E user
on build G990EXXSLHZA1 (One UI 8.0, Android 16) was told there is
no way to unlock the bootloader anymore.

- **Do NOT update to One UI 8 before unlocking.** Unlock while
  the phone is still on Android 15 (One UI 7) or older.
- UN1CA needs the last Android 15 bootloader anyway
  (G990EXXSIGYI3, see [flash-un1ca.md](flash-un1ca.md)), so the
  safe base is Android 15, not Android 16.
- TODO: no unlock method for a phone already on One UI 8 was found
  in this research pass. If one appears, it must be verified
  against a real device before it is written here.

## What unlocking costs

Read this before you start. There is no undo for the first two
items.

- The phone **wipes itself** once, during the unlock.
- Knox trips **permanently**. Samsung Pay and Secure Folder never
  come back. Flashing stock firmware does not untrip Knox. (The
  S21 FE is a Knox device; this is standard Samsung behaviour, as
  in the m51 docs.)
- Widevine drops to L3 (no HD Netflix and no HD playback in apps
  that require L1). Standard Samsung behaviour after an unlock.
- Banking apps and Play Integrity can fail on an unlocked phone.
- You must **never relock the bootloader** with TWRP, Magisk, or
  any custom image installed. That bricks the phone.

## Prereqs

1. **Check the phone is still on Android 15 or older.** Settings,
   About phone, Software information: if it already says Android
   16 / One UI 8.0, stop. See the warning above.
2. **Back up everything.** Photos, files, app data. Copy them off
   the phone and check you can open the copies. The unlock wipes
   the phone.
3. **Back up EFS first if TWRP is already installed.** In TWRP,
   back up the EFS partition and keep a copy off the phone. EFS
   holds the IMEI and modem calibration. Losing it is very hard to
   recover from. (Standard Samsung/TWRP practice, as in the m51
   docs. TODO: confirm the EFS backup entry exists in the r9s
   recovery build you use.)
4. **Log out of Google and Samsung accounts** before unlocking, or
   Factory Reset Protection can lock you out of your own phone
   afterwards.
5. **Battery above 50%, ideally full.** A dead phone mid-flash is
   how bricks happen.
6. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G990E** and the service
   provider software version must show your region (for example
   THL for Thailand, INS for India). Do not unlock or flash
   anything in this repo on any other model. SM-G990B is the
   Snapdragon FE: different SoC, different firmware, different
   recovery. The two must never be mixed up.
7. A good USB data cable (charge-only cables will not work) and a
   USB port on the PC itself. No hubs, no front-panel ports.

## Steps

1. Do everything in Prereqs above first: backup, EFS, log out of
   accounts. Confirm the phone is on Android 15 or older.
2. Enable Developer options: Settings, About phone, tap Build
   number 7 times. Then turn on **OEM unlocking** and **USB
   debugging**. (If OEM unlocking is missing entirely, the phone
   is already on One UI 8 or is carrier-locked. See
   Troubleshooting.)
3. Power the phone fully off. Press and hold **Volume Up + Volume
   Down**, then connect the USB cable to the PC. A warning screen
   appears. Press **Volume Up** to continue into Download mode.
   (Shared Samsung Download mode pattern, as in the m51 docs.)
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

- **OEM unlocking is greyed out or missing.** Three possible
  causes. (a) The phone is carrier-locked. (b) The 7-day waiting
  period applies (Samsung enforces a wait after first setup on
  some firmwares). Wait it out. (c) The phone is already on One
  UI 8 (Android 16), where Samsung removed the option entirely:
  there is no supported bypass and no waiting period fixes it.
  Check the Android version first so you know which case you are
  in.
- **The phone asks for a Google or Samsung account after the
  wipe.** That is Factory Reset Protection. You logged out too
  late, or not at all. Sign in with the account that was on the
  phone before the wipe.
- **The phone bootloops after the unlock wipe.** Boot into stock
  recovery (power off, hold Volume Up + Power) and factory reset
  from there. If it still will not boot, flash the stock firmware:
  [flash-stock.md](flash-stock.md).

## Next step

Flash a custom recovery: [flash-twrp.md](flash-twrp.md). Note the
UN1CA installer rejects afaneh92's TWRP, so read that file's
recovery choice before you flash anything.

## Sources

- Upstream identity: `salvogiangri/UN1CA`, branch `sixteen`,
  UN1CA 3.2.1, `target/r9s/config.sh` (read live 2026-11-25):
  `TARGET_FIRMWARE="SM-G990E/THL/355798871234563"`.
- One UI 8 unlock removal: ExtremeROM wiki Build Guide,
  https://github.com/ExtremeXT/ExtremeROM/wiki/Build-Guide
  ("As of September 2025, Samsung has removed the option to
  unlock the bootloader on any device that got the OneUi 8
  update", "For the Galaxy S21 FE this is GYI3
  (G990EXXSIGYI3)").
- XDA thread "Unlock bootloader G990E",
  https://xdaforums.com/t/unlock-bootloader-g990e.4781493/
  (user on G990EXXSLHZA1, One UI 8.0 Android 16, told there is
  no way to unlock the bootloader anymore; links the thread
  "Bootloader unlocking option removed from One UI 8.0",
  https://xdaforums.com/t/bootloader-unlocking-option-removed-from-one-ui-8-0.4751904/).
- Shared Samsung flow (Download mode combo, wipe, Knox,
  Widevine, FRP): `../m51/unlock-bootloader.md` in this repo
  (the m51 docs are the cited source for the shared Samsung
  behaviour, not for any r9s value).
