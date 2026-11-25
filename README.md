# UN1CA Universal

Universal UN1CA porter — build One UI ROMs for every Samsung phone, per SoC family, GitHub Actions only.

## Goal

One universal *porter*, not one universal zip. A single flashable zip cannot work for every Samsung phone: each device needs its own kernel, vendor blobs, camera, modem, display and CSC, and different SoCs, partitions and bootloaders break a single build.

This project aims to make UN1CA available for as many Samsung phones as possible by:

1. Grouping devices by SoC family (SM7150 first, then SM8250, SM8350, Exynos 2100/2200, and others)
2. Taking a stock firmware + codename as input
3. Picking the right UN1CA base, applying its patches, and injecting that device's vendor / kernel / CSC
4. Building a tested flashable zip with GitHub Actions — no private servers

## Status

- Base UN1CA covers about 15 codenames: A52 / A52s / A53 / A71 / A72 / A73, M52, S20 FE, S21 / S21+ / S21 FE / S21 Ultra, S22 / S22+ / S22 Ultra
- SM7150 forks add M51 (Galaxy M51)
- m51 builds exist and are verified: #5, #7 and #8 all built green on
  GitHub Actions (latest #8, run 45491802857, UN1CA 5.4.0, 10.9 GB).
  None is flashed or tested on a real M51 yet, and all are signed with
  throwaway test keys — no release builds are published yet. A rebuild
  with the blur-flag fix is next.

## Guides, downloads & flashing

Everything below is where it lives — this README points at it, the
complete steps live in the guides.

> **Universal does not mean the same for every phone.** This porter is
> universal — one system that builds for many Samsung phones — but
> every device gets its own build, its own firmware, its own TWRP, its
> own kernel and its own guide. Nothing here is one-size-fits-all: a
> file or a step for the M51 is for the M51 only. At each place below,
> the link for your device is right next to the item it belongs to —
> follow the link for your device, not another device's file. New
> devices get their own folder and their own links the same way.

### Guides in this repo

- [docs/FLASHING-GUIDE.md](docs/FLASHING-GUIDE.md) — how to flash:
  TWRP, the stock ROM, a UN1CA zip, and a custom kernel. Includes the
  TWRP rule (nothing we build overwrites recovery) and the EFS backup
  step. Read this before flashing anything.
- [docs/BUILD-GUIDE.md](docs/BUILD-GUIDE.md) — how to build a ROM with
  this porter (workflow inputs, the fix pack, the §10.1 artifact check).
- [docs/FIRMWARE.md](docs/FIRMWARE.md) — which stock firmware each
  build uses, how it is downloaded and verified, and where it is stored.

### Complete per-device procedures (m51)

The full step-by-step for the Galaxy M51 lives in the sister repo
[kkisdevil/m51-hyperos](https://github.com/kkisdevil/m51-hyperos).
Each procedure is its own file, with its own prerequisites, steps,
checks and troubleshooting — open the one for your job:

- [Device card (m51 facts)](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/devices/m51/README.md)
- [Unlock the bootloader](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/devices/m51/unlock-bootloader.md)
- [Flash TWRP](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/devices/m51/flash-twrp.md)
- [Root (Magisk)](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/devices/m51/root.md)
- [Flash the stock ROM](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/devices/m51/flash-stock.md)
- [Flash the HyperOS GSI](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/devices/m51/flash-gsi.md)
- [Flash UN1CA](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/devices/m51/flash-un1ca.md)
- [Flash a custom kernel](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/devices/m51/flash-kernel.md)

The same procedures are also on one complete page in that repo's
[README](https://github.com/kkisdevil/m51-hyperos#readme) (unlock,
TWRP, root, stock ROM, GSI, UN1CA, kernel, logging), and the m51
build itself is defined in this repo's
[devices/m51.json](devices/m51.json).

### Downloads

- **UN1CA ROM for m51** — GitHub Actions artifacts, not releases:
  [build workflow runs](https://github.com/kkisdevil/un1ca-universal/actions/workflows/build.yml).
  Latest good build is #8 (run 45491802857, UN1CA 5.4.0, 10.9 GB,
  decrypted, signed with throwaway test keys — never a release build).
  Artifacts expire 7 days after the run, so download soon; a rebuild
  with the blur-flag fix is next.
- **Stock firmware for m51 (M515FXXU6DXJ1, INS)** — Google Drive
  [`backups/m51-hyperos/firmware/`](https://drive.google.com/drive/folders/1p-6znbYCrBtKXbkYzo01nQfsHO9O3WUy),
  6 parts + hashes + rejoin command (see `docs/FIRMWARE.md`).
- **HyperOS GSI (MysticGSI spring, HyperOS 2 / Android 15)** — Google
  Drive [`backups/m51-hyperos/gsi/`](https://drive.google.com/drive/folders/1Lki6WecamHlTwQpXPMkM1WvmhGk7fMNu),
  3 parts + hashes (see the m51-hyperos repo).
- **Odin** — not in this repo (Samsung does not officially distribute
  it). Use v3.14.1; its SHA-256 is in `docs/FLASHING-GUIDE.md`.
- **TWRP for m51** — version 3.7.0_11-0; the flash steps and the
  source thread are in the m51 procedures above.

### How to flash (short version — the complete steps are in the guides)

1. [Unlock the bootloader](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/devices/m51/unlock-bootloader.md)
   (wipes the phone — back up first).
2. [Flash TWRP with Odin](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/devices/m51/flash-twrp.md),
   then boot straight into recovery.
3. Back up EFS in TWRP before touching anything else (see the TWRP
   guide above).
4. [Flash the UN1CA zip in TWRP](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/devices/m51/flash-un1ca.md).
   Recovery is never overwritten.
5. If anything goes wrong, [flash the stock firmware](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/devices/m51/flash-stock.md)
   from the Drive folder above (BL/CP/CSC only keeps TWRP; full AP
   replaces it).

Do not skip the guides: the short version above leaves out the
checks that keep a flash safe.

## Rules for this project

- **GitHub-only:** build runners, workflow testing and direct GitHub access only. No private servers.
- **Open source:** GPL-3.0, matching UN1CA upstream. See `LICENSE`.
- **Credits always:** everyone whose repo, tool, guide or info is used is credited in `CREDITS.md` and in the README. If you contributed and are missing, open an issue.
- **Safety:** flashing a custom ROM can brick a device, trip Knox, and void warranty. Locked-bootloader models (notably some US Snapdragon models) cannot flash at all. Test only on a device you can afford to recover.

## Universal porter — how the setup works

The porter is the centre of this repo. It is a manifest + resolver, not a
hard-coded device list:

- `devices/<codename>.json` — one manifest per device (m51 first), copied
  verbatim from the real upstream `target/<codename>/` files.
- `devices/soc-families.json` — SoC family → primary upstream fork/branch.
  sm7150 is mapped (a71, m51 → Arnav `seventeen`, Mehedi `sixteen` as the
  alternative); sm7125, sm7325, sm8450, exynos2100, s5e8825, sm8250 are
  listed with their codenames verified from the upstream `target/` table.
- `scripts/resolve-device.py` — given a device, resolves it to
  (SoC family, upstream repo, branch, UN1CA version). The build workflow's
  `resolve` job runs it and the build checks out exactly that repo@branch.
  Inputs default to `auto` (use the manifest); override them for one run.
- `devices/_template.json` — copy it to add a device; fill every field
  from the real upstream files, never from memory.

Workflows: `.github/workflows/build.yml` (workflow_dispatch, dry-run
default / full build, logs uploaded as artifacts, re-runnable) and
`.github/workflows/validate.yml` (push/PR: shellcheck, YAML parse, device
JSON validation, SoC-manifest + resolver check, upstream existence).

## How a port works (high level)

1. Detect codename + SoC from the target device
2. Download the matching stock Samsung firmware
3. Use the UN1CA build system to extract firmware components, apply patches, and generate a flashable zip
4. Inject device-specific vendor blobs, kernel and CSC
5. Test: boot, calls, mobile data, Wi-Fi, Bluetooth, camera, fingerprint, and sensors — per device, with a named tester

## Contributing

- Pick one SoC family, not one random phone
- Bring a test device for the model you port
- Keep changes general and account-agnostic — no owner-only workarounds
- Credit every upstream source you use

## Credits

Full credits are in [CREDITS.md](CREDITS.md). In short:

- UN1CA itself: [salvogiangri/UN1CA](https://github.com/salvogiangri/UN1CA)
- SM7150 forks: [mehedihjoy0/UN1CA-SM7150](https://github.com/mehedihjoy0/UN1CA-SM7150) and [Arnav3078/UN1CA-SM7150](https://github.com/Arnav3078/UN1CA-SM7150)
- UN1CA Carbon (S23-focused distribution): [alrigroup/un1ca-carbon](https://github.com/alrigroup/un1ca-carbon)
- UN1CA's own credits, tools and inspirations are listed in CREDITS.md

## License

GNU General Public License v3.0. See `LICENSE`.

## Disclaimer

This project is not affiliated with Samsung, UN1CA, or any of the upstream projects listed in CREDITS.md. Samsung, Galaxy, One UI and related marks belong to their owners.
