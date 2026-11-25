# Flash TWRP - Galaxy S21+ 5G (SM-G996B)

Flash the custom recovery on the SM-G996B and keep it. This file
is for the SM-G996B only. Do not use it on any other model.

## What TWRP is

TWRP is a custom recovery: the menu you boot into to install zips,
make backups, and wipe. Everything in this repo is flashed through
it. Every other procedure in this folder assumes it.

## Verified build

There is **no official TWRP for t2s**. No twrp.me device page for
the Galaxy S21+ 5G (t2s) turned up in search on 2026-11-25, and
the builds that exist are unofficial, by XDA Senior Member
afaneh92. The XDA thread is titled "[CLOSED][RECOVERY]
[UNOFFICIAL] TWRP for Galaxy S21+ (Exynos)" and is closed, not
open for further replies.

- First release: **TWRP 3.5.0**, 2021-03-03. Known bugs at the
  time: haptic feedback did not work, encryption worked only
  partially.
- Latest changelog entry in the thread: **TWRP 3.6.0**,
  2021-11-29 (updated kernel source, updated multidisabler,
  fstab clean up). Thread replies also mention 3.6.x builds.
- TODO: the exact latest TWRP tar filename, its size, and its
  hash for t2s. The thread's download links were not readable
  from the fetched copy, so no filename or hash is stated here.
  Do not flash a file whose name and hash you have not checked
  against the thread.
- TODO: is the image verified against a reference build? No
  verification has been done for this device. Say so plainly:
  nothing here is verified against a reference build the way the
  m51 TWRP was.
- Known limitation from the thread: "Encryption does not work
  fully." Backups of /data from TWRP on this device are
  therefore not to be relied on; keep real backups on the system
  side.

## Prereqs

1. **Unlocked bootloader.** Do
   [unlock-bootloader.md](unlock-bootloader.md) first.
2. **Back up everything** and back up EFS in TWRP if it is already
   installed. Flashing TWRP itself does not wipe data, but the
   Format Data step below does.
3. **Log out of Google and Samsung accounts** before wiping, or
   Factory Reset Protection can lock you out afterwards.
4. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself. No hubs, no front-panel ports.
5. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-G996B** (or SM-G996B/DS).

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
  it. (Shared Samsung tooling, cited from the m51 docs.)
- `vbmeta_disabled_R.tar`: a disabled vbmeta. See the conflict
  note in the steps below.
- The **TWRP tar** for t2s, from the XDA thread
  "[CLOSED][RECOVERY][UNOFFICIAL] TWRP for Galaxy S21+
  (Exynos)":
  https://xdaforums.com/t/closed-recovery-unofficial-twrp-for-galaxy-s21-exynos.4241935/page-2
- `multidisabler`, named in the same thread (credit to @ianmacd).
  It stops stock from re-encrypting or re-locking things after
  the flash. The thread says to run it from Advanced, Terminal,
  and to run it twice (see steps).

## Steps

These steps follow the XDA thread, not the m51 procedure. The
slots differ: this thread puts vbmeta in the USERDATA slot.

1. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
2. Open Odin **as administrator**. The `ID:COM` box turns blue and
   shows `Added!` when the phone is detected. If nothing appears,
   the driver, cable, or port is the problem. Do not proceed.
3. Load the **TWRP tar in the AP slot** and
   `vbmeta_disabled_R.tar` in the **USERDATA slot**, then click
   Start. Wait for PASS.
4. **The moment Odin shows PASS, boot straight into recovery. Do
   not let the phone boot to system.** Hold **Volume Up + Power
   with USB connected** until the TWRP logo appears. If the phone
   boots to system first, stock recovery gets restored and you
   have to flash TWRP again.
5. In TWRP, disable encryption: Advanced, Terminal, type
   `multidisabler`. If it complains about free space, it tries to
   resize the vendor partition; run `multidisabler` again until
   it shows Finished.
6. **Format Data:** Wipe, Format Data, type `yes`. This is a
   format, not a wipe. It removes encryption so TWRP and the ROM
   can use /data.
7. Reboot to recovery, then flash the Magisk APK in TWRP if you
   want root now (see [root.md](root.md)), then Reboot, System.

TODO: vbmeta conflict in the thread. The thread's step 4 says to
flash `vbmeta_disabled_R.tar` in the USERDATA slot, but the same
thread's changelog for 2021-08-09 says "No vbmeta disable
require". It is not clear from the fetched thread whether the
vbmeta step is still needed on current (Android 15) firmware, or
whether it was dropped after that changelog entry. Verify on a
real t2s on current firmware before treating either line as the
rule, and record which one worked. Do not copy the m51 vbmeta
route (AP slot) for this device: the t2s thread says USERDATA.

## Verify

- Reboot to recovery (power off, hold Volume Up + Power with USB
  connected). TWRP opens. The version is shown on the main
  screen; expect 3.6.x from the latest thread builds.
- In TWRP, /data mounts and Format Data completed without errors.
- TODO: confirm the exact version string shown by the latest
  thread build on a real phone.

## Keeping TWRP: the rules

- A full stock AP flash **replaces TWRP** with stock recovery
  (the stock AP tar contains `recovery.img`). To keep TWRP, either
  remove `recovery.img` from the AP tar before flashing (advanced:
  re-pack the tar and recompute the trailing MD5; the `.md5`
  suffix is only a checksum footer, not a signature), or flash
  stock and then **immediately re-flash TWRP before the first boot
  into system** (steps 2 to 4 above, then boot straight into
  recovery).
- TODO: does the t2s stock AP tar contain `recovery.img`? It is
  assumed yes (standard Samsung layout, as on m51), but it has
  not been checked against a t2s AP tar in this repo. Verify by
  listing the AP tar contents before relying on this rule.
- Never let a ROM's own updater touch recovery.
- After any stock flash, re-flash TWRP before doing custom work
  again, and take a fresh TWRP backup (including EFS) once the
  phone is back on stock.
- /data decryption inside TWRP is **not working fully** on this
  device (thread bug list). Test a /data backup before relying
  on it. Keep your real backups on the system side.

## Troubleshooting

- **Odin does not see the phone.** Reinstall the Samsung USB
  Driver, try another port (on the PC itself, not a hub) and
  another data cable. Confirm the phone is in Download mode, not
  just charging.
- **TWRP is gone after a boot.** You booted to system first.
  Re-flash from step 2 and boot straight to recovery this time.
- **TWRP splash screen flickers on and off, or TWRP bootloops.**
  Reported in the thread. The thread's fix from afaneh92: force
  reboot to Download mode (connect USB, press both volume
  buttons) and flash the latest TWRP 3.6.x again. Do not flash a
  patched AP file in the AP slot in place of the TWRP tar: that
  mistake caused a constant bootloop for one reporter.
- **Stuck on the Samsung logo after flashing.** Boot into recovery
  and Format Data again.
- **TWRP asks for a password or cannot mount /data.** That is the
  thread's known encryption limitation. Format Data (step 6)
  removes encryption. If you need the data on /data, stop: back
  it up from the running system first, then format.

## Next step

Root the phone: [root.md](root.md). Or flash something:
[flash-stock.md](flash-stock.md),
[flash-gsi.md](flash-gsi.md), [flash-un1ca.md](flash-un1ca.md),
[flash-kernel.md](flash-kernel.md).

## Sources

- XDA thread "[CLOSED][RECOVERY][UNOFFICIAL] TWRP for Galaxy
  S21+ (Exynos)" by afaneh92:
  https://xdaforums.com/t/closed-recovery-unofficial-twrp-for-galaxy-s21-exynos.4241935/page-2
  (supported models G996B/N; TWRP tar in AP slot,
  vbmeta_disabled_R.tar in USERDATA slot; recovery combo Vol Up
  + Power + USB; multidisabler twice; Format Data; changelog
  3.5.0 2021-03-03, 3.6.0 2021-11-29, "No vbmeta disable
  require" 2021-08-09; encryption not fully working; thread
  closed).
- XDA news "TWRP ports are now available for the Samsung Galaxy
  S21, S21 Plus, and S21 Ultra":
  http://www.xda-developers.com/unofficial-twrp-samsung-galaxy-s21-plus-ultra/
  (unofficial TWRP 3.5.0, Exynos SM-G996B/N, codename t2s).
- Odin3 v3.14.1 size and SHA-256, Samsung USB Driver, and the
  "boot straight into recovery after PASS" rule: shared Samsung
  tooling, cited from [../m51/flash-twrp.md](../m51/flash-twrp.md).
- No twrp.me device page for t2s found in web search on
  2026-11-25; that absence is the basis for "no official TWRP".

## TODO

- Exact latest TWRP tar filename, size, and hash for t2s.
- Verification of the TWRP image against a reference build.
- The vbmeta conflict (USERDATA slot vs "No vbmeta disable
  require") on current Android 15 firmware.
- Confirm the t2s stock AP tar contains `recovery.img`.
- Confirm the exact TWRP version string shown on a real phone.
