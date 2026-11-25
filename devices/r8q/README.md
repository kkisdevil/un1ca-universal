# Galaxy S20 FE (Snapdragon) (r8q)

Device card for the Galaxy S20 FE (Snapdragon) in the UN1CA Universal porter.

| Fact | Value |
|---|---|
| Codename | `r8q` |
| Model | `SM-G780G` |
| Marketing name | Galaxy S20 FE (Snapdragon) |
| SoC family | `sm8250` (Snapdragon 865) |
| Primary upstream | `salvogiangri/UN1CA` branch `sixteen`, UN1CA 3.2.1 |
| UN1CA base | 3.2.1 |
| Guide status | **Researched 2026-11-25**: all 7 procedure files are filled from this device's own sources (see each file's Sources note). Still TODO: Odin SHA-256; BTU firmware package filename, size, MD5 and SHA-256 (no BTU package downloaded yet); TWRP tar hash verification; whether the UN1CA zip flashes BL/modem, wipes fingerprints, or touches recovery; APatch/KernelSU verification; a first porter build for r8q (none exists yet); the kernel defconfig/toolchain; the first HyperOS DSU trial and the first UN1CA/kernel boot tests on an r8q. |

## Researched facts (2026-11-25)

- Stock firmware (latest, BTU): PDA `G780GXXSHEYJ1`, CSC
  `G780GOXMHEYJ1`, modem `G780GXXSHEYJ1`, Android 13 / One UI 5.1,
  patch 2025-10-01, built 2025-09-30, changelist 27100863,
  bootloader binary H (17).
- TWRP: official, maintainer ata-kaner, version 3.7.1_12-2,
  Android 12.1 base; decryption support removed; no multidisabler.
- UN1CA: branch `sixteen`, 3.2.1, Android 16 / One UI 8.0, Galaxy
  S22 base; minimum bootloader G780GXXU3DVK5 (Android 13).
- Kernel: UN1CA sm8250, Linux 4.19.325-cip136-st20-perf, latest
  release UN1CA-r8q-20261007-164834.
- Partitions: boot 64 MB, DTBO 10 MB, super 10,292,822,016 B
  (dynamic, `qti_dynamic_partitions`); 120 Hz display, in-display
  optical fingerprint, Snapdragon 865 (sm8250).

## Facts source

Family, upstream repo/branch and UN1CA version come from
[`../soc-families.json`](../soc-families.json) (checked 2026-11-23 from
the upstream `target/` table). Model and SoC are the standard public
spec for this device. Verify them against the device's own
`target/r8q/config.sh` in the upstream repo before building.

## Guides in this folder

- [Unlock the bootloader](unlock-bootloader.md)
- [Flash TWRP](flash-twrp.md)
- [Root](root.md)
- [Flash the stock ROM](flash-stock.md)
- [Flash the HyperOS GSI](flash-gsi.md)
- [Flash UN1CA](flash-un1ca.md)
- [Flash a custom kernel](flash-kernel.md)

Each file is standalone: prerequisites, steps, checks, troubleshooting.
Do not copy the m51 values: every device fact differs.
