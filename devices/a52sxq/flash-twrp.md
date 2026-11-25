# Flash TWRP - Galaxy A52s 5G (SM-A528B)

Flash the custom recovery on the SM-A528B and keep it. This file
is for the SM-A528B only. Do not use it on any other model.

## What TWRP is

TWRP is a custom recovery: the menu you boot into to install zips,
make backups, and wipe. Everything in this folder is flashed
through it. The A52s has **official** TWRP, not unofficial: the
twrp.me device page lists Support Status Current, maintainer
BlackMesa123, codename a52sxq.

This device uses **Dynamic Partitions**. TWRP will not allow
modifications to any of the partitions that make up the Super
partition on the stock ROM. All backups and restores include the
full Super partition rather than the individual dynamic
partitions. To flash the individual partitions, boot into
fastbootd. That matters for the GSI guide:
[flash-gsi.md](flash-gsi.md).

## Verified build

TWRP **3.7.1_12-0** for a52sxq, file
`twrp-3.7.1_12-0-a52sxq.img.tar`, 78 MB, dated 2024-02-18 01:19:38
UTC, from the official download mirror (eu.dl.twrp.me/a52sxq).
The previous build, 3.7.0_12-4 (2023-12-24), updated the kernel
to EWJ1, added Android 14 decrypt support, and set the framerate
to 120 Hz. The 3.7.1_12-0 build has **not** been file-verified by
us against a reference build in this session: the version, date,
and size above are from the official mirror listing, not from a
download we hashed. TODO: download it, record its SHA-256, and
confirm the version string on the phone.

Sources for the build: TWRP kernel source
https://github.com/BlackMesa123/android_kernel_samsung_sm7325/tree/sep-15/twrp-12.1
and device tree
https://github.com/TeamWin/android_device_samsung_a52sxq
(both linked from the XDA TWRP thread).

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
   information: model must read **SM-A528B**. The UN1CA target
   firmware is the BTU region build (upstream
   `target/a52sxq/config.sh` line 13); check your own CSC in the
   service provider software version and do not flash another
   region's files on it.

## What you need

- A Windows PC with the **Samsung USB Driver** installed (from
  Samsung: developer.samsung.com) and Samsung Smart Switch closed.
- **Odin3 v3.14.1** (the conservative choice used across Samsung
  devices). Odin is Windows-only. On Linux, `samloader-rs flash`
  speaks the same Odin protocol, and the twrp.me page also
  documents a Heimdall route (untar the `.img.tar` and flash the
  `.img` with Heimdall). Odin is a leaked internal tool, not
  officially distributed by Samsung, and its binary is never
  committed to our repos. TODO: verify the Odin ZIP SHA-256 from
  a trusted source in this session. Do not copy any hash from
  another device's guide without checking it.
- `vbmeta_disabled.tar` (also called `vbmeta_disabled_R.tar` in
  the GetDroidTips guide): a disabled vbmeta, so the unsigned
  TWRP can boot. Named in the XDA TWRP thread and in the
  Droidwin guide (`vbmeta_patched.tar` there).
- The **TWRP tar** for a52sxq, `twrp-3.7.1_12-0-a52sxq.img.tar`,
  from https://dl.twrp.me/a52sxq/ (or the Europe mirror
  https://eu.dl.twrp.me/a52sxq/).
- `multidisabler`, as used in the GetDroidTips A52s guide: run
  from TWRP Advanced, Terminal, by typing `multidisabler`. It
  stops stock from re-encrypting or re-locking things after the
  flash. TODO: record the exact multidisabler version and source
  link for this device; the guide names the command but not a
  versioned download.

## Steps

1. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
2. Open Odin **as administrator**. The `ID:COM` box turns blue and
   shows `Added!` when the phone is detected. If nothing appears,
   the driver, cable, or port is the problem. Do not proceed.
3. Load `vbmeta_disabled.tar` in Odin and flash it. TODO: confirm
   the slot from the XDA TWRP thread before flashing. The
   GetDroidTips A52s guide puts `vbmeta_disabled_R.tar` in the
   **USERDATA** slot; other Samsung guides put vbmeta in the AP
   slot. The USERDATA-slot route is unusual and is **not verified
   by us** on this device. Do not treat either slot as settled
   until the XDA thread (post 1) is read and the slot it uses is
   recorded here.
4. Load the **TWRP tar in the AP slot** and flash it. Wait for
   PASS. (AP slot for the TWRP tar is stated in the GetDroidTips
   guide and is the standard Samsung route.)
5. **The moment Odin shows PASS, boot straight into recovery. Do
   not let the phone boot to system.** Hold **Volume Up + Power**
   (with USB connected) until the TWRP logo appears. The twrp.me
   page says the same in general terms: many devices replace the
   custom recovery automatically during first boot, and once TWRP
   is booted it patches the stock ROM to prevent the stock ROM
   from replacing TWRP. If the phone boots to system first, stock
   recovery gets restored and you have to flash TWRP again.
6. In TWRP, run **`multidisabler`**: Advanced, Terminal, type
   `multidisabler`. The GetDroidTips guide says if the vendor
   complains about free space it will attempt to resize the
   vendor and ask you to run multidisabler again; type it again
   until it prints `Finished.`
7. **Format Data:** Wipe, Format Data, type `YES`. This is a
   format, not a wipe. It removes encryption so TWRP and the ROM
   can use /data.
8. Reboot, System for a stock boot, or stay in TWRP for the next
   flash (root, GSI, UN1CA, or kernel).

## Verify

- Reboot to recovery (power off, hold Volume Up + Power, with USB
  connected). TWRP **3.7.1_12-0** opens. The version is shown on
  the main screen.
- In TWRP, /data mounts and Format Data completed without errors.
- The 3.7.0_12-4 changelog says Android 14 decrypt is supported
  and the framerate is set to 120 Hz, matching this phone's 120 Hz
  display. TODO: confirm on-device that TWRP asks for the PIN
  and decrypts /data on Android 14 firmware, rather than
  assuming the changelog claim.

## Keeping TWRP: the rules

- A full stock AP flash **replaces TWRP** with stock recovery
  (the stock AP tar contains `recovery.img`). TODO: confirm by
  listing the contents of the A528BXXSBGYI3 AP tar in this
  session; this is standard Samsung behaviour and is stated here
  on that basis, not from a listing we made. To keep TWRP, either
  remove `recovery.img` from the AP tar before flashing (advanced:
  re-pack the tar and recompute the trailing MD5; the `.md5`
  suffix is only a checksum footer, not a signature), or flash
  stock and then **immediately re-flash TWRP before the first boot
  into system** (steps 2 to 5 above, then boot straight into
  recovery).
- Never let a ROM's own updater touch recovery. Do not check any
  "update recovery on first boot" box.
- After any stock flash, re-flash TWRP before doing custom work
  again, and take a fresh TWRP backup (including EFS) once the
  phone is back on stock. The UN1CA XDA thread recommends backing
  up Boot, DTBO, Vendor Boot, and Super before flashing UN1CA.
  Note that on this dynamic-partition device, Super is backed up
  as a whole, not as individual partitions.
- /data decryption inside TWRP (FBE) is claimed for Android 14 in
  the 3.7.0_12-4 changelog but is **unproven by us on this
  device**. Test a /data backup before relying on it. Keep your
  real backups on the system side.
- Do **not** follow the vbmeta-on-USERDATA variant without
  verifying it against the XDA TWRP thread first (see step 3).
  It puts a vbmeta image on the userdata partition, which is
  unusual and unverified by us.

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
  unproven FBE decryption. Format Data (step 7) removes
  encryption. If you need the data on /data, stop: back it up from
  the running system first, then format.

## Next step

Root the phone: [root.md](root.md). Or flash something:
[flash-stock.md](flash-stock.md),
[flash-gsi.md](flash-gsi.md), [flash-un1ca.md](flash-un1ca.md),
[flash-kernel.md](flash-kernel.md).

## Sources

- Official TWRP device page (Support Status Current, maintainer
  BlackMesa123, codename a52sxq, Dynamic Partitions note, Odin
  and Heimdall methods): https://twrp.me/samsung/samsunggalaxya52s5G.html
- Official TWRP download mirror (3.7.1_12-0, 78 MB,
  2024-02-18; 3.7.0_12-4, 2023-12-24):
  https://eu.dl.twrp.me/a52sxq/
- XDA TWRP thread (Odin3, Samsung USB Drivers, disabled vbmeta,
  kernel source, device tree, changelog incl. Android 14 decrypt
  and 120 Hz framerate):
  https://xdaforums.com/t/recovery-unofficial-twrp-3-6-2-0-for-galaxy-a52s-5g.4488419/
- GetDroidTips TWRP guide (vbmeta in USERDATA slot, TWRP tar in
  AP slot, multidisabler from Terminal, Format Data):
  https://www.getdroidtips.com/twrp-recovery-galaxy-a52s-5g/
- Droidwin TWRP guide (vbmeta_patched.tar, unlock and Knox
  notes): https://droidwin.com/how-to-install-twrp-recovery-on-galaxy-a52s-5g/
- Upstream `target/a52sxq/config.sh` line 13 (BTU target
  firmware): https://raw.githubusercontent.com/salvogiangri/UN1CA/sixteen/target/a52sxq/config.sh
- TODO: vbmeta Odin slot (USERDATA vs AP) from the XDA TWRP
  thread post 1. TODO: TWRP 3.7.1_12-0 SHA-256 and on-device
  version check. TODO: multidisabler version and download link.
  TODO: confirm the stock AP tar contains recovery.img by
  listing it. TODO: confirm Android 14 /data decryption in TWRP
  on-device.
