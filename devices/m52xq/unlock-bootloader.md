# Unlock the bootloader - Galaxy M52 5G (SM-M526B / SM-M526BR)

Unlock the bootloader once. It wipes the phone. This file is for
the SM-M526B and SM-M526BR only. Do not use it on any other model.
The two model numbers are the same phone (m52xq) sold in different
regions: SM-M526B is the usual model number, SM-M526BR is the
variant the UN1CA target firmware is built from. Supported models
per the LineageOS wiki are SM-M526B, SM-M526BR, SM-M526B/DS and
SM-M526BR/DS.

## What unlocking costs

Read this before you start. There is no undo for the first two
items.

- The phone **wipes itself** once, during the unlock. The XDA
  TWRP thread states this plainly: long-pressing Volume Up to
  unlock "will wipe your data".
- Knox trips **permanently**. The XDA TWRP thread states the Knox
  Warranty Bit "will be blown once you flash this or others custom
  binaries" and "can't be resetted in any way". Samsung Pay and
  Secure Folder never come back. Flashing stock firmware does not
  untrip Knox.
- Widevine is expected to drop to L3 (no HD Netflix and no HD
  playback in apps that require L1). This is the standard Samsung
  behaviour after an unlock. TODO: confirm Widevine L3 on an
  m52xq after unlocking; the phone reports Widevine L1 on locked
  stock.
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
   recover from. The platform installer fstab for sm7325 lists
   the EFS partitions as `sec_efs` (mounted at `/efs` and
   `/sec_efs`).
3. **Log out of Google and Samsung accounts** before unlocking, or
   Factory Reset Protection can lock you out of your own phone
   afterwards.
4. **Battery above 50%, ideally full.** A dead phone mid-flash is
   how bricks happen.
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-M526B** or **SM-M526BR**,
   and the service provider software version must show the CSC
   for your region (for example INS for India, BTU for the United
   Kingdom). Do not unlock or flash anything in this folder on any
   other model.
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
5. Go through the initial setup. Skip through the steps, since
   data will be wiped again later when TWRP is installed. Make
   sure to **connect the device to the internet** during the
   setup. This is the XDA TWRP thread's own instruction.
6. Check: Settings, Developer options, **OEM unlocking** should
   now exist and be greyed out. The XDA thread states this means
   the bootloader is unlocked and the phone has no KnoxGuard lock
   set. `adb reboot bootloader` then `fastboot oem device-info`
   is not available on Samsung. The Download mode screen itself
   shows the lock state.

## Verify

- Settings, Developer options: OEM unlocking shows as greyed out.
- Boot into Download mode again (power off, hold Volume Up +
  Volume Down, connect USB). The screen shows the bootloader as
  unlocked.

## Troubleshooting

- **OEM unlocking is greyed out or missing.** The phone is likely
  carrier-locked, or the 7-day waiting period applies (Samsung
  enforces a wait after first setup on some firmwares), or a
  KnoxGuard lock is set. Wait it out. There is no supported
  bypass.
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

- XDA thread "[RECOVERY][UNOFFICIAL] TWRP 3.7.0 for Galaxy M52
  5G", https://xdaforums.com/t/recovery-unofficial-twrp-3-7-0-for-galaxy-m52-5g.4538691/
  (unlock wipes data; Knox Warranty Bit blown permanently;
  Download mode and long-press Volume Up steps; OEM unlocking
  greyed out means unlocked with no KnoxGuard lock; connect to
  the internet during setup). Read via search results 2026-11-25;
  the thread itself could not be opened directly (XDA returned
  403 to curl and the browser fetch was rate-limited), so the
  exact first-post wording beyond the search snippets is TODO to
  re-check.
- LineageOS wiki, m52xq info page,
  https://wiki.lineageos.org/devices/m52xq/ (supported models
  SM-M526B, SM-M526BR, SM-M526B/DS, SM-M526BR/DS).
- Upstream platform installer fstab,
  https://github.com/salvogiangri/UN1CA/blob/sixteen/platform/sm7325/installer/recovery.fstab
  (EFS partitions `sec_efs`, lines 46-47).
- Widevine L1 on locked stock: deviceinfo.app Galaxy M52 5G page,
  https://www.deviceinfo.app/devices/samsung/galaxy-m52-5g/
  (Widevine DRM L1, Android 13 / One UI 5.1, kernel 5.4.233).
  Widevine after unlock is TODO, as noted above.
