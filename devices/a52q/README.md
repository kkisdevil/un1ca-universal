# Galaxy A52 (a52q)

Device card for the Galaxy A52 in the UN1CA Universal porter.

| Fact | Value |
|---|---|
| Codename | `a52q` |
| Model | `SM-A525F` |
| Marketing name | Galaxy A52 |
| SoC family | `sm7125` (Snapdragon 720G) |
| Primary upstream | `salvogiangri/UN1CA` branch `sixteen`, UN1CA 3.2.1 |
| UN1CA base | 3.2.1 |
| Guide status | **Researched 2026-11-25**: all 7 procedure files are filled from this device's own sources (upstream `target/a52q/`, official TWRP, XDA threads, samfw/SamMobile firmware records). Remaining TODOs, all marked in the files: vbmeta filename/link and multidisabler question (flash-twrp.md); Magisk boot-key behaviour and Method B end-to-end run (root.md); FYF1 build number, changelist, One UI version, SHA-256, server filename (flash-stock.md); DSU trial not started and super-partition size discrepancy (flash-gsi.md); porter UN1CA build does not exist yet, donor firmware and zip behaviour unverified (flash-un1ca.md); no kernel build exists yet (flash-kernel.md). |

## Facts source

Family, upstream repo/branch and UN1CA version come from
[`../soc-families.json`](../soc-families.json) (checked 2026-11-23 from
the upstream `target/` table). Model and SoC are the standard public
spec for this device. Verify them against the device's own
`target/a52q/config.sh` in the upstream repo before building.

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
