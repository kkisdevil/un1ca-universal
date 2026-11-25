# Unlock the bootloader - Galaxy S22 Ultra (SM-S908E)

Unlock the bootloader once. It wipes the phone. This file is for
the Galaxy S22 Ultra (Snapdragon), codename `b0q`, only. Do not
use it on any other model. In particular, do not use it on the
base Galaxy S22 (Snapdragon, SM-S901E, codename `r0q`): that is a different
phone, and the b0q target in the upstream UN1CA repo is the S22
Ultra, not the base S22.

## What unlocking costs

Read this before you start. There is no undo for the first two
items.

- The phone **wipes itself** once, during the unlock.
- Knox trips **permanently**. Samsung Pay and Secure Folder never
  come back. Flashing stock firmware does not untrip Knox. This
  is the standard Samsung rule for Knox devices, and the S22
  Ultra is a Knox device; the XDA TWRP thread for this phone
  opens with the matching "your warranty is now void" warning.
- Widevine drops to L3 (no HD Netflix and no HD playback in apps
  that require L1). TODO: confirm the L3 drop on this exact model
  after an unlock; it is the standard Samsung outcome, not yet
  checked on a b0q in front of us.
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
   information: model must read **SM-S908E**, **SM-S908N**, or
   **SM-S9080** (the Snapdragon S22 Ultra models the b0q TWRP
   supports). Do not unlock or flash anything in this folder on
   any other model. US carrier models (SM-S908U, SM-S908U1) have
   no OEM unlock toggle and cannot be unlocked; see
   Troubleshooting below.
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
4. In Download mode, **long-press Volume Up** (hold it for more
   than 7 seconds) to unlock the bootloader. Confirm on screen.
   The phone wipes itself and reboots.
5. Set the phone up minimally (or skip setup). You only need adb
   working for the next steps.
6. Check: Settings, Developer options, **OEM unlocking** should now
   show as unlocked or greyed out. Samsung has no fastboot
   `oem device-info`. The Download mode screen itself shows the
   lock state.

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
  out. There is no supported bypass. US models SM-S908U and
  SM-S908U1 have no OEM unlock toggle at all and cannot be
  unlocked; this is reported in the XDA b0q TWRP thread.
- **The phone asks for a Google or Samsung account after the
  wipe.** That is Factory Reset Protection. You logged out too
  late, or not at all. Sign in with the account that was on the
  phone before the wipe.
- **The phone bootloops after the unlock wipe.** Boot into stock
  recovery (power off, hold Volume Up + Power, with USB
  connected) and factory reset from there. If it still will not
  boot, flash the stock firmware:
  [flash-stock.md](flash-stock.md).

## Next step

Flash TWRP: [flash-twrp.md](flash-twrp.md).

## Sources

- Upstream target identity:
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/b0q/config.sh
  lines 5-13 (TARGET_NAME "Galaxy S22 Ultra (Snapdragon)",
  TARGET_CODENAME "b0q", TARGET_FIRMWARE "SM-S908E/TUR/...").
- Unlock steps (Download mode combo, long-press Volume Up):
  https://magiskzip.com/install-twrp-recovery-on-samsung-galaxy-s22-ultra/
  and https://droidwin.com/install-twrp-recovery-on-galaxy-s22-ultra-root-via-magisk/
- Supported Snapdragon models (S908E/S908N/S9080) and the
  warranty-void warning: XDA thread
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-s22-ultra-snapdragon.4453235/
  (afaneh92, closed Dec 2023).
- US models with no OEM unlock: same XDA thread, page 2
  discussion of SM-S908U1.
- Knox trip and Widevine L3 are the standard Samsung-wide
  outcomes for a Knox flagship; the L3 drop on this exact model
  is still TODO to confirm on device.
