# Credits

Everyone whose repo, tool, guide or info this project uses. If you contributed and are missing, please open an issue — this file is meant to grow, not to be complete on day one.

## UN1CA — the base project

- **salvogiangri / UN1CA** — https://github.com/salvogiangri/UN1CA
  Work-in-progress custom firmware for Samsung Galaxy devices. GPL-3.0.
  The build system downloads and extracts firmware components, applies patches, and generates a flashable zip.

## SM7150 forks

- **mehedihjoy0 / UN1CA-SM7150** — https://github.com/mehedihjoy0/UN1CA-SM7150
  Fork of UN1CA on branch `sixteen`, SM7150 (Snapdragon 732G / 730G family) adaptation. Adds the `m51` target (Galaxy M51).
- **Arnav3078 / UN1CA-SM7150** — https://github.com/Arnav3078/UN1CA-SM7150
  Fork of UN1CA on branch `seventeen`, described as "UN1CA 5.x One UI 9 And One UI 9.5 For M51". Also carries the `m51` target.

## UN1CA Carbon — S23-focused distribution

- **alrigroup / un1ca-carbon** — https://github.com/alrigroup/un1ca-carbon
  "Next-Generation One UI Custom ROM" for Galaxy S23 Base (dm1q, SM-S911B / SM-S9110), One UI 9.0 / Android 17.
  Organisation & maintainer: ALRI Development. Lead maintainer: Alexsander "AlexsAR" ALRI (@alexsanderalri).
  UN1CA Core Architecture credit in Carbon: Salvo Giangri (@salvogiangri).
  Carbon also credits: GoRhanHee (custom kernel, Linux 5.15.220, KernelSU-Next + SUSFS), rifsxd / KernelSU-Next contributors (based on KernelSU by tiann), Team Win Recovery Project (TWRP) and Galaxy S23 maintainers (@archer9634), @Rezoss-Reza (One UI 9 Framework Engine), @cosinemyan / NPL ROM Team (visuals & wallpapers).

## People credited by UN1CA itself

From the UN1CA README (salvogiangri/UN1CA):

- **ShaDisNX255** — for his help, time, and for his NcX ROM which inspired UN1CA
- **DavidArsene** — help and time
- **paulowesll** — help and support
- **Simon1511** — support and device-specific patches
- **ananjaser1211** — troubleshooting and time
- **Fede2782** — contributions and help with Exynos / MTK support
- **iDrinkCoffee** and **RisenID** — support
- **LineageOS Team** — original OTA updater implementation
- All UN1CA project forks, contributors, testers and users

## Tools and libraries used by UN1CA

From the UN1CA README licensing section:

- **android-tools** — Apache License 2.0
- **apktool** — Apache License 2.0
- **erofs-utils** — dual license GPL-2.0 / Apache-2.0
- **img2sdat** — MIT License
- **platform_build** (ext4_utils, f2fs_utils, signapk, from android.googlesource.com) — Apache License 2.0

UN1CA also integrates, per its README: BluetoothLibraryPatcher, KnoxPatch, TrickyStore (key attestation spoof), Play Integrity Fix, and Hide My Applist. Their own authors and licences apply.

## Guides and info

- UN1CA Supported Devices discussions: https://github.com/salvogiangri/UN1CA/discussions/categories/supported-devices
- UN1CA releases and changelogs: https://github.com/salvogiangri/UN1CA/releases
- Community guides and device threads on XDA Forums for UN1CA ports (search "UN1CA" + codename). Individual thread authors are credited in those threads; if this project draws on a specific guide, its author will be added here by name and link.

## This project

- **YuZora / Kartik Deepak Sormare (kkisdevil)** — project owner, universal-porter goal.
- This repo is GPL-3.0, matching UN1CA upstream.
