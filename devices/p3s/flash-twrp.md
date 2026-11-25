# Flash TWRP - Galaxy S21 Ultra 5G (SM-G998B)

Flash the custom recovery on the SM-G998B and keep it. This file
is for the SM-G998B only. Do not use it on any other model. The
Korean SM-G998N shares the codename p3s, but its firmware differs,
so check its own build before flashing anything from this file.

## What TWRP is

TWRP is a custom recovery: the menu you boot into to install zips,
make backups, and wipe. Everything in this repo is flashed through
it, except where a guide says otherwise.

## Official status: there is no official TWRP for this device

No official twrp.me device page for the S21 Ultra (p3s) was found
in search on 2026-11-25. TWRP for this device is **unofficial**,
by XDA Senior Member afaneh92. Do not look for it on twrp.me and
do not flash a build labelled official for p3s from an unknown
mirror.

## Verified build

The XDA thread "[CLOSED][RECOVERY][UNOFFICIAL] TWRP for Galaxy
S21 Ultra (Exynos)" by afaneh92, for Galaxy S21 Ultra G998B/N,
gives this changelog: initial release 01.03.2021, update to TWRP
**3.6.0** on 29.11.2021. The first release was TWRP 3.5.0. Known
bugs listed in the thread: encryption not fully working, and in
the early 3.5.0 build haptic feedback did not work and encryption
worked only partially.

There is also a newer XDA listing, "[Recovery] [TWRP] [Android
15] [p3s] Unofficial Twrp For S21 Ultra OneUI 7.0", seen in the
S21 Ultra forum index. That build is the one to use on current
One UI 7 / Android 15 firmware if the 3.6.0 build does not mount
or boot, but its exact version, file name and download link are
TODO below: the forum index did not give a direct thread URL in
search, so no link is invented here.

**WARNING: afaneh92's TWRP is NOT supported by UN1CA.** The
upstream UN1CA installer for p3s aborts with E3000 if it detects
afaneh92's recovery. See [flash-un1ca.md](flash-un1ca.md). Do not
assume this TWRP is the recovery UN1CA wants. Which recovery
UN1CA 3.2.1 for p3s does want is TODO in that file.

## Prereqs

1. **Unlocked bootloader.** Do
   [unlock-bootloader.md](unlock-bootloader.md) first, including
   the VaultKeeper step (setup plus internet, OEM unlocking
   greyed out). Without that step the bootloader still rejects
   unofficial images.
2. **Back up everything** and back up EFS in TWRP if it is already
   installed. Flashing TWRP itself does not wipe data, but the
   Format Data step below does.
3. **Log out of Google and Samsung accounts** before wiping, or
   Factory Reset Protection can lock you out afterwards.
4. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself. No hubs, no front-panel ports.
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G998B** and the service
   provider software version must show your region code.

## What you need

- A Windows PC with the **Samsung USB Driver** installed (from
  Samsung: developer.samsung.com) and Samsung Smart Switch closed.
- **Odin3 v3.14.1** (2,595,015 B, SHA-256
  `638296a11b1bfa954991b0597214d833511b973480ae9e15e299a761fea1f794`,
  from the XDA Odin3 thread or https://getodintool.com/). Verify
  with PowerShell before opening it:
  `Get-FileHash .\Odin3-v3.14.1.zip -Algorithm SHA256`.
  Odin is Windows-only. On Linux, `samloader-rs flash` speaks the
  same Odin protocol. Odin is a leaked internal tool, not
  officially distributed by Samsung, and its binary is never
  committed to our repos. Do not use any file claiming to be a
  newer Odin3 than v3.14.4. Odin3 v3.14.4 is disputed (same compile
  date as v3.14.1, older DLL, an unsigned DLL no component
  references, four different ZIPs circulating). We do not recommend
  it. Shared tooling, verified in `../m51/flash-twrp.md`.
- The **TWRP tar** for p3s, from the XDA thread
  "[CLOSED][RECOVERY][UNOFFICIAL] TWRP for Galaxy S21 Ultra
  (Exynos)":
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-s21-ultra-exynos.4240993
- `vbmeta_disabled_R.tar`: a disabled vbmeta, named in the same
  XDA thread. On **this** device it goes in the **USERDATA** slot,
  not the AP slot. That is the thread's own instruction, verified
  against the thread text, and it differs from the m51 route. Do
  not copy the m51 slot here.
- `multidisabler`, by ianmacd, named in the same thread. It is run
  from TWRP's terminal (see step 6), not flashed as a zip. It stops
  stock from re-encrypting or re-locking things after the flash.

## Steps

These steps follow the XDA thread for this device, not the m51
steps.

1. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
2. Open Odin **as administrator**. The `ID:COM` box turns blue and
   shows `Added!` when the phone is detected. If nothing appears,
   the driver, cable, or port is the problem. Do not proceed.
3. Put the **TWRP TAR in the AP slot** and
   `vbmeta_disabled_R.tar` in the **USERDATA** slot, then click
   Start. Wait for PASS.
4. **The moment Odin shows PASS, boot straight into recovery. Do
   not let the phone boot to system.** Reboot to recovery via the
   recovery key combo: **Volume Up + Power, with USB connected**.
   If the phone boots to system first, stock recovery gets
   restored and you have to flash TWRP again.
5. In TWRP, disable encryption: go to Advanced, Terminal, type
   `multidisabler`. If the vendor complains about free space left
   on device, it will attempt to resize vendor and ask you to run
   multidisabler again. Type `multidisabler` again. You will see
   " - Finished." when it is done.
6. **Format Data:** Wipe, Format Data, type `yes`. This is a
   format, not a wipe. It removes encryption so TWRP and the ROM
   can use /data.
7. Reboot to recovery.
8. Flash the Magisk APK in TWRP if you want root now (see
   [root.md](root.md)). Reboot to system.

## Verify

- Reboot to recovery (power off, hold Volume Up + Power, with USB
  connected). TWRP opens. The version is shown on the main screen.
  On the 3.6.0 build it must read 3.6.0.
- In TWRP, /data mounts and Format Data completed without errors.

## Keeping TWRP: the rules

- A full stock AP flash **replaces TWRP** with stock recovery
  (the stock AP tar contains `recovery.img`). To keep TWRP, either
  remove `recovery.img` from the AP tar before flashing (advanced:
  re-pack the tar and recompute the trailing MD5; the `.md5`
  suffix is only a checksum footer, not a signature), or flash
  stock and then **immediately re-flash TWRP before the first boot
  into system** (steps 2 to 4 above, then boot straight into
  recovery).
- The XDA thread's own update route, for a phone already unlocked
  with TWRP installed: load all stock files in Odin, pick
  HOME_CSC instead of CSC, uncheck Auto Reboot, flash, reboot to
  Download mode, keep Auto Reboot unchecked, flash TWRP in the AP
  slot and `vbmeta_disabled.tar` in USERDATA, then hold Volume
  Down + Power until the screen goes black and immediately switch
  to Volume Up + Power to reboot into TWRP, then run
  multidisabler again. Steps 2 to 6 there are the ones that keep
  your data.
- Never let a ROM's own updater touch recovery. Do not check any
  "update recovery on first boot" box.
- After any stock flash, re-flash TWRP before doing custom work
  again, and take a fresh TWRP backup (including EFS) once the
  phone is back on stock.
- /data decryption in TWRP on this device is **not fully working**
  (the thread lists encryption as not fully working, and the early
  build had encryption working only partially). Format Data
  (step 6) removes encryption. Test a /data backup before relying
  on it. Keep your real backups on the system side.
- Do **not** put vbmeta on the AP slot on this device. The XDA
  thread for p3s puts `vbmeta_disabled_R.tar` in USERDATA. The
  m51 warning about vbmeta-on-USERDATA does not apply here: the
  p3s thread itself prescribes USERDATA, and the Snapdragon
  sibling thread repeats the same slot.

## Troubleshooting

- **Odin does not see the phone.** Reinstall the Samsung USB
  Driver, try another port (on the PC itself, not a hub) and
  another data cable. Confirm the phone is in Download mode, not
  just charging.
- **TWRP is gone after a boot.** You booted to system first.
  Re-flash from step 2 and boot straight to recovery this time.
- **Stuck on the Samsung logo after flashing.** Boot into recovery
  and Format Data again.
- **TWRP asks for a password or cannot mount /data.** That is the
  known incomplete encryption support on this build. Format Data
  (step 6) removes encryption. If you need the data on /data,
  stop: back it up from the running system first, then format.
- **TWRP 3.6.0 does not mount /data on current firmware.** The
  thread has reports of this on newer security patches. Try the
  One UI 7.0 TWRP build listed in TODO below before assuming the
  phone is at fault.

## TODO

- TODO: exact version, file name, SHA or MD5, and direct thread
  URL for "[Recovery] [TWRP] [Android 15] [p3s] Unofficial Twrp
  For S21 Ultra OneUI 7.0". Do not link it until the thread URL
  is found on xdaforums.com.
- TODO: verify the 3.6.0 build file-by-file against a reference
  build (version, fingerprint, build date, build host) the way
  the m51 guide does. Not verified yet.
- TODO: confirm whether multidisabler is still needed on One UI 7
  firmware, or whether the newer TWRP build handles encryption
  differently.
- TODO: confirm which recovery UN1CA 3.2.1 for p3s requires, given
  the E3000 abort on afaneh92's TWRP (see flash-un1ca.md).

## Sources

- XDA thread "[CLOSED][RECOVERY][UNOFFICIAL] TWRP for Galaxy S21
  Ultra (Exynos)" (afaneh92), steps, slots, multidisabler,
  changelog 3.5.0 to 3.6.0, bugs:
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-s21-ultra-exynos.4240993
- XDA Developers news, "TWRP ports are now available for the
  Samsung Galaxy S21, S21 Plus, and S21 Ultra" (unofficial TWRP
  3.5.0, models SM-G998B/N, codename p3s):
  http://www.xda-developers.com/unofficial-twrp-samsung-galaxy-s21-plus-ultra/
- Newer One UI 7.0 TWRP listing title: XDA S21 Ultra forum index,
  https://xdaforums.com/f/samsung-galaxy-s21-ultra.12091/
- UN1CA E3000 abort on afaneh92's recovery: salvogiangri/UN1CA
  branch `sixteen`, `target/p3s/installer/assertions.edify`
  line 0, read live 2026-11-25.
  https://github.com/salvogiangri/UN1CA/blob/sixteen/target/p3s/installer/assertions.edify
- Update route (HOME_CSC, Auto Reboot off, vbmeta in USERDATA,
  multidisabler again): XDA Snapdragon sibling thread, page 5,
  https://xdaforums.com/t/closed-recovery-unofficial-twrp-for-galaxy-s21-ultra-5g-snapdragon.4241001/page-5
  (same author, same slot prescription; p3s thread prescribes the
  same USERDATA slot).
- Odin3 v3.14.1 size and SHA-256, and the v3.14.4 dispute: shared
  tooling, verified in `../m51/flash-twrp.md`.

## Next step

Root the phone: [root.md](root.md). Or flash something:
[flash-stock.md](flash-stock.md),
[flash-gsi.md](flash-gsi.md), [flash-un1ca.md](flash-un1ca.md),
[flash-kernel.md](flash-kernel.md).
