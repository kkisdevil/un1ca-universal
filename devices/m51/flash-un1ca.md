> Mirror of the verified m51 guides. Canonical home is the [m51-hyperos repo](https://github.com/kkisdevil/m51-hyperos) (`docs/devices/m51/`); if the two copies disagree, that copy wins.

# Flash UN1CA - Galaxy M51 (SM-M515F)

Flash the UN1CA One UI port on the SM-M515F. This file is for the
SM-M515F only. Do not use it on any other model.

## What UN1CA is

UN1CA is a One UI port: Samsung's flagship firmware (Galaxy S22
base, One UI 9 / 9.5) rebuilt for the m51, with Galaxy AI, DeX,
KnoxPatch, Play Integrity Fix, and its own OTA app. Our builds live
in the sister repo
https://github.com/kkisdevil/un1ca-universal (the universal porter:
one manifest plus resolver, per-device targets; upstream is
https://github.com/salvogiangri/UN1CA, our m51 target is Arnav's
`seventeen` branch, UN1CA 5.4.0).

## Build status (honest)

Three builds succeeded (#5, #7, #8). Latest is **#8** (run
45491802857, 1h 35m, all jobs green): the performance fix pack
**plus** the daemon fix (see below). Artifact
`UN1CA-m51-decrypted`, 10.9 GB, SHA-256
`fe7201a28d6becbd056d4ba27515aecbee091fae8a54f11fd7a403a3d07c020e`,
7-day retention. Download by about 2026-12-02. Signed with
throwaway test keys (real keys are an open decision). **Not yet
flashed or tested on the m51.** The thorough artifact check is
waiting on the download, and the flash itself needs the phone in
hand.

## What the zip does (read before flashing)

- It flashes Samsung's own DXJ2 bootloader and modem firmware.
- It wipes fingerprint enrolments and dalvik-cache on every flash.
- It asserts the bootloader is **≥ DXE3**. The phone must already
  be on bootloader DXE3 or newer (any recent stock or UN1CA build
  is).
- It does **not** touch recovery. The installer deletes
  `recovery.img` from the zip. That is the TWRP rule, kept.

## The lag fix pack (in builds #7 and #8)

The S23 firmware on this 730G lags: thermal caps at 35 to 38 °C,
live blur forced on, zram off plus swappiness 100. The pack
relaxes the thermal caps (CPU cap at 45 °C, GPU 565 to 650 MHz,
game floor 430 MHz), turns blur off in both places it is forced
on, restores zram with swappiness 60, and neutralises the
`carbon_power_engine` daemon that resets swappiness to 100 at
every boot (build #7's effective swappiness was 100, not 60: the
daemon fix in #8 is what makes 60 stick). All flagship features
are kept. **Only blur is removed**, by the user's own rule.

## How the build is made

The workflow downloads the three stock firmwares (S21 FE source,
m51 target, and one more), extracts them, applies the m51 target
(Arnav's `seventeen` at `f679035535`, vendored in our repo) and
the performance patches, then builds the flashable zip with
`avbroot` and `signapk` signing. Firmware download uses
**samloader-rs v2.0.0** (pinned, SHA-256 verified). The OTA system
(manifest schema, incrementals about 155 MB, fulls about 5.9 GB,
`id` = SHA-256) comes from Mehedi's `static_resources` pattern,
retargeted to our own repo before any release run.

## Prereqs

1. **TWRP installed** ([flash-twrp.md](flash-twrp.md)).
2. **Back up everything** and back up EFS in TWRP first. A Format
   Data is needed when coming from stock or another ROM.
3. **Battery above 50%, ideally full.**
4. **Check the phone first.** Settings, About phone, Software
   information: model must read **SM-M515F** and the service
   provider software version must show **INS**.
5. The phone must already be on bootloader **≥ DXE3**.
6. The UN1CA zip (about 5.5 GB) on the phone or an SD card, and
   its SHA-256 checked against the build record.

## Steps

1. TWRP installed (prereq 1), backup taken (prereq 2). The phone
   must already be on bootloader ≥ DXE3.
2. Copy the UN1CA zip to the phone (or an SD card).
3. In TWRP: Wipe, Format Data, type `YES` if coming from stock or
   another ROM (encryption differs). If updating from an older
   UN1CA, a dirty flash is usually fine. The zip wipes dalvik
   itself.
4. Install, select the UN1CA zip, flash it. Wait. It is a 5.5 GB
   zip and it also flashes the BL and modem.
5. Reboot, System. First boot takes several minutes. Set up, then
   leave the phone idle about 30 min for dexopt before judging
   lag.
6. Check the lag fix landed (see "Verify" below).

## Verify

- `adb shell cat /proc/sys/vm/swappiness` must read **60** (the
  effective value, never the prop).
- `adb shell dumpsys SurfaceFlinger` should show 60.00 Hz.
- After the 30 min idle: scrolling is smooth at 60 Hz, apps stay
  in memory instead of being killed, and the phone does not
  throttle to 1.71 GHz at 35 °C.
- Settings shows the UN1CA version (5.4.0) and the device name
  Galaxy M51.

## Troubleshooting

- **Installer refuses with a bootloader assertion.** The phone is
  below DXE3. Flash the stock DXJ1 firmware first
  ([flash-stock.md](flash-stock.md)), which is bootloader 6, then
  retry.
- **Bootloop after flashing.** Boot into TWRP, Format Data, and
  re-flash the zip. If it still bootloops, capture a log (`adb
  logcat -d`) before wiping, and report it.
- **Swappiness reads 100, not 60.** The daemon fix did not land.
  Check the build number: only build #8 and later carry it. Build
  #7 reads 100 at runtime.
- **Fingerprint enrolments are gone after flashing.** Expected.
  The zip wipes them on every flash. Re-enrol.
- **Lag is still bad after 30 min idle.** Record the numbers
  (swappiness, thermal zones, frequencies) and report them with a
  log bundle. Do not judge speed before dexopt finishes.

## Going back to stock

Flash the [flash-stock.md](flash-stock.md) firmware with Odin
(AP/BL/CP/CSC), then Format Data in stock recovery. Knox stays
tripped. That cannot be undone.
