# Galaxy S22 (r0q)

Device card for the Galaxy S22 in the UN1CA Universal porter.

| Fact | Value |
|---|---|
| Codename | `r0q` |
| Model | `SM-S901E` (also SM-S901N, SM-S9010) |
| Marketing name | Galaxy S22 (Snapdragon) |
| SoC family | `sm8450` (Snapdragon 8 Gen 1) |
| Primary upstream | `salvogiangri/UN1CA` branch `sixteen`, UN1CA 3.2.1 |
| UN1CA base | 3.2.1 |
| Guide status | **Researched 2026-11-25** - all 7 procedure files are filled from this device's own sources. Remaining TODOs: TWRP image not downloaded/hashed/booted by us, no r0q porter manifest or build run yet, firmware file hashes for `S901EXXSEGZH4` (and TUR availability), GSI build choice and Permissiver not verified, no custom kernel build yet, DSU trial not started. |

## Correction (2026-11-25)

This card used to say Galaxy S22 Ultra, model SM-S908B. That was
wrong. The upstream `target/r0q/config.sh` names the target
"Galaxy S22 (Snapdragon)" with target firmware
`SM-S901E/TUR/350999641234561`. Codename `r0q` is the base
Galaxy S22 (Snapdragon); the S22 Ultra (SM-S908E) is codename
`b0q`, a different phone. (SM-S901B is the Exynos S22, codename
`r0s`, also a different phone.) Every guide in this folder is
written for the base Galaxy S22 (SM-S901E).

## Facts source

Family, upstream repo/branch and UN1CA version come from
[`../soc-families.json`](../soc-families.json) (checked 2026-11-23 from
the upstream `target/` table). Model and SoC are verified against
the device's own `target/r0q/config.sh` in the upstream repo
(read 2026-11-25): TARGET_NAME "Galaxy S22 (Snapdragon)",
TARGET_CODENAME "r0q", TARGET_PLATFORM "sm8450",
TARGET_FIRMWARE "SM-S901E/TUR/350999641234561",
TARGET_PLATFORM_SDK_VERSION 36, TARGET_SUPER_PARTITION_SIZE
12058624000.

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
