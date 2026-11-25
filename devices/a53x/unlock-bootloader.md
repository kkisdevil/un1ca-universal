# Unlock the bootloader - Galaxy A53 5G (SM-A536B)

Unlock the bootloader once. It wipes the phone. This file is for
the SM-A536B only. Do not use it on any other model. The A53 5G
is an Exynos phone (Exynos 1280, s5e8825), so there is no
Qualcomm EDL or Snapdragon-specific step anywhere in this folder.
Everything here goes through Samsung Download mode and Odin.

## What unlocking costs

Read this before you start. There is no undo for the first two
items.

- The phone **wipes itself** once, during the unlock.
- Knox trips **permanently**. Samsung Pay and Secure Folder never
  come back. Flashing stock firmware does not untrip Knox. The
  XDA TWRP thread states this directly: flashing a custom binary
  blows the Knox warranty bit.
- Widevine drops to L3 (no HD Netflix and no HD playback in apps
  that require L1).
- Banking apps and Play Integrity can fail on an unlocked phone.
- You must **never relock the bootloader** with TWRP, Magisk, or
  any custom image installed. That bricks the phone.
- Only the international models can be unlocked. The XDA TWRP
  thread records that the Canadian SM-A536W bootloader cannot
  currently be unlocked. These guides cover the SM-A536B only.

## Prereqs

1. **Back up everything.** Photos, files, app data. Copy them off
   the phone and check you can open the copies. The unlock wipes
   the phone.
2. **Back up EFS first if TWRP is already installed.** In TWRP,
   back up the EFS partition and keep a copy off the phone. EFS
   holds the IMEI and modem calibration. Losing it is very hard to
   recover from. (On a first unlock TWRP is not installed yet, so
   this step applies on later re-flashes, not on the first run.)
3. **Log out of Google and Samsung accounts** before unlocking, or
   Factory Reset Protection can lock you out of your own phone
   afterwards.
4. **Battery above 50%, ideally full.** A dead phone mid-flash is
   how bricks happen.
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A536B** and the service
   provider software version must show **EUX**. The upstream
   UN1CA target for this device is built against
   `SM-A536B/EUX`. Do not unlock or flash anything in this repo
   on any other model or region.
6. A good USB data cable (charge-only cables will not work) and a
   USB port on the PC itself. No hubs, no front-panel ports.

## Steps

1. Do everything in Prereqs above first: backup, log out of
   accounts.
2. Enable Developer options: Settings, About phone, tap Build
   number 7 times. Then turn on **OEM unlocking** and **USB
   debugging**.
3. Power the phone fully off. Press and hold **Volume Up + Volume
   Down**, then connect the USB cable to the PC. A warning screen
   appears. Press **Volume Up** to continue into Download mode.
4. In Download mode, **long-press Volume Up** (hold it more than
   7 seconds) to unlock the bootloader. Confirm on screen. The
   phone wipes itself and reboots.
5. Set the phone up minimally (or skip setup). You only need adb
   working for the next steps.
6. Check: Settings, Developer options, **OEM unlocking** should
   now show as unlocked or greyed out. `adb reboot bootloader`
   then `fastboot oem device-info` is not available on Samsung.
   The Download mode screen itself shows the lock state.

## Verify

- Settings, Developer options: OEM unlocking shows as unlocked or
  greyed out.
- Boot into Download mode again (power off, hold Volume Up +
  Volume Down, connect USB). The screen shows the bootloader as
  unlocked, and the KG/RMM state line no longer reads Prenormal.

## Troubleshooting

- **OEM unlocking is greyed out or missing.** Samsung enforces a
  waiting period after first setup: the KG/RMM state sits at
  Prenormal and blocks custom binaries until the phone has been
  on, online, and SIM-inserted for 7 days. Keep the phone on and
  connected and wait it out. There is no supported bypass. A
  carrier-locked phone may also never show the toggle.
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

Root the phone first, then flash TWRP pre-rooted (the order the
official TWRP page recommends for this device): see
[root.md](root.md) and [flash-twrp.md](flash-twrp.md).

## Sources

- Upstream target firmware `SM-A536B/EUX`: `target/a53x/config.sh`
  line 11 in salvogiangri/UN1CA branch `sixteen`.
- Download mode key combo and long-press Volume Up to unlock:
  XDA TWRP threads for a53x and the A53 TWRP install guide at
  https://magiskzip.com/install-twrp-recovery-on-samsung-galaxy-a53-5g/
- Knox trip on flashing a custom binary, and SM-A536W bootloader
  not unlockable: XDA thread "[RECOVERY][OFFICIAL] TWRP 3.7.1-12
  for Galaxy A53 5G", https://xdaforums.com/t/recovery-unofficial-twrp-3-7-1-12-for-galaxy-a53-5g.4680051/
  and "[RECOVERY][UNOFFICIAL] TWRP for Galaxy A53 5G (Exynos)",
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-a53-5g-exynos.4467443/post-89444919
- 7-day KG/RMM Prenormal wait: Samsung-wide mechanism, described
  at https://www.thecustomdroid.com/prenormal-rmm-state-on-samsung-galaxy-guide/
  and https://en.androidayuda.com/android/Tutorials/How-to-fix-the-RMM-state-prenormal-error-when-trying-to-flash-a-Samsung-Galaxy/
- Widevine L3 and banking-app loss on unlock: A53 TWRP/root guide
  at https://droidwin.com/install-twrp-recovery-and-root-samsung-galaxy-a53-5g/
