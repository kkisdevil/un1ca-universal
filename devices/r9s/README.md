# Galaxy S21 FE 5G (r9s)

Device card for the Galaxy S21 FE 5G (Exynos) in the UN1CA Universal porter.

| Fact | Value |
|---|---|
| Codename | `r9s` |
| Model | `SM-G990E` |
| Marketing name | Galaxy S21 FE 5G |
| SoC family | `exynos2100` (Exynos 2100) |
| Primary upstream | `salvogiangri/UN1CA` branch `sixteen`, UN1CA 3.2.1 |
| UN1CA base | 3.2.1 |
| Guide status | **Researched 2026-11-25** - the 7 procedure files in this folder are filled from this device's own sources. Some items are still marked TODO where no verifiable source was found (notably the exact TWRP file, the newest THL firmware hashes, and any our-repo UN1CA or kernel build, which do not exist yet). |

## Facts source

Model, SoC and upstream facts come from the upstream
`target/r9s/config.sh` in `salvogiangri/UN1CA` (branch `sixteen`,
UN1CA 3.2.1), read live 2026-11-25: `TARGET_FIRMWARE`
`SM-G990E/THL/355798871234563`, SDK 36, super partition
11,429,478,400 B, optical under-display fingerprint, HFR default
120 (60/120 only), eSIM false, single-SIM tray count 1. The
previous version of this README said "Galaxy S21 Ultra,
SM-G998B": that was wrong. This is the Exynos S21 FE 5G,
SM-G990E, not the Snapdragon FE (SM-G990B) and not the S21 Ultra.

## Guides in this folder

- [Unlock the bootloader](unlock-bootloader.md)
- [Flash TWRP](flash-twrp.md)
- [Root](root.md)
- [Flash the stock ROM](flash-stock.md)
- [Flash the HyperOS GSI](flash-gsi.md)
- [Flash UN1CA](flash-un1ca.md)
- [Flash a custom kernel](flash-kernel.md)

Each file is standalone: prerequisites, steps, checks, troubleshooting.
Do not copy the m51 values - every device fact differs.
