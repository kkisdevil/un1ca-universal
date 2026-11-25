# Unlock the bootloader - Galaxy S21+ 5G (SM-G996B)

Unlock the bootloader once. It wipes the phone. This file is for
the SM-G996B only. Do not use it on any other model. The Korean
variant SM-G996N shares the t2s codename but has its own
bootloader requirement (see flash-un1ca.md); do not use this file
on a G996N, G996U, G996U1, G996W, or G9960.

## What unlocking costs

Read this before you start. There is no undo for the first item.

- The phone **wipes itself** once, during the unlock.
- Knox trips **permanently**. The XDA TWRP thread states that
  flashing custom binaries trips Knox, and Samsung Pay and Secure
  Folder never come back. Flashing stock firmware does not untrip
  Knox.
- OTA updates stop working on the phone once custom binaries are
  flashed (stated in the XDA TWRP thread and in the XDA news
  coverage of the TWRP release).
- Banking apps and Play Integrity can fail on an unlocked phone.
- TODO: Widevine level after unlock on this device. The stock
  locked phone reports Widevine L1 (deviceinfo.app record for
  SM-G996B), but no source found so far confirms whether it drops
  to L3 after unlock on t2s. Do not state L3 as fact until it is
  checked on a real unlocked phone.
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
   information: model must read **SM-G996B** (or SM-G996B/DS for
   the dual-SIM variant) and the service provider software version
   must show the CSC of the firmware on the phone. The UN1CA
   target firmware for this device uses CSC **AUT**; the newest
   firmware record found for this device uses CSC **SER** (see
   flash-stock.md). Do not unlock or flash anything in this repo
   on any other model.
6. A good USB data cable (charge-only cables will not work) and a
   USB port on the PC itself. No hubs, no front-panel ports.
7. TODO: the 7-day waiting period. Samsung enforces a wait after
   first setup on some firmwares before OEM unlocking appears.
   No t2s-specific source found so far confirms whether it applies
   to this device. If OEM unlocking is missing, wait it out (see
   Troubleshooting).

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
   show as unlocked or greyed out. The Download mode screen
   itself shows the lock state. Samsung phones have no fastboot
   `oem device-info` check; do not look for one.

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
  recovery (power off, hold Volume Up + Power with USB connected)
  and factory reset from there. If it still will not boot, flash
  the stock firmware: [flash-stock.md](flash-stock.md).

## Next step

Flash TWRP: [flash-twrp.md](flash-twrp.md).

## Sources

- Upstream UN1CA `target/t2s/config.sh` (salvogiangri/UN1CA,
  branch sixteen, UN1CA 3.2.1): model SM-G996B, codename t2s,
  SoC exynos2100. Read live 2026-11-25.
- XDA thread "[CLOSED][RECOVERY][UNOFFICIAL] TWRP for Galaxy
  S21+ (Exynos)" by afaneh92:
  https://xdaforums.com/t/closed-recovery-unofficial-twrp-for-galaxy-s21-exynos.4241935/page-2
  (Knox trip and OTA loss; supported models Galaxy S21+
  G996B/N; thread is closed, not open for further replies).
- XDA news "TWRP ports are now available for the Samsung Galaxy
  S21, S21 Plus, and S21 Ultra":
  http://www.xda-developers.com/unofficial-twrp-samsung-galaxy-s21-plus-ultra/
  (unofficial TWRP 3.5.0 for Exynos SM-G996B/N, codename t2s;
  Knox trip, no OTA).
- Unlock key sequence: AndroidBiits "How to Unlock Bootloader of
  Samsung Galaxy S21+ 5G SM-G996B Easily":
  https://androidbiits.com/unlock-bootloader-samsung-galaxy-s21-plus-sm-g996b-easily/
  (Vol Up + Vol Down + USB, long-press Vol Up to unlock).
- GSMArena Samsung Galaxy S21+ 5G specifications:
  https://www.gsmarena.com/samsung_galaxy_s21+_5g-10625.php
  (models SM-G996B, SM-G996B/DS, SM-G996U, SM-G996U1, SM-G996W,
  SM-G996N, SM-G9960; Exynos 2100 international).
- Stock locked Widevine L1: deviceinfo.app record for Galaxy
  S21+ 5G: https://www.deviceinfo.app/devices/samsung/galaxy-s21-plus-5g/
- Download mode and recovery key patterns, Odin rule, and guide
  structure: [../m51/unlock-bootloader.md](../m51/unlock-bootloader.md)
  (Samsung-wide practice, not m51 values).

## TODO

- Widevine level after unlock on t2s (see "What unlocking
  costs").
- Whether the 7-day OEM unlocking waiting period applies to t2s.
