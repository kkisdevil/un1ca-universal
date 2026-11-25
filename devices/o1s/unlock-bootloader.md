# Unlock the bootloader - Galaxy S21 5G (SM-G991B)

Unlock the bootloader once. It wipes the phone. This file is for
the SM-G991B only. Do not use it on any other model. The
SM-G991B is the international Exynos 2100 variant; the
Snapdragon S21 models (SM-G9910/U/U1/W) are different devices
with different unlock rules, and US carrier models have no OEM
unlock toggle at all.

## What unlocking costs

Read this before you start. There is no undo for the first two
items.

- The phone **wipes itself** once, during the unlock.
- Knox trips **permanently**. Samsung Pay, Samsung Pass and
  Secure Folder never come back. Flashing stock firmware does not
  untrip Knox.
- Widevine drops to L3 (no HD Netflix and no HD playback in apps
  that require L1).
- Banking apps and Play Integrity can fail on an unlocked phone.
- OTA updates stop working once custom binaries are flashed.
- You must **never relock the bootloader** with TWRP, Magisk, or
  any custom image installed. That bricks the phone.

## Prereqs

1. **Back up everything.** Photos, files, app data. Copy them off
   the phone and check you can open the copies. The unlock wipes
   the phone.
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
   information: model must read **SM-G991B** and the service
   provider software version must show **AUT** (the region this
   folder's firmware record covers). Do not unlock or flash
   anything in this repo on any other model. TODO: confirm the
   exact service provider string shown on an AUT phone.
6. A good USB data cable (charge-only cables will not work) and a
   USB port on the PC itself. No hubs, no front-panel ports.
7. **Check the 7-day wait.** Samsung enforces a waiting period
   after first setup on some firmwares before the OEM unlocking
   toggle appears. If the toggle is missing, wait it out. There
   is no supported bypass. A date-change trick is reported in the
   XDA TWRP thread comments, but it is unverified and not
   recommended here.

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
   bootloader. Press Volume Up again to confirm. The phone wipes
   itself and reboots.
5. Set the phone up minimally (or skip setup). You only need adb
   working for the next steps.
6. Check: Settings, Developer options, **OEM unlocking** should
   now show as enabled and greyed out. `adb reboot bootloader`
   then `fastboot oem device-info` is not available on Samsung.
   The Download mode screen itself shows the lock state.

## Verify

- Settings, Developer options: OEM unlocking shows as enabled
  and greyed out.
- Boot into Download mode again (power off, hold Volume Up +
  Volume Down, connect USB). The screen shows the bootloader as
  unlocked.

## Troubleshooting

- **OEM unlocking is greyed out or missing.** The phone is likely
  carrier-locked (US/Canada models have no OEM unlock toggle), or
  the 7-day waiting period applies. Wait it out. There is no
  supported bypass.
- **The phone asks for a Google or Samsung account after the
  wipe.** That is Factory Reset Protection. You logged out too
  late, or not at all. Sign in with the account that was on the
  phone before the wipe.
- **The phone bootloops after the unlock wipe.** Boot into stock
  recovery (power off, connect USB to the PC, hold Volume Up +
  Power) and factory reset from there. If it still will not boot,
  flash the stock firmware: [flash-stock.md](flash-stock.md).

## Next step

Flash TWRP: [flash-twrp.md](flash-twrp.md). Read the warning
there first: the UN1CA installer refuses afaneh92's TWRP, so if
your goal is UN1CA, the recovery choice matters.

## Sources

- Unlock steps (key combo, long-press Volume Up, confirm, wipe,
  OEM unlocking greyed out afterwards): XDA BeyondROM thread,
  "[ROM] BeyondROM v8.4 [22/02/2026]-[HZA6]-[EXYNOS]-[SM-G99xB]",
  https://xdaforums.com/t/rom-beyondrom-v7-5-25-10-2024-gxh7-exynos-sm-g99xb.4254933/page-20
- Knox, Widevine L3, OTA loss: DroidWin, "Install TWRP Recovery
  on Galaxy S21 (Exynos) and S21 5G (Snapdragon)",
  https://droidwin.com/install-twrp-recovery-on-galaxy-s21/
- 7-day trick report and US/Canada no-toggle note: XDA TWRP
  thread comments,
  https://xdaforums.com/t/closed-recovery-unofficial-twrp-for-galaxy-s21-exynos.4241869/page-6
- Identity (SM-G991B, Exynos 2100, o1s): upstream
  `salvogiangri/UN1CA` branch `sixteen`, `target/o1s/config.sh`,
  read live 2026-11-25.
