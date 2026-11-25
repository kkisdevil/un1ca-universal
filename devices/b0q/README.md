# Galaxy S22 Ultra (b0q)

Device card for the Galaxy S22 Ultra in the UN1CA Universal porter.

| Fact | Value |
|---|---|
| Codename | `b0q` |
| Model | `SM-S908E` (also SM-S908N, SM-S9080) |
| Marketing name | Galaxy S22 Ultra (Snapdragon) |
| SoC family | `sm8450` (Snapdragon 8 Gen 1) |
| Primary upstream | `salvogiangri/UN1CA` branch `sixteen`, UN1CA 3.2.1 |
| UN1CA base | 3.2.1 |
| Guide status | **Researched 2026-11-25** - all 7 procedure files are filled from this device's own sources. Remaining TODOs: TWRP version/date/hash (dl.twrp.me unreachable), Odin version/hash, firmware file hashes for `S908EXXSEGZH4`, no UN1CA build run yet, no custom kernel build yet, DSU trial not started. |

## Correction (2026-11-25)

This card used to say Galaxy S22, model SM-S901B. That was
wrong. The upstream `target/b0q/config.sh` names the target
"Galaxy S22 Ultra (Snapdragon)" with donor firmware
`SM-S908E/TUR`, and the b0q TWRP supports SM-S908E/S908N/S9080.
Codename `b0q` is the S22 Ultra; the base S22 (Snapdragon,
SM-S901E) is codename `r0q`, a different phone. (SM-S901B is the
Exynos S22, codename `r0s`.) Every guide in this folder is
written for the S22 Ultra.

## Facts source

Family, upstream repo/branch and UN1CA version come from
[`../soc-families.json`](../soc-families.json) (checked 2026-11-23 from
the upstream `target/` table). Model and SoC are verified against
the device's own `target/b0q/config.sh` in the upstream repo
(read 2026-11-25): TARGET_NAME "Galaxy S22 Ultra (Snapdragon)",
TARGET_CODENAME "b0q", TARGET_PLATFORM "sm8450",
TARGET_FIRMWARE "SM-S908E/TUR/...".

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
