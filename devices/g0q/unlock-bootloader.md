# Unlock the bootloader - Galaxy S22+ (Snapdragon) (SM-S906E)

Unlock the bootloader once. It wipes the phone. This file is for
the Snapdragon Galaxy S22+ (g0q) only: **SM-S906E, SM-S906N,
SM-S9060**. Do not use it on any other model.

**Model warning: SM-S906B is the wrong phone.** SM-S906B is the
Exynos Galaxy S22+ (codename `g0s`). It is not g0q, and nothing in
this folder applies to it. The upstream UN1CA target firmware is
`SM-S906E/TUR`. If Settings shows SM-S906B, stop: you have the
Exynos model.

US and Canadian models (**SM-S906U, SM-S906U1, SM-S906W**) cannot
unlock the bootloader at all. The XDA TWRP thread answers the
S906U1 question directly: "not unlockable bootloader".

## What unlocking costs

Read this before you start. There is no undo for the first two
items.

- The phone **wipes itself** once, during the unlock.
- Knox trips **permanently**. Samsung Pay and Secure Folder never
  come back. Flashing stock firmware does not untrip Knox.
- Banking apps and SafetyNet / Play Integrity can fail on an
  unlocked phone.
- Widevine drops to L3 (no HD playback in apps that require L1).
  This is the standard Samsung result of an unlock; it was not
  separately confirmed on a g0q phone in the sources read.
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
   information: model must read **SM-S906E** (or SM-S906N, or
   SM-S9060). Do not unlock or flash anything in this repo on
   SM-S906B (Exynos) or on any US model (SM-S906U, SM-S906U1,
   SM-S906W).
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
4. In Download mode, **long-press Volume Up** to enter Device
   unlock mode. Press **Volume Up** again to confirm the unlock.
   The phone wipes itself and reboots.
5. Set the phone up minimally (or skip setup). You only need adb
   working for the next steps.
6. Check: Settings, Developer options, **OEM unlocking** should now
   show as unlocked or greyed out. `fastboot oem device-info` is
   not available on Samsung. The Download mode screen itself shows
   the lock state.

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
  out. There is no supported bypass. On US models (SM-S906U,
  SM-S906U1, SM-S906W) the bootloader cannot be unlocked at all.
- **The phone asks for a Google or Samsung account after the
  wipe.** That is Factory Reset Protection. You logged out too
  late, or not at all. Sign in with the account that was on the
  phone before the wipe.
- **The phone bootloops after the unlock wipe.** Boot into stock
  recovery (power off, hold Volume Up + Power with the USB cable
  connected) and factory reset from there. If it still will not
  boot, flash the stock firmware:
  [flash-stock.md](flash-stock.md).

## Next step

Flash TWRP: [flash-twrp.md](flash-twrp.md).

## Sources

- Unlock steps (Download mode combo, long-press Volume Up, press
  Volume Up again to confirm): AndroidBiits, "How to Unlock
  Bootloader in Samsung Galaxy S22 Plus (SM-S906B, SM-S906E,
  SM-S906N)", https://androidbiits.com/unlock-bootloader-samsung-galaxy-s22-plus-sm-s906b-sm-s906e-sm-s906n-easily/
  and Droidwin, "How to Unlock Bootloader on Samsung Galaxy S22,
  S22 Plus, S22 Ultra",
  https://droidwin.com/how-to-unlock-bootloader-on-samsung-galaxy-s22-s22-plus-s22-ultra/
- Knox trip, Samsung Pay / Secure Folder loss, SafetyNet and
  banking apps: Droidwin unlock guide above.
- US models not unlockable: XDA thread "[CLOSED][RECOVERY]
  [UNOFFICIAL] TWRP for Galaxy S22+ (Snapdragon)",
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-s22-snapdragon.4453813/
  (S906U1 question, answered "not unlockable bootloader").
- Model split (SM-S906B is Exynos, codename g0s; SM-S906E/N/0/U/U1/W
  are Snapdragon, codename g0q): /e/OS community device list,
  https://community.e.foundation/t/samsung-galaxy-s22/58689 and
  PhoneMore comparison,
  https://www.phonemore.com/compare/phones/samsung-galaxy-s22-plus-sm-s906eds-256gb-vs-samsung-galaxy-s22-plus-sm-s906bds-256gb/19560452
- Upstream target firmware SM-S906E/TUR:
  https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/g0q/config.sh
  line 13.

## TODO

- Widevine L3 after unlock on g0q: stated above as the standard
  Samsung result, not confirmed on a g0q phone. Confirm from a
  g0q device report before presenting it as verified.
- The 7-day waiting period for OEM unlocking on g0q: stated from
  general Samsung practice, not confirmed for this model.
- Recovery key combination after the unlock wipe (Volume Up +
  Power with USB connected) is from the S22+ hard-reset guide, not
  from an unlock report on g0q. Confirm on the device.
