# Galaxy S21 (o1s)

Device card for the Galaxy S21 in the UN1CA Universal porter.

| Fact | Value |
|---|---|
| Codename | `o1s` |
| Model | `SM-G991B` |
| Marketing name | Galaxy S21 |
| SoC family | `exynos2100` (Exynos 2100) |
| Primary upstream | `salvogiangri/UN1CA` branch `sixteen`, UN1CA 3.2.1 |
| UN1CA base | 3.2.1 |
| Guide status | **Filled 2026-11-25** - all 7 procedure files are written from this device's own sources (upstream `target/o1s/config.sh` and `assertions.edify`, afaneh92 XDA TWRP thread, SamFrew/SamFW firmware records). Items that could not be verified stay marked TODO inside each file: TWRP download hash, AUT firmware MD5/SHA-256, whether HZA6 satisfies the UN1CA HZC2 bootloader assertion, the non-afaneh92 recovery UN1CA accepts, the GSI super layout and DSU trial, and the kernel build (none exists yet). |

## Facts source

Family, upstream repo/branch and UN1CA version come from
[`../soc-families.json`](../soc-families.json) (checked 2026-11-23 from
the upstream `target/` table). Model and SoC are the standard public
spec for this device - verify them against the device's own
`target/o1s/config.sh` in the upstream repo before building.

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
