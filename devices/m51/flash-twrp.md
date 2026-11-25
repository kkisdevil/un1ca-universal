> Mirror of the verified m51 guides. Canonical home is the [m51-hyperos repo](https://github.com/kkisdevil/m51-hyperos) (`docs/devices/m51/`); if the two copies disagree, that copy wins.

# Flash TWRP - Galaxy M51 (SM-M515F)

Flash the custom recovery on the SM-M515F and keep it. This file
is for the SM-M515F only. Do not use it on any other model.

## What TWRP is

TWRP is a custom recovery: the menu you boot into to install zips,
make backups, and wipe. Everything in this repo is flashed through
it. Our phone runs it, and every other procedure in this folder
assumes it.

## Verified build

TWRP **3.7.0_11-0** for m51, built 2025-06-05, Android 11 base,
kernel Linux 4.14.190+. The image on our phone was checked
file-by-file against the reference build and is identical
(version, fingerprint
`samsung/twrp_m51/m51:11/RQ1A.210205.004/runner06050938`, build date,
build host). Full check:
[../../twrp-user-check.md](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/twrp-user-check.md).

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
   information: model must read **SM-M515F** and the service
   provider software version must show **INS**.

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
  it.
- `vbmeta_disabled.tar`: a disabled vbmeta, so the unsigned TWRP
  and GSI can boot. Named in the XDA TWRP thread below.
- The **TWRP tar** for m51, from the XDA thread
  "[RECOVERY][UNOFFICIAL] TWRP for Galaxy M51 (Snapdragon)":
  https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-m51-snapdragon.4559657/
- `multidisabler`, named in the same thread. It stops stock from
  re-encrypting or re-locking things after the flash.

## Steps

1. Boot into Download mode: power off, hold **Volume Up + Volume
   Down**, connect USB, press **Volume Up** at the warning.
2. Open Odin **as administrator**. The `ID:COM` box turns blue and
   shows `Added!` when the phone is detected. If nothing appears,
   the driver, cable, or port is the problem. Do not proceed.
3. Load `vbmeta_disabled.tar` in Odin and flash it (AP slot, as in
   the XDA thread). Wait for PASS.
4. Load the **TWRP tar in the AP slot** and flash it. Wait for
   PASS.
5. **The moment Odin shows PASS, boot straight into recovery. Do
   not let the phone boot to system.** Hold **Volume Up + Power**
   until the TWRP logo appears. If the phone boots to system
   first, stock recovery gets restored and you have to flash TWRP
   again.
6. In TWRP, run **`multidisabler`**: Install, select the zip,
   flash it.
7. **Format Data:** Wipe, Format Data, type `YES`. This is a
   format, not a wipe. It removes encryption so TWRP and the ROM
   can use /data.
8. Reboot, System for a stock boot, or stay in TWRP for the next
   flash (root, GSI, UN1CA, or kernel).

## Verify

- Reboot to recovery (power off, hold Volume Up + Power). TWRP
  **3.7.0_11-0** opens. The version is shown on the main screen.
- In TWRP, /data mounts and Format Data completed without errors.

## Keeping TWRP: the rules

- A full stock AP flash **replaces TWRP** with stock recovery
  (the stock AP tar contains `recovery.img`). To keep TWRP, either
  remove `recovery.img` from the AP tar before flashing (advanced:
  re-pack the tar and recompute the trailing MD5; the `.md5`
  suffix is only a checksum footer, not a signature), or flash
  stock and then **immediately re-flash TWRP before the first boot
  into system** (steps 2 to 5 above, then boot straight into
  recovery).
- Never let a ROM's own updater touch recovery. Do not check any
  "update recovery on first boot" box. On this device that flow is
  broken and will cost you a re-flash through Odin.
- After any stock flash, re-flash TWRP before doing custom work
  again, and take a fresh TWRP backup (including EFS) once the
  phone is back on stock.
- /data decryption inside TWRP (FBE) is present in code but
  **unproven on the device**. Test a /data backup before relying
  on it. Keep your real backups on the system side.
- Do **not** follow the vbmeta-on-USERDATA variant that appears in
  some other guides. It puts a vbmeta image on the userdata
  partition, which is unusual and unverified. The XDA-thread route
  above is the one our docs use.

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
