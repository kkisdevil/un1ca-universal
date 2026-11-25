# Unlock the bootloader - Galaxy A71 (SM-A715F)

Unlock the bootloader once. It wipes the phone. This file is for
the SM-A715F only. Do not use it on any other model. Do not use it
on the Galaxy A71 5G (SM-A716, codename a71xq): that is a different
phone.

## What unlocking costs

Read this before you start. There is no undo for the first two
items.

- The phone **wipes itself** once, during the unlock.
- Knox trips **permanently**. Samsung Pay and Secure Folder never
  come back. Flashing stock firmware does not untrip Knox.
- Widevine drops to L3 (no HD Netflix and no HD playback in apps
  that require L1).
- Banking apps and Play Integrity can fail on an unlocked phone.
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
   information: model must read **SM-A715F**. The Canadian variant
   is sold as SM-A715W. Do not unlock or flash anything in this
   repo on any other model. There is no single region for this
   device: the UN1CA target firmware is SM-A715F/ROM, and the
   latest stock builds differ by region (see
   [flash-stock.md](flash-stock.md)).
6. A good USB data cable (charge-only cables will not work) and a
   USB port on the PC itself. No hubs, no front-panel ports.

## Steps

1. Do everything in Prereqs above first: backup, EFS, log out of
   accounts.
2. Enable Developer options: Settings, About phone, tap Build
   number 7 times. Then turn on **OEM unlocking** and **USB
   debugging**.
3. Power the phone fully off. Press and hold **Volume Up + Volume
   Down**, then connect the USB cable to the PC. A warning screen
   appears. Press **Volume Up** to continue into Download mode.
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
  out. There is no supported bypass.
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

- Model SM-A715F / SM-A715W (4G LTE) and the unlock wipe warning:
  androidweblog.com guide "Root Samsung Galaxy A71 SM-A715 and
  Install TWRP Recovery 3.5.1" and droidwin.com "Install TWRP and
  Root Samsung Galaxy A71".
- A71 5G is a different device (SM-A716, codename a71xq): XDA
  thread "[RECOVERY][UNOFFICIAL] TWRP for Galaxy A71 5G
  (Snapdragon)".
- UN1CA target firmware SM-A715F/ROM:
  Arnav3078/UN1CA-SM7150@seventeen, `target/a71/config.sh:7`
  (identical in mehedihjoy0/UN1CA-SM7150@sixteen).
- The 7-day wait, Knox, and FRP behaviour are standard Samsung
  practice, not a71-specific measurements.
