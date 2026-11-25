# Unlock the bootloader - Galaxy A52s 5G (SM-A528B)

Unlock the bootloader once. It wipes the phone. This file is for
the SM-A528B only. Do not use it on any other model, and do not
use it on the SM-A528N (the Korean variant, codename a52sxqks):
the UN1CA XDA thread lists it as a separate supported variant,
but every step below was written for the SM-A528B.

## What unlocking costs

Read this before you start. There is no undo for the first two
items.

- The phone **wipes itself** once, during the unlock.
- Knox trips **permanently**. The A52s has Knox (a Chimera log
  for an SM-A528B on BTU firmware records Knox v30). Samsung Pay
  and Secure Folder never come back. Flashing stock firmware does
  not untrip Knox.
- Widevine drops to L3 on Samsung phones after unlock (no HD
  Netflix and no HD playback in apps that require L1). This is
  Samsung-wide behaviour, not yet confirmed on this exact phone
  in front of us: see TODO in Sources.
- Banking apps and Play Integrity can fail on an unlocked phone.
  The Droidwin A52s TWRP guide says the same: Knox will be
  tripped and many banking and payment apps might not work,
  including Samsung Pay.
- You must **never relock the bootloader** with TWRP, Magisk, or
  any custom image installed. That bricks the phone.

## Prereqs

1. **Back up everything.** Photos, files, app data. Copy them off
   the phone and check you can open the copies. The unlock wipes
   the phone.
2. **Back up EFS first if TWRP is already installed.** In TWRP,
   back up the EFS partition and keep a copy off the phone. EFS
   holds the IMEI and modem calibration. Losing it is very hard to
   recover from. EFS dumps for this model exist (azrom.net lists
   SM-A528B EFS backup files), so the partition exists on this
   device.
3. **Log out of Google and Samsung accounts** before unlocking, or
   Factory Reset Protection can lock you out of your own phone
   afterwards.
4. **Battery above 50%, ideally full.** A dead phone mid-flash is
   how bricks happen.
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A528B**. The service
   provider software version shows your CSC (for example BTU for
   the UK unbranded region used by the UN1CA target firmware).
   The UN1CA target firmware is `SM-A528B/BTU/352599501234566`
   (upstream `target/a52sxq/config.sh` line 13). Do not unlock or
   flash anything in this folder on any other model.
6. A good USB data cable (charge-only cables will not work) and a
   USB port on the PC itself. No hubs, no front-panel ports.

## Steps

1. Do everything in Prereqs above first: backup, EFS, log out of
   accounts.
2. Enable Developer options: Settings, About phone, Software
   information, tap Build number 7 times. Then turn on **OEM
   unlocking** and **USB debugging**. This path is confirmed for
   the A52s in the Android Infotech and GetDroidTips root guides.
3. Power the phone fully off. Press and hold **Volume Up + Volume
   Down**, then connect the USB cable to the PC. A warning screen
   appears. Press **Volume Up** to continue into Download mode.
   This is the standard Samsung key combination, confirmed for
   the A52s in the Android Infotech root guide.
4. In Download mode, **long-press Volume Up** to unlock the
   bootloader. Confirm on screen. The phone wipes itself and
   reboots. TODO: confirm the exact on-screen wording on this
   device. One A52s guide (Droidwin) describes this step as a
   single Volume Up press rather than a long press; follow what
   the warning screen itself says.
5. Set the phone up minimally (or skip setup). You only need adb
   working for the next steps.
6. Check: Settings, Developer options, **OEM unlocking** should now
   show as unlocked or greyed out. `fastboot oem device-info` is
   not available on Samsung. The Download mode screen itself
   shows the lock state.

## Verify

- Settings, Developer options: OEM unlocking shows as unlocked or
  greyed out.
- Boot into Download mode again (power off, hold Volume Up +
  Volume Down, connect USB). The screen shows the bootloader as
  unlocked.

## Troubleshooting

- **OEM unlocking is greyed out or missing.** The phone is likely
  carrier-locked, or the 7-day waiting period applies (Samsung
  enforces a wait after first setup on some firmwares). XDA has
  A52s threads titled "OEM Unlocking Not Showing" and "No OEM
  unlock option for my A52s (SM-A528B/DS)". Wait it out. There is
  no supported bypass. TODO: read those threads and record
  whether any A52s-specific cause (for example a carrier or
  KnoxGuard lock) was confirmed.
- **The phone asks for a Google or Samsung account after the
  wipe.** That is Factory Reset Protection. You logged out too
  late, or not at all. Sign in with the account that was on the
  phone before the wipe.
- **The phone bootloops after the unlock wipe.** Boot into stock
  recovery (power off, hold Volume Up + Power, with USB connected)
  and factory reset from there. If it still will not boot, flash
  the stock firmware: [flash-stock.md](flash-stock.md).

## Next step

Flash TWRP: [flash-twrp.md](flash-twrp.md).

## Sources

- Upstream `target/a52sxq/config.sh` lines 7-13 (device name,
  codename a52sxq, platform sm7325, target firmware
  SM-A528B/BTU): https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/a52sxq/config.sh
- UN1CA XDA thread (supported variants SM-A528B a52sxqxx,
  a52sxqzt, SM-A528N a52sxqks; Android 14 bootloader required):
  https://xdaforums.com/t/rom-16-a528b-n-un1ca-3-0-5-one-ui-8-0-for-galaxy-a52s-5g-23-12-2025.4768756/
- Droidwin TWRP guide (Knox trip, banking apps, unlock steps):
  https://droidwin.com/how-to-install-twrp-recovery-on-galaxy-a52s-5g/
- Android Infotech root guide (Developer options path, Download
  mode keys): https://www.androidinfotech.com/root-samsung-galaxy-a52s-5g-android-14/
- GetDroidTips root guide (unlock wipes data, supported model
  SM-A528B): https://www.getdroidtips.com/root-samsung-a52s-5g-sm-a528b/
- Chimera log for SM-A528B BTU on A528BXXSBGYI3 (Knox v30,
  Sales Code BTU): https://www.martview-forum.com/threads/samsung-a52s-5g-sm-a528b-bypass-knoxguard-android-14.167037/
- TODO: Widevine level after unlock on this exact phone, not
  yet confirmed on-device. TODO: exact unlock-screen wording
  (long press vs single press). TODO: read the XDA "OEM
  Unlocking Not Showing" threads for A52s-specific causes.
