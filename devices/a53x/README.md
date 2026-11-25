# Galaxy A53 5G (a53x)

Device card for the Galaxy A53 5G in the UN1CA Universal porter.

| Fact | Value |
|---|---|
| Codename | `a53x` |
| Model | `SM-A536B` |
| Marketing name | Galaxy A53 5G |
| SoC family | `s5e8825` (Exynos 1280) |
| Primary upstream | `salvogiangri/UN1CA` branch `sixteen`, UN1CA 3.2.1 |
| UN1CA base | 3.2.1 |
| Guide status | **Researched 2026-11-25**. All 7 procedure files are filled from this device's own sources (upstream `target/a53x/`, official TWRP, XDA, SamFrew/SamDB). Still TODO: Odin SHA-256; GZI3 EUX firmware CSC/modem/build number/file/hashes; TWRP image verification; UN1CA first build (no `devices/a53x.json`, no run yet) and its fix pack; a53x kernel build (no gates, no boot test); HyperOS DSU trial not started. See the TODO lines in each file. |

## Facts source

Family, upstream repo/branch and UN1CA version come from
[`../soc-families.json`](../soc-families.json) (checked 2026-11-23 from
the upstream `target/` table). Model and SoC are the standard public
spec for this device. Verify them against the device's own
`target/a53x/config.sh` in the upstream repo before building.

## Guides in this folder

- [Unlock the bootloader](unlock-bootloader.md)
- [Flash TWRP](flash-twrp.md)
- [Root](root.md)
- [Flash the stock ROM](flash-stock.md)
- [Flash the HyperOS GSI](flash-gsi.md)
- [Flash UN1CA](flash-un1ca.md)
- [Flash a custom kernel](flash-kernel.md)

Each file is standalone: prerequisites, steps, checks, troubleshooting.
Do not copy the m51 values. Every device fact differs.
