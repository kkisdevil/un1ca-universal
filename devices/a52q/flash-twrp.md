# Flash TWRP - Galaxy A52 (SM-A525F)

Flash the custom recovery on the SM-A525F and keep it. This file
is for the SM-A525F only. Do not use it on any other model.

## What TWRP is

TWRP is a custom recovery: the menu you boot into to install zips,
make backups, and wipe. Everything in this folder is flashed
through it, except the stock firmware (Odin) and root Method A
(Magisk patching the AP, see [root.md](root.md)).

**Read this first: this device is different from the m51.** The
official TWRP device page for the a52q says the phone uses
system-as-root in an A-only partition configuration, and that
Magisk installs to the **recovery partition, not the boot
partition**. Both TWRP and Magisk-rooted Android boot using the
recovery kernel, with the hardware keys choosing between TWRP and
Android at boot time. The same page strongly advises rooting with
Magisk first and then pre-rooting a TWRP image before flashing it
to recovery, because installing TWRP before rooting is problematic
on this device: the Magisk installer does not support installation
to recovery from TWRP. If your goal is a rooted phone with TWRP,
do [root.md](root.md) Method A first, then come back here. If you
want TWRP without root, read the pitfalls below: a stock device is
protected by Android Verified Boot, and flashing TWRP without
first flashing a vbmeta image with verity disabled will leave the
device unable to boot.

## Verified build

TWRP **3.7.1_12-0** for a52q, Android 12 base, released
2024-02-18, 43.8 MB. Official status **Current**, maintainers
**Velosh** and **Simon1511**, codename **a52q**. Download from
https://dl.twrp.me/a52q/ (file `twrp-3.7.1_12-0-a52q.img.tar` for
Odin, or `twrp-3.7.1_12-0-a52q.img` for image flashing).

Hashes checked live from dl.twrp.me on 2026-11-25:

- `.img.tar` MD5: `60c57bbb35253fee3f736ff62620820f`
- `.img` SHA-256: `0e6a9abcea4736f2ce34201a6561942cd0c5bd0b398b90d36501dc09ba31e0bc`

Verify before flashing:

```sh
md5sum twrp-3.7.1_12-0-a52q.img.tar
sha256sum twrp-3.7.1_12-0-a52q.img
```

The image was **not** verified by us against a reference build on
a device. The hashes above are the ones published by dl.twrp.me
itself. The recovery partition on this device is 81,788,928 bytes
(78 MiB), so the 43.8 MB image fits with room to spare.

The XDA thread for this TWRP ([RECOVERY][OFFICIAL] TWRP 3.7 for
Galaxy A52 4G and A72 4G) lists Android 11, 12 and 13 support and
encryption support for AOSP and OneUI, with one known bug:
encryption only works on OneUI if no lock screen is set.

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
   information: model must read **SM-A525F** and the service
   provider software version must show **EUX**.
6. **Decide the order: root first or TWRP first.** See "What TWRP
   is" above. For a rooted phone with TWRP, root first
   ([root.md](root.md) Method A), then flash a Magisk-patched
   TWRP image to recovery. For TWRP without root, the vbmeta step
   below is mandatory.

## What you need

- A Windows PC with the **Samsung USB Driver** installed (from
  Samsung: developer.samsung.com) and Samsung Smart Switch closed.
- **Odin3 v3.14.1** (2,595,015 B, SHA-256
  `638296a11b1bfa954991b0597214d833511b973480ae9e15e299a761fea1f794`,
  from the XDA Odin3 thread or https://getodintool.com/). Verify
  with PowerShell before opening it:
  `Get-FileHash .\Odin3-v3.14.1.zip -Algorithm SHA256`.
  Odin is Windows-only. On Linux, `samloader-rs flash` speaks the
  same Odin protocol, and the LineageOS install path for this
  device also uses `samloader-rs` from Download mode. Odin is a
  leaked internal tool, not officially distributed by Samsung, and
  its binary is never committed to our repos. Do not use any file
  claiming to be a newer Odin3 than v3.14.4. Odin3 v3.14.4 is
  disputed (same compile date as v3.14.1, older DLL, an unsigned
  DLL no component references, four different ZIPs circulating).
  We do not recommend it. (Odin version and hash are the shared
  Samsung tool values already verified in this repo, not an a52q
  value.)
- `vbmeta_disabled.tar`: a vbmeta image with verity disabled, so
  the unsigned TWRP can boot. Named in the XDA TWRP thread below.
  TODO: the exact filename and a verified download link for the
  a52q vbmeta file were not pinned down while writing this guide.
  Get it from the XDA thread, not from a random mirror.
- The **TWRP tar** for a52q, `twrp-3.7.1_12-0-a52q.img.tar`, from
  https://dl.twrp.me/a52q/ (hashes above).
- **Multidisabler: not named for this device.** The XDA TWRP
  thread for the a52q does not name a multidisabler step in the
  install excerpt we read. Do not add one without a source. TODO:
  confirm from the full XDA thread whether a multidisabler or
  DM-verity disabler is needed on the a52q after flashing TWRP.

## Steps

1. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
2. Open Odin **as administrator**. The `ID:COM` box turns blue and
   shows `Added!` when the phone is detected. If nothing appears,
   the driver, cable, or port is the problem. Do not proceed.
3. Load `vbmeta_disabled.tar` in Odin and flash it. The XDA TWRP
   thread for this device puts the disabled vbmeta in the
   **USERDATA slot**. That is unusual: the m51 route puts vbmeta
   in the AP slot. The USERDATA slot is what this device's own
   XDA thread prescribes, but we have not verified it with our
   own Odin run on an a52q. Follow the thread, and if Odin
   rejects it, stop and report the exact error instead of
   guessing another slot. Wait for PASS.
4. Load the **TWRP tar in the AP slot** and flash it. Wait for
   PASS.
5. **The moment Odin shows PASS, boot straight into recovery. Do
   not let the phone boot to system.** The moment the screen goes
   black, hold **Volume Up + Power** until the TWRP logo appears.
   (On this device the recovery key combination needs a USB cable
   connected to a PC.) If the phone boots to system first, stock
   recovery gets restored and you have to flash TWRP again.
6. **Format Data:** Wipe, Format Data, type `YES`. This is a
   format, not a wipe. It removes encryption so TWRP and the ROM
   can use /data.
7. Reboot, System for a stock boot, or stay in TWRP for the next
   flash (root, GSI, UN1CA, or kernel).

## Verify

- Reboot to recovery (power off, connect USB, hold Volume Up +
  Power). TWRP **3.7.1_12-0** opens. The version is shown on the
  main screen.
- In TWRP, /data mounts and Format Data completed without errors.

## Keeping TWRP: the rules

- A full stock AP flash **replaces TWRP** with stock recovery
  (the stock AP tar contains `recovery.img`; this is the standard
  Samsung AP layout, TODO to confirm by listing the a52q AP tar).
  To keep TWRP, either remove `recovery.img` from the AP tar
  before flashing (advanced: re-pack the tar and recompute the
  trailing MD5; the `.md5` suffix is only a checksum footer, not
  a signature), or flash stock and then **immediately re-flash
  TWRP before the first boot into system** (steps 2 to 5 above,
  then boot straight into recovery).
- Never let a ROM's own updater touch recovery. Do not check any
  "update recovery on first boot" box.
- After any stock flash, re-flash TWRP before doing custom work
  again, and take a fresh TWRP backup (including EFS) once the
  phone is back on stock.
- /data decryption inside TWRP is **claimed by the XDA thread**
  (encryption support for AOSP and OneUI) but **unproven by us**
  on this device, and the thread itself notes encryption only
  works on OneUI if no lock screen is set. Test a /data backup
  before relying on it. Keep your real backups on the system side.
- **Magisk and TWRP share the recovery partition on this
  device.** Flashing a stock recovery, or a plain TWRP image over
  a Magisk-patched recovery, can cost you root. The TWRP device
  page recommends a Magisk-patched TWRP image (see
  [root.md](root.md)).

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
  encryption limit noted above (OneUI encryption in TWRP only
  works with no lock screen set). Format Data (step 6) removes
  encryption. If you need the data on /data, stop: back it up from
  the running system first, then format.
- **Device will not boot after flashing TWRP.** The vbmeta step
  was skipped or the wrong vbmeta was used. Flashing TWRP without
  a verity-disabled vbmeta leaves the device unable to boot
  (TWRP device page). Re-enter Download mode and flash the
  disabled vbmeta, then TWRP again.

## Next step

Root the phone: [root.md](root.md). Or flash something:
[flash-stock.md](flash-stock.md),
[flash-gsi.md](flash-gsi.md), [flash-un1ca.md](flash-un1ca.md),
[flash-kernel.md](flash-kernel.md).

## Sources

- Official TWRP device page, Samsung Galaxy A52 4G (a52q):
  Support Status Current, maintainers Velosh and Simon1511,
  system-as-root A-only, Magisk in the recovery partition, root
  first then pre-rooted TWRP, vbmeta with verity disabled
  required:
  https://test.twrp.me/samsung/samsunggalaxya52q.html
- Latest build, size, date, and hashes, checked live 2026-11-25
  from https://dl.twrp.me/a52q/ and the per-file pages
  (`twrp-3.7.1_12-0-a52q.img.tar.md5`,
  `twrp-3.7.1_12-0-a52q.img.sha256`).
- XDA thread [RECOVERY][OFFICIAL] TWRP 3.7 for Galaxy A52 4G and
  A72 4G (Android 11, 12 and 13 support, encryption support, the
  OneUI no-lock-screen bug, vbmeta disabled in the USERDATA slot,
  recovery key combination):
  https://xdaforums.com/t/recovery-official-twrp-3-7-for-galaxy-a52-4g-and-a72-4g.4405751/post-89439820
- Recovery partition size 81,788,928 bytes and boot partition size
  100,663,296 bytes: `BoardConfig.mk` in
  https://github.com/TeamWin/android_device_samsung_a52q
  (branch android-12.1).
- Recovery reboot combination (power off, connect USB, hold
  Volume Up + Power): XDA UN1CA thread for the A52 4G and A72 4G,
  https://xdaforums.com/t/eol-rom-14-a525f-m-a725f-m-un1ca-1-1-6-one-ui-6-for-galaxy-a52-4g-a72-4g-12-01-2024.4650551/
- TODO: exact vbmeta_disabled filename and verified link for the
  a52q; whether a multidisabler step is needed; confirmation that
  the stock AP tar contains `recovery.img`; TWRP image not yet
  verified against a reference build on a device.
