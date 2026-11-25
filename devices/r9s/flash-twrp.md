# Flash TWRP - Galaxy S21 FE 5G (SM-G990E)

Flash a custom recovery on the SM-G990E and keep it. This file is
for the SM-G990E only (Exynos S21 FE 5G, codename r9s). Do not use
it on the Snapdragon FE (SM-G990B, SM-G990B2, SM-G990U, codename
r9q/r9q2) or any other model. The Snapdragon builds are different
files for a different SoC.

## What TWRP is on this device, and the hard truth about it

TWRP is a custom recovery: the menu you boot into to install zips,
make backups, and wipe. Everything in this repo is flashed through
a custom recovery.

**There is no official TWRP for the r9s.** No device page for the
r9s exists on twrp.me, and no official build was found in this
research pass. The official TWRP for the S21 FE 5G covers the
Snapdragon variants only (r9q/r9q2): see "[RECOVERY][OFFICIAL]
TWRP for Galaxy S21 FE 5G (Snapdragon) with crypt support",
https://xdaforums.com/t/recovery-official-twrp-for-galaxy-s21-fe-5g-snapdragon-with-crypt-support.4677578/
That build is NOT for the SM-G990E. Do not flash it on this phone.

For the Exynos r9s there is only an **unofficial** build:

- "[CLOSED][RECOVERY][UNOFFICIAL] TWRP for Galaxy S21 FE
  (Exynos)" by afaneh92,
  https://xdaforums.com/t/closed-recovery-unofficial-twrp-for-galaxy-s21-fe-exynos.4421829/
  Supported model: Galaxy S21 FE G990E. Initial release
  2022-03-26. The thread is **CLOSED**, and in the copy indexed
  2026-06-10 the download link is struck through (`~~r9s~~`),
  which means the download is no longer offered there. Known bug
  from the thread: "Encryption not fully working."

**And UN1CA rejects that exact build.** The UN1CA installer
assertions for r9s abort with E3000 if afaneh92's TWRP is
installed (verified from the upstream installer, see
[flash-un1ca.md](flash-un1ca.md)). So even if you find the
afaneh92 build, do not use it as the recovery for UN1CA.

**Use OrangeFox instead.** The UN1CA install instructions accept
TWRP or OrangeFox, and for this device OrangeFox is the recovery
with a live maintainer:

- "[RECOVERY][UNOFFICIAL][OFOX][SM-G990E/DS] Samsung S21 FE 5G
  Exynos OFOX Recovery Project R11.3" by bekirakil, posted
  2025-10-30 on XDA. TODO: the exact thread URL was not recovered
  in this pass (the forum index lists the thread, but no direct
  link was returned); get it from the S21 FE forum,
  https://xdaforums.com/f/samsung-galaxy-s21-fe.12389/, before
  flashing.
- A newer OrangeFox build file is named in the "StockLite rom for
  SM-G990E" thread: `OrangeFox-R12.1-Beta-r9s.img.tar`, flashed in
  Odin AP with `vbmeta_disabled_R.tar` in USERDATA,
  https://xdaforums.com/t/stocklite-rom-for-sm-g990e.4719034/
- Recovery source tree: OrangeFox and TWRP trees for the r9s,
  https://github.com/MLXProjects/recovery_samsung_r9s (default
  branch fox-12.1; kernel source
  https://github.com/mohammad92/android_kernel_samsung_r9s).

## Verified build

TODO: no recovery image for the r9s has been verified against a
reference build in this pass. There is no verified TWRP version,
build date, Android base, kernel version, fingerprint, or hash to
list here. The afaneh92 download link is dead as indexed, and no
OrangeFox file has been downloaded and checked by us. Do not flash
any file whose hash you have not checked against its own release
page. When a build is verified, record its version, date, source
link, size and hash here.

## Prereqs

1. **Unlocked bootloader.** Do
   [unlock-bootloader.md](unlock-bootloader.md) first. Read its
   One UI 8 warning: a phone already on One UI 8 cannot be
   unlocked at all.
2. **Back up everything** and back up EFS in the current recovery
   if one is already installed. Flashing a recovery itself does
   not wipe data, but the Format Data step below does.
3. **Log out of Google and Samsung accounts** before wiping, or
   Factory Reset Protection can lock you out afterwards.
4. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself. No hubs, no front-panel ports.
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G990E** and the service
   provider software version must show your region (for example
   THL or INS).

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
  it. (Shared tooling, cited from the m51 docs.)
- `vbmeta_disabled_R.tar`: a disabled vbmeta, so the unsigned
  recovery and GSI can boot. Named in the XDA TWRP thread below.
  TODO: exact download source and hash for this file were not
  verified in this pass.
- The **OrangeFox tar for r9s** (recommended, see above), or the
  afaneh92 TWRP tar if you can find a trustworthy copy and you do
  NOT plan to flash UN1CA. TODO: exact file name, version and
  download link for either build.
- `multidisabler` (by ianmacd, credited in the XDA TWRP thread).
  It stops stock from re-encrypting or re-locking things after
  the flash. On this device it is run as a command in the
  recovery terminal, not flashed as a zip. TODO: exact version
  and source for the multidisabler build matching this device.

## Steps

These steps follow the XDA TWRP thread for the r9s. The thread's
own order is: recovery tar in the AP slot, vbmeta in the USERDATA
slot, in one Odin run.

1. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
2. Open Odin **as administrator**. The `ID:COM` box turns blue and
   shows `Added!` when the phone is detected. If nothing appears,
   the driver, cable, or port is the problem. Do not proceed.
3. Load the **recovery tar in the AP slot** and
   `vbmeta_disabled_R.tar` in the **USERDATA slot** and flash.
   Wait for PASS. Note: on the m51 the vbmeta-on-USERDATA variant
   is unverified and not used, but on the r9s it IS the XDA
   thread's own instruction, so it is the route documented here.
   (A second guide, GetDroidTips, flashes vbmeta first, wipes,
   then flashes the recovery tar in a second Odin run. The XDA
   thread order above is the primary one.)
4. **The moment Odin shows PASS, boot straight into recovery. Do
   not let the phone boot to system.** Hold **Volume Up + Power
   with the USB cable connected** until the recovery screen
   appears. If the phone boots to system first, stock recovery
   gets restored and you have to flash again.
5. In the recovery, disable encryption: go to Advanced, Terminal,
   and type `multidisabler`. If it complains about free space on
   vendor, it will try to resize vendor and ask you to run it
   again: type `multidisabler` again until you see `- Finished.`
6. **Format Data:** Wipe, Format Data, type `yes`. This is a
   format, not a wipe. It removes encryption so the recovery and
   the ROM can use /data.
7. Reboot to recovery again, then reboot to System for a stock
   boot, or stay in recovery for the next flash (root, GSI, UN1CA,
   or kernel).

## Verify

- Reboot to recovery (power off, hold Volume Up + Power with USB
  connected). The custom recovery opens and shows its version on
  the main screen. TODO: record the exact version string of the
  build you flash.
- In the recovery, /data mounts and Format Data completed without
  errors. Note the thread's known bug: encryption is not fully
  working in the afaneh92 build, so do not rely on /data
  decryption in that build. TODO: confirm whether the OrangeFox
  build you use decrypts /data.

## Keeping the recovery: the rules

- A full stock AP flash **replaces the custom recovery** with
  stock recovery (Samsung stock AP tars contain `recovery.img`;
  this is standard Samsung behaviour, as in the m51 docs). TODO:
  confirm by listing the r9s AP tar contents before relying on
  it. To keep the recovery, either remove `recovery.img` from the
  AP tar before flashing (advanced: re-pack the tar and recompute
  the trailing MD5; the `.md5` suffix is only a checksum footer,
  not a signature), or flash stock and then **immediately re-flash
  the recovery before the first boot into system** (steps 2 to 4
  above, then boot straight into recovery).
- Never let a ROM's own updater touch recovery. Do not check any
  "update recovery on first boot" box.
- After any stock flash, re-flash the recovery before doing custom
  work again, and take a fresh backup (including EFS) once the
  phone is back on stock.
- /data decryption inside the recovery is **unproven on this
  device** (the afaneh92 build lists encryption as not fully
  working). Test a /data backup before relying on it. Keep your
  real backups on the system side.

## Troubleshooting

- **Odin does not see the phone.** Reinstall the Samsung USB
  Driver, try another port (on the PC itself, not a hub) and
  another data cable. Confirm the phone is in Download mode, not
  just charging.
- **Recovery is gone after a boot.** You booted to system first.
  Re-flash from step 2 and boot straight to recovery this time,
  with the USB cable connected.
- **Stuck on the Samsung logo after flashing.** Boot into recovery
  and Format Data again.
- **Recovery asks for a password or cannot mount /data.** That is
  the known encryption bug. Format Data (step 6) removes
  encryption. If you need the data on /data, stop: back it up from
  the running system first, then format.

## Next step

Root the phone: [root.md](root.md). Or flash something:
[flash-stock.md](flash-stock.md),
[flash-gsi.md](flash-gsi.md), [flash-un1ca.md](flash-un1ca.md),
[flash-kernel.md](flash-kernel.md).

## Sources

- No official TWRP for r9s: twrp.me has no r9s device page
  (checked by search 2026-11-25); official S21 FE TWRP is
  Snapdragon-only, XDA thread
  https://xdaforums.com/t/recovery-official-twrp-for-galaxy-s21-fe-5g-snapdragon-with-crypt-support.4677578/
- Unofficial TWRP, install steps, vbmeta USERDATA slot,
  multidisabler terminal steps, Format Data, known bug:
  "[CLOSED][RECOVERY][UNOFFICIAL] TWRP for Galaxy S21 FE
  (Exynos)",
  https://xdaforums.com/t/closed-recovery-unofficial-twrp-for-galaxy-s21-fe-exynos.4421829/
  (initial release 2022-03-26; download link struck through in
  the copy indexed 2026-06-10).
- afaneh92 TWRP rejected by UN1CA (E3000): upstream
  `target/r9s/installer/assertions.edify`, verified live
  2026-11-25 (see [flash-un1ca.md](flash-un1ca.md)).
- OrangeFox R11.3 thread (bekirakil, 2025-10-30) and
  OrangeFox-R12.1-Beta-r9s.img.tar: XDA S21 FE forum,
  https://xdaforums.com/f/samsung-galaxy-s21-fe.12389/, and
  "StockLite rom for SM-G990E",
  https://xdaforums.com/t/stocklite-rom-for-sm-g990e.4719034/
- Recovery trees:
  https://github.com/MLXProjects/recovery_samsung_r9s
- Shared tooling (Odin3 v3.14.1 size and SHA-256, Samsung USB
  Driver, Download mode combo, boot-straight-to-recovery rule):
  `../m51/flash-twrp.md` in this repo.
