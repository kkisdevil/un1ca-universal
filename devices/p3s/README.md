# Galaxy S21 Ultra 5G (p3s)

Device card for the Galaxy S21 Ultra 5G in the UN1CA Universal porter.

| Fact | Value |
|---|---|
| Codename | `p3s` |
| Model | `SM-G998B` |
| Marketing name | Galaxy S21 Ultra 5G |
| SoC family | `exynos2100` (Exynos 2100) |
| Primary upstream | `salvogiangri/UN1CA` branch `sixteen`, UN1CA 3.2.1 |
| UN1CA base | 3.2.1 |
| Guide status | **Researched 2026-11-25** - all 7 procedure files are filled from this device's own sources. Remaining TODOs are listed at the end of each file: the biggest are which recovery UN1CA 3.2.1 wants (afaneh92's TWRP is refused with E3000), the stock firmware MD5 and SHA-256, the p3s fastbootd partition layout for the GSI full flash, and the fact that no porter build and no custom kernel build exist for p3s yet. |

## Facts source

Family, upstream repo/branch and UN1CA version come from
[`../soc-families.json`](../soc-families.json) (checked 2026-11-23 from
the upstream `target/` table). Model, marketing name and SoC are
verified against the device's own `target/p3s/config.sh` in the
upstream repo, read live 2026-11-25: `TARGET_NAME="Galaxy S21
Ultra 5G (Exynos)"`, `TARGET_CODENAME="p3s"`,
`TARGET_PLATFORM="exynos2100"`,
`TARGET_FIRMWARE="SM-G998B/AUT/350635581234563"`. An earlier
version of this README said Galaxy S21+ / SM-G996B. That was
wrong: SM-G996B is the S21+ (codename t2s), not p3s. It is fixed
here.

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
