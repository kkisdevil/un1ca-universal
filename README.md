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
- This repo is the starting point. No device builds are published yet.

## Rules for this project

- **GitHub-only:** build runners, workflow testing and direct GitHub access only. No private servers.
- **Open source:** GPL-3.0, matching UN1CA upstream. See `LICENSE`.
- **Credits always:** everyone whose repo, tool, guide or info is used is credited in `CREDITS.md` and in the README. If you contributed and are missing, open an issue.
- **Safety:** flashing a custom ROM can brick a device, trip Knox, and void warranty. Locked-bootloader models (notably some US Snapdragon models) cannot flash at all. Test only on a device you can afford to recover.

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
