# Flash TWRP - Galaxy A53 5G (SM-A536B)

Flash the custom recovery on the SM-A536B and keep it. This file
is for the SM-A536B only. Do not use it on any other model. The
A53 5G is an Exynos phone (Exynos 1280, s5e8825): the recovery
lives on the recovery partition and Magisk installs to recovery,
not to boot. That changes the root order below, so read the
"Root first" box before flashing anything.

## What TWRP is on this device

TWRP is a custom recovery: the menu you boot into to install
zips, make backups, and wipe. Everything in this repo is flashed
through it.

**TWRP is official for this device.** Support status is Current,
maintainer mytja, codename a53x, on
https://twrp.me/samsung/samsunggalaxya53.html. The XDA thread is
"[RECOVERY][OFFICIAL] TWRP 3.7.1-12 for Galaxy A53 5G":
https://xdaforums.com/t/recovery-unofficial-twrp-3-7-1-12-for-galaxy-a53-5g.4680051/
The same maintainer previously shipped it as unofficial in
"[RECOVERY][UNOFFICIAL] TWRP for Galaxy A53 5G (Exynos)":
https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-a53-5g-exynos.4467443/post-89444919
The official build is universal for A536B and A536E, but it is
only tested on A536B. These guides cover A536B only.

There is no LineageOS recovery or other recovery in use for this
device in our docs. TWRP is the recovery this device uses.

## Root first: read this before flashing TWRP

This device uses system-as-root in an A-only partition layout,
and **Magisk installs to the recovery partition, not the boot
partition**. Both TWRP and a Magisk-rooted Android boot using the
recovery kernel, and the hardware keys choose between TWRP and
Android at boot time. The official TWRP page therefore strongly
advises: **first root the device with Magisk, then pre-root a
TWRP image, then flash that to recovery**. The usual path of
installing TWRP before rooting is problematic on this device,
because the Magisk installer does not support installation to
recovery from TWRP. Rooting first also disables device protection
mechanisms you would otherwise have to handle by hand.

So the order for this device is:
[unlock-bootloader.md](unlock-bootloader.md), then
[root.md](root.md) Method A (patch the stock AP with Magisk),
then this file. If you flash plain TWRP first anyway, read the
pitfalls in "Troubleshooting" below: a stock device is protected
by Android Verified Boot, and flashing TWRP without first
flashing a vbmeta image with verity disabled will leave the
device unable to boot.

## Verified build

TWRP **3.7.1-12** for a53x, maintainer mytja. Initial release
2024-07-06. The XDA thread was last edited 2026-01-02, when the
build went official. The thread attachment is
`a53x_twrp-mytja-001.tar` (44.6 MB). The TWRP kernel comes from
https://github.com/mytja/android_kernel_samsung_a53x/tree/twrp-12.1
and the device tree from
https://github.com/mytja/android_device_samsung_a53x.

TODO: the image has not been verified against a reference build
by us. Before flashing, download from https://dl.twrp.me/a53x/
and check the version shown on the TWRP main screen after the
flash. No SHA-256 for the current file was found in the sources
checked; do not trust a hash from a mirror.

## Prereqs

1. **Unlocked bootloader.** Do
   [unlock-bootloader.md](unlock-bootloader.md) first.
2. **Rooted with Magisk first** (see "Root first" above), unless
   you deliberately take the TWRP-first route and accept its
   pitfalls.
3. **Back up everything** and back up EFS in TWRP if it is already
   installed. Flashing TWRP itself does not wipe data, but the
   Format Data step below does.
4. **Log out of Google and Samsung accounts** before wiping, or
   Factory Reset Protection can lock you out afterwards.
5. **Battery above 50%, ideally full.** A good USB data cable and
   a USB port on the PC itself. No hubs, no front-panel ports.
6. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-A536B** and the service
   provider software version must show **EUX**.

## What you need

- A Windows PC with the **Samsung USB Driver** installed (from
  Samsung: developer.samsung.com) and Samsung Smart Switch closed.
  On Linux, Odin4 speaks the same protocol (the XDA thread names
  Odin3 for Windows and Odin4 for Linux).
- **Odin3 v3.14.1**. Odin is Windows-only. Odin is a leaked
  internal tool, not officially distributed by Samsung, and its
  binary is never committed to our repos.
- TODO: Odin SHA-256 not verified from a trusted source for this
  device. Verify the hash from the XDA Odin3 thread before
  opening it. Do not copy a hash from another device's guide.
- A **patched vbmeta is already included** in the official TWRP
  tar, per the XDA thread. You do not need a separate
  vbmeta_disabled tar for the official build.
- The **TWRP tar** for a53x, from https://dl.twrp.me/a53x/ or
  the XDA thread above.
- **Do NOT run multidisabler.** The official XDA thread says so
  plainly: running multidisabler inside the TWRP terminal after
  flashing will cause OneUI bootloops. The older unofficial
  thread used a terminal `multidisabler` step; the official
  build supersedes that. Do not follow the old step.

## Steps

1. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
   (`adb reboot download` works too.)
2. Open Odin **as administrator**. The `ID:COM` box turns blue and
   shows `Added!` when the phone is detected. If nothing appears,
   the driver, cable, or port is the problem. Do not proceed.
3. Load the **TWRP tar in the AP slot** and flash it. Wait for
   PASS. (On Linux, the same AP flash is done with the `-a` flag
   on odin4.)
4. **The moment Odin shows PASS, boot straight into recovery. Do
   not let the phone boot to system.** Hold **Volume Up + Power**
   with the USB cable connected until the TWRP logo appears. If
   the phone boots to system first, stock recovery gets restored
   and you have to flash TWRP again.
5. In TWRP, decrypt or encrypt internal storage only if you need
   it: the official thread notes stock storage is encrypted, so
   TWRP shows 0 MB for internal storage unless you run `decrypt`
   or `encrypt` from the TWRP terminal. Either one **formats
   internal storage**. TWRP can always access an SD card, and
   perhaps USB OTG (untested per the thread).
6. **Format Data if you need /data usable:** Wipe, Format Data,
   type `yes`. This is a format, not a wipe. It removes
   encryption so TWRP and the ROM can use /data.
7. Reboot, System for a stock boot, or stay in TWRP for the next
   flash (root, GSI, UN1CA, or kernel).

## Verify

- Reboot to recovery (power off, hold Volume Up + Power with USB
  connected). TWRP **3.7.1-12** opens. The version is shown on
  the main screen.
- In TWRP, /data mounts and Format Data completed without errors.
- MTP works in TWRP (stated in the XDA thread). Note: the
  maintainer reports MTP trouble on Linux kernels 6.x (dmesg
  segfaults in libc); on Ubuntu 20.04 with kernel 5.15 it works.

## Keeping TWRP: the rules

- A full stock AP flash **replaces TWRP** with stock recovery
  (the stock AP tar contains `recovery.img`). To keep TWRP, either
  remove `recovery.img` from the AP tar before flashing (advanced:
  re-pack the tar and recompute the trailing MD5; the `.md5`
  suffix is only a checksum footer, not a signature), or flash
  stock and then **immediately re-flash TWRP before the first boot
  into system** (steps 1 to 4 above, then boot straight into
  recovery).
- Never let a ROM's own updater touch recovery. Do not check any
  "update recovery on first boot" box.
- After any stock flash, re-flash TWRP before doing custom work
  again, and take a fresh TWRP backup (including EFS) once the
  phone is back on stock.
- TODO: /data decryption inside TWRP (FBE) on this device is
  unproven by us. The official thread offers the terminal
  `decrypt` / `encrypt` commands, which format storage. Test a
  /data backup before relying on it. Keep your real backups on
  the system side.
- Do **not** follow the vbmeta-on-USERDATA variant that appears
  in the older unofficial thread (vbmeta_disabled_R.tar in the
  USERDATA slot). It puts a vbmeta image on the userdata
  partition, which is unusual and unverified, and the official
  build already includes a patched vbmeta. The official-thread
  route above is the one our docs use.

## Troubleshooting

- **Odin does not see the phone.** Reinstall the Samsung USB
  Driver, try another port (on the PC itself, not a hub) and
  another data cable. Confirm the phone is in Download mode, not
  just charging.
- **TWRP is gone after a boot.** You booted to system first.
  Re-flash from step 1 and boot straight to recovery this time.
- **Stuck on the Samsung logo after flashing.** The unofficial
  thread notes: reboot to TWRP and wipe metadata from the
  Advanced Wipe section. If that fails, Format Data again.
- **TWRP asks for a password or cannot mount /data, or shows
  0 MB internal storage.** That is stock encryption. Either run
  `decrypt` from the TWRP terminal (formats internal storage) or
  Format Data (step 6). If you need the data on /data, stop: back
  it up from the running system first, then format.
- **OneUI bootloops after flashing TWRP.** You probably ran
  multidisabler. The official thread warns it causes OneUI
  bootloops on this build. Re-flash stock (see
  [flash-stock.md](flash-stock.md)) and start over without it.

## Next step

Flash something: [flash-stock.md](flash-stock.md),
[flash-gsi.md](flash-gsi.md), [flash-un1ca.md](flash-un1ca.md),
[flash-kernel.md](flash-kernel.md). Or root, if you came here
before rooting: [root.md](root.md).

## Sources

- Official TWRP page (status Current, maintainer mytja, dynamic
  partitions, system-as-root A-only, Magisk to recovery,
  root-first advice, vbmeta warning):
  https://twrp.me/samsung/samsunggalaxya53.html
- Official XDA thread (3.7.1-12, install steps, patched vbmeta
  included, no multidisabler, decrypt/encrypt, MTP, A536B/A536E,
  kernel and device tree links, last edited 2026-01-02):
  https://xdaforums.com/t/recovery-unofficial-twrp-3-7-1-12-for-galaxy-a53-5g.4680051/
- Unofficial XDA thread (older route: vbmeta in USERDATA slot,
  terminal multidisabler, metadata wipe for logo bootloop,
  encryption not fully working):
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-a53-5g-exynos.4467443/post-89444919
- Download mode and recovery key combos:
  https://magiskzip.com/install-twrp-recovery-on-samsung-galaxy-a53-5g/
