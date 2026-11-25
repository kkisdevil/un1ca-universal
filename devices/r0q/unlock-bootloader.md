# Unlock the bootloader - Galaxy S22 (SM-S901E)

Unlock the bootloader once. It wipes the phone. This file is for
the Galaxy S22 (Snapdragon), codename `r0q`, models **SM-S901E**,
SM-S901N, and SM-S9010 only. Do not use it on the Exynos Galaxy
S22 (SM-S901B, codename `r0s`) or on the US models SM-S901U,
SM-S901U1, and SM-S901W: the US Snapdragon models cannot have
their bootloader unlocked. Do not use it on the Galaxy S22 Ultra
(SM-S908x, codename `b0q`).

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
   information: model must read **SM-S901E** (or SM-S901N or
   SM-S9010). The upstream UN1CA target firmware for this device
   is SM-S901E/TUR. If the model reads SM-S901B, stop: that is the
   Exynos S22 (`r0s`), a different device. If it reads SM-S901U,
   SM-S901U1, or SM-S901W, stop: the bootloader on the US
   Snapdragon models cannot be unlocked.
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
  out. There is no supported bypass. On the US models (SM-S901U,
  SM-S901U1, SM-S901W) the option never appears: the bootloader
  cannot be unlocked on those models at all.
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

- Upstream target firmware and model: `target/r0q/config.sh`
  line 13 (`TARGET_FIRMWARE="SM-S901E/TUR/350999641234561"`),
  line 7 (`TARGET_NAME="Galaxy S22 (Snapdragon)"`), line 11
  (`TARGET_PLATFORM="sm8450"`), in
  https://github.com/salvogiangri/UN1CA/tree/sixteen/target/r0q
- Unlock steps and US-model lock: XDA unlock discussion and the
  GetDroidTips S22/S22 Plus unlock guide,
  https://www.getdroidtips.com/samsung-galaxy-s22-plus-unlock-bootloader/
  (Volume Up + Volume Down + USB into Download mode, long-press
  Volume Up to unlock; US Snapdragon S22 bootloader cannot be
  unlocked)
- Knox, Widevine, and relock behaviour: standard Samsung platform
  behaviour, as stated in the m51 guides in this repo
- TODO: no r0q phone has been unlocked in front of us, so the
  exact Download mode screen wording for this device is
  unverified. Confirm it on the first real unlock and record it
  here.
