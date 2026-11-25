# Galaxy S21+ 5G (t2s)

Device card for the Galaxy S21+ 5G in the UN1CA Universal porter.

| Fact | Value |
|---|---|
| Codename | `t2s` |
| Model | `SM-G996B` |
| Marketing name | Galaxy S21+ 5G |
| SoC family | `exynos2100` (Exynos 2100) |
| Primary upstream | `salvogiangri/UN1CA` branch `sixteen`, UN1CA 3.2.1 |
| UN1CA base | 3.2.1 |
| Guide status | **Partially filled 2026-11-25**  -  the 7 procedure files are written from this device's own sources where verified; items that could not be verified stay marked TODO in each file. Biggest open items: the exact latest TWRP tar and hash, the vbmeta conflict on current firmware, the AUT HZC2 firmware package, which recovery the UN1CA installer accepts (afaneh92's TWRP is rejected with E3000), the first t2s UN1CA build, any HyperOS GSI boot on t2s, and any custom kernel for t2s (none exists yet). |

## Facts source

Family, upstream repo/branch and UN1CA version come from
[`../soc-families.json`](../soc-families.json) (checked 2026-11-23 from
the upstream `target/` table). Model and SoC are the standard public
spec for this device  -  verify them against the device's own
`target/t2s/config.sh` in the upstream repo before building.

## Guides in this folder

- [Unlock the bootloader](unlock-bootloader.md)
- [Flash TWRP](flash-twrp.md)
- [Root](root.md)
- [Flash the stock ROM](flash-stock.md)
- [Flash the HyperOS GSI](flash-gsi.md)
- [Flash UN1CA](flash-un1ca.md)
- [Flash a custom kernel](flash-kernel.md)

Each file is standalone: prerequisites, steps, checks, troubleshooting.
Do not copy the m51 values  -  every device fact differs.
