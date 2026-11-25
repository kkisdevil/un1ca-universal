# Galaxy A73 5G (a73xq)

Device card for the Galaxy A73 5G in the UN1CA Universal porter.

| Fact | Value |
|---|---|
| Codename | `a73xq` |
| Model | `SM-A736B` |
| Marketing name | Galaxy A73 5G |
| SoC family | `sm7325` (Snapdragon 778G) |
| Primary upstream | `salvogiangri/UN1CA` branch `sixteen`, UN1CA 3.2.1 |
| UN1CA base | 3.2.1 |
| Guide status | **Researched 2026-11-25** - all 7 procedure files are filled from this device's own sources (upstream `target/a73xq/config.sh` and `sff.sh`, the XDA TWRP 3.7.0-12 thread, and the SamFrew XME CGZK3 firmware record). Honest limits remain: no UN1CA build, no HyperOS boot, and no custom kernel exist for this phone in this project yet; TWRP 3.7.0-12 is a 2023 unofficial build untested on current Android 16 firmware; and the items listed under TODO in each guide (full `patches/` listing, CGZK3 MD5/SHA-256, Odin SHA-256, vbmeta Odin slot, boot partition size) are still open. |

## Facts source

Family, upstream repo/branch and UN1CA version come from
[`../soc-families.json`](../soc-families.json) (checked 2026-11-23 from
the upstream `target/` table). Model and SoC are the standard public
spec for this device - verify them against the device's own
`target/a73xq/config.sh` in the upstream repo before building.

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
