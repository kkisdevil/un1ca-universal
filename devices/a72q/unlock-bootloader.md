# Unlock the bootloader - Galaxy A72 (SM-A725F)

Unlock the bootloader once. It wipes the phone. This file is for
the SM-A725F only. Do not use it on any other model. The sibling
model SM-A725M (Latin America) is a different model: the UN1CA
installer treats it separately (see flash-un1ca.md), and nothing
here is verified on it.

## What unlocking costs

Read this before you start. There is no undo for the first two
items.

- The phone **wipes itself** once, during the unlock.
- Knox trips **permanently**. Samsung Pay and Secure Folder never
  come back. Flashing stock firmware does not untrip Knox.
- Widevine drops to L3 (no HD Netflix and no HD playback in apps
  that require L1). TODO: confirm the L3 drop on this exact model
  from a live check; it is the standard Samsung behaviour on
  unlock, not yet measured on an A72 in front of us.
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
   recover from. TODO: confirm the EFS partition name and backup
   path on this device in TWRP; the m51 procedure is the model,
   not the proof.
3. **Log out of Google and Samsung accounts** before unlocking, or
   Factory Reset Protection can lock you out of your own phone
   afterwards.
4. **Battery above 50%, ideally full.** A dead phone mid-flash is
   how bricks happen.
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A725F**. The upstream target
   firmware is the BTU (United Kingdom) build
   `SM-A725F/BTU/353546291234560`
   (`target/a72q/config.sh` line 8), so a BTU phone is the
   reference device. Do not unlock or flash anything in this repo
   on any other model. If your phone is a different region, record
   its CSC first and check flash-stock.md before proceeding.
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
   This is the standard Samsung key combination for this
   generation, and the XDA TWRP threads for this device use it
   (see Sources).
4. In Download mode, **long-press Volume Up** to unlock the
   bootloader. Confirm on screen. The phone wipes itself and
   reboots.
5. Set the phone up minimally (or skip setup). You only need adb
   working for the next steps.
6. Check: Settings, Developer options, **OEM unlocking** should now
   show as unlocked or greyed out. Samsung has no fastboot
   `oem device-info` check. The Download mode screen itself shows
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

- Upstream target config:
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/a72q/config.sh
  line 8 (`TARGET_FIRMWARE="SM-A725F/BTU/353546291234560"`).
- XDA, "[RECOVERY] [OFFICIAL] TWRP 3.5.2 for Galaxy A72 4G":
  https://xdaforums.com/t/recovery-official-twrp-3-5-2-for-galaxy-a72-4g.4278031/
  (Download mode via both volume keys plus USB; unlocked
  bootloader required first).
- XDA, "[RECOVERY][OFFICIAL] TWRP 3.7 for Galaxy A52 4G and A72 4G":
  https://xdaforums.com/t/recovery-official-twrp-3-7-for-galaxy-a52-4g-and-a72-4g.4405751/
  (same Download mode entry).
- Knox, Widevine L3, FRP and the 7-day OEM unlocking wait are
  standard Samsung behaviour, stated here as such. TODO: confirm
  each on a live A72 and replace this note with the measured
  result.
