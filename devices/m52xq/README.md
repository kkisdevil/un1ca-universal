# Galaxy M52 5G (m52xq)

Device card for the Galaxy M52 5G in the UN1CA Universal porter.

| Fact | Value |
|---|---|
| Codename | `m52xq` |
| Model | `SM-M526B` |
| Marketing name | Galaxy M52 5G |
| SoC family | `sm7325` (Snapdragon 778G) |
| Primary upstream | `salvogiangri/UN1CA` branch `sixteen`, UN1CA 3.2.1 |
| UN1CA base | 3.2.1 |
| Guide status | **Researched 2026-11-25.** All 7 procedure files are filled from this device's own sources (upstream `target/m52xq`, XDA TWRP/kernel threads, samfw firmware records). Remaining TODOs are listed in each file: mainly the exact Odin version and SHA-256, the vbmeta slot confirmation against the XDA thread's first post, the fingerprint sensor position coordinates, the UN1CA 3.2.1 zip behaviour (BL/modem flash, fingerprint/dalvik wipe, recovery handling), the exact stock build-number strings, and any on-device verification (nothing in this folder has been run on a real m52xq yet). |

## Facts source

Family, upstream repo/branch and UN1CA version come from
[`../soc-families.json`](../soc-families.json) (checked 2026-11-23 from
the upstream `target/` table). Model and SoC are the standard public
spec for this device - verify them against the device's own
`target/m52xq/config.sh` in the upstream repo before building.

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
