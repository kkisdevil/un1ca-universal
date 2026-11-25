# Unlock the bootloader - Galaxy S21 Ultra 5G (SM-G998B)

Unlock the bootloader once. It wipes the phone. This file is for
the SM-G998B only. Do not use it on any other model. The Korean
SM-G998N shares the codename p3s and the same Exynos 2100 SoC, but
its firmware and bootloader strings differ, so do not follow this
file on a G998N without checking its own firmware first. The US
Snapdragon models SM-G998U, SM-G998U1 and SM-G998W are codename
p3q, not p3s, and are not unlockable in most cases. Do not use this
file on them.

## What unlocking costs

Read this before you start. There is no undo for the first two
items.

- The phone **wipes itself** once, during the unlock.
- Knox trips **permanently**. Samsung Pay, Samsung Pass and Secure
  Folder never come back. Flashing stock firmware does not untrip
  Knox.
- Widevine drops to L3 on some firmware combinations after unlock
  and root, so HD playback in apps that require L1 can stop
  working. The exact Widevine level after unlock alone on this
  device, with no root, is TODO: verify with a DRM Info check on
  an unlocked but unrooted SM-G998B and record the result here.
- Banking apps and Play Integrity can fail on an unlocked phone.
- You must **never relock the bootloader** with TWRP, Magisk, or
  any custom image installed. That bricks the phone.
- VaultKeeper: unlocking is not finished when the wipe ends.
  Samsung's VaultKeeper service relocks the bootloader after the
  wipe until you complete setup and connect to the internet. Until
  that step is done, the bootloader still rejects unofficial
  images. See step 5 below.

## Prereqs

1. **Back up everything.** Photos, files, app data. Copy them off
   the phone and check you can open the copies. The unlock wipes
   the phone.
2. **Back up EFS first if TWRP is already installed.** In TWRP,
   back up the EFS partition and keep a copy off the phone. EFS
   holds the IMEI and modem calibration. Losing it is very hard to
   recover from. If TWRP is not installed yet, this step waits
   until after [flash-twrp.md](flash-twrp.md); the unlock itself
   does not need an EFS backup first, but do not skip the backup
   once TWRP exists.
3. **Log out of Google and Samsung accounts** before unlocking, or
   Factory Reset Protection can lock you out of your own phone
   afterwards.
4. **Battery above 50%, ideally full.** A dead phone mid-flash is
   how bricks happen.
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G998B** and the service
   provider software version must show your region code. The
   UN1CA target firmware for this device is **SM-G998B/AUT**,
   so a phone already on AUT is the known-good base. Do not unlock
   or flash anything in this repo on any other model.
6. A good USB data cable (charge-only cables will not work) and a
   USB port on the PC itself. No hubs, no front-panel ports.
7. Check for a software update first, even if none is offered.
   On the S21 family this starts Samsung's waiting timer, which
   is usually 7 days before the OEM unlocking toggle appears. If
   the toggle is missing, the waiting period (RMM/KG state
   Prenormal) is the usual cause. There is no supported bypass.

## Steps

1. Do everything in Prereqs above first: backup, log out of
   accounts, check the model.
2. Enable Developer options: Settings, About phone, tap Build
   number 7 times. Then turn on **OEM unlocking** and **USB
   debugging**. If OEM unlocking is greyed out or missing, see
   Troubleshooting below. Do not proceed without it.
3. Power the phone fully off. Press and hold **Volume Up + Volume
   Down**, then connect the USB cable to the PC. A warning screen
   appears. Press **Volume Up** to continue into Download mode.
4. In Download mode, **long-press Volume Up** to unlock the
   bootloader. Press Volume Up again to confirm when asked. The
   phone wipes itself and reboots.
5. **VaultKeeper step, do not skip it.** Go through the initial
   setup and **connect the phone to the internet** during setup.
   Then enable Developer options again and confirm that the OEM
   unlocking option exists and is greyed out. That greyed-out
   state means VaultKeeper has released the bootloader. Until
   then, the bootloader still rejects unofficial images in
   Download mode, even though the wipe already happened.
6. Check: Settings, Developer options, **OEM unlocking** should
   now show as unlocked or greyed out. Samsung has no fastboot
   `oem device-info` check. The Download mode screen itself shows
   the lock state.

## Verify

- Settings, Developer options: OEM unlocking shows as unlocked or
  greyed out after the VaultKeeper step.
- Boot into Download mode again (power off, hold Volume Up +
  Volume Down, connect USB). The screen shows the bootloader as
  unlocked.

## Troubleshooting

- **OEM unlocking is greyed out or missing.** The phone is likely
  carrier-locked, or the 7-day waiting period applies (Samsung
  enforces a wait after first setup and after a software update
  check on this family; some reports say up to 30 days). Wait it
  out. There is no supported bypass. On a US Snapdragon model
  (SM-G998U/U1/W) the toggle never appears at all: stop, that
  phone is not unlockable by this method.
- **The phone asks for a Google or Samsung account after the
  wipe.** That is Factory Reset Protection. You logged out too
  late, or not at all. Sign in with the account that was on the
  phone before the wipe.
- **The phone bootloops after the unlock wipe.** Boot into stock
  recovery (power off, hold Volume Up + Power, with USB connected
  on this family) and factory reset from there. If it still will
  not boot, flash the stock firmware:
  [flash-stock.md](flash-stock.md).
- **Odin or TWRP still refuses unofficial images after the
  unlock.** You skipped the VaultKeeper step. Complete setup,
  connect to the internet, and confirm the greyed-out OEM
  unlocking state in Developer options.

## TODO

- TODO: Widevine level after unlock alone on the SM-G998B
  (unrooted). Verify with DRM Info and record L1 or L3 here.
- TODO: confirm the exact Download mode warning screen wording on
  current One UI 7 firmware for this device.

## Sources

- Upstream identity: salvogiangri/UN1CA branch `sixteen`,
  `target/p3s/config.sh` lines 5 to 13: device name Galaxy S21
  Ultra 5G (Exynos), codename `p3s`, platform `exynos2100`,
  `TARGET_FIRMWARE="SM-G998B/AUT/350635581234563"`.
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/p3s/config.sh
- Unlock steps, VaultKeeper step and 7-day wait: XDA thread
  "[Magisk][US/CAN BL Unlock] Root for Galaxy S21 Series
  (B/N/0/U/U1/W)", https://xdaforums.com/t/magisk-us-can-bl-unlock-root-for-galaxy-s21-series-b-n-0-u-u1-w.4233567/page-2
  and TheCustomDroid Samsung bootloader unlock guide,
  https://www.thecustomdroid.com/samsung-galaxy-bootloader-unlock-guide/
- Model split (Exynos G998B unlockable, US Snapdragon G998U/U1/W
  not unlockable) and Knox eFuse 0x1: AndroidRebels S21 root
  guide, https://androidrebels.com/smartphones-hardware/how-to-root-samsung-galaxy-s21/
- Waiting period detail (7 days, RMM Prenormal): Krispitech,
  "How to Unlock the Bootloader of the Samsung Galaxy S21
  (Exynos)?", https://krispitech.com/galaxy-s21-unlock-bootloader/
- Download mode key combo and long-press Volume Up: AndroidBiits,
  "How to Unlock Bootloader of Samsung Galaxy S21 Ultra 5G
  SM-G998B", https://androidbiits.com/unlock-bootloader-samsung-galaxy-s21-ultra-sm-g998b-easily/
- Shared Samsung practice (backup, EFS, battery, cable, FRP):
  `../m51/unlock-bootloader.md` in this repo.

## Next step

Flash TWRP: [flash-twrp.md](flash-twrp.md).
