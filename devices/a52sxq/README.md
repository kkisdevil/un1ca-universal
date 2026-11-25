# Galaxy A52s 5G (a52sxq)

Device card for the Galaxy A52s 5G in the UN1CA Universal porter.

| Fact | Value |
|---|---|
| Codename | `a52sxq` |
| Model | `SM-A528B` |
| Marketing name | Galaxy A52s 5G |
| SoC family | `sm7325` (Snapdragon 778G) |
| Primary upstream | `salvogiangri/UN1CA` branch `sixteen`, UN1CA 3.2.1 |
| UN1CA base | 3.2.1 |
| Guide status | **Filled 2026-11-25** - all 7 procedure files are filled from this device's own sources (upstream `target/a52sxq/config.sh`, official TWRP, XDA threads, SamFrew/samfirm firmware records). Remaining TODOs are marked in each file: the main ones are the BTU GYI3 firmware file hashes, the vbmeta Odin slot, the exact UN1CA 3.2.1 zip and hashes, the `assertions.edify` contents, the A52s super layout, and any on-device test (no UN1CA build, kernel build, or GSI boot has been done by us for this device yet). |

## Facts source

Family, upstream repo/branch and UN1CA version come from
[`../soc-families.json`](../soc-families.json) (checked 2026-11-23 from
the upstream `target/` table). Model and SoC are the standard public
spec for this device - verify them against the device's own
`target/a52sxq/config.sh` in the upstream repo before building.

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
