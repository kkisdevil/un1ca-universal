# Galaxy S22+ (g0q)

Device card for the Galaxy S22+ in the UN1CA Universal porter.

| Fact | Value |
|---|---|
| Codename | `g0q` |
| Model | `SM-S906E` |
| Marketing name | Galaxy S22+ |
| SoC family | `sm8450` (Snapdragon 8 Gen 1) |
| Primary upstream | `salvogiangri/UN1CA` branch `sixteen`, UN1CA 3.2.1 |
| UN1CA base | 3.2.1 |
| Guide status | **Researched 2026-11-25.** All 7 guides are filled from live sources (see the Sources note in each file). Every guide still carries TODO items: no working TWRP download exists for g0q, no UN1CA build and no custom kernel build have been produced, no HyperOS boot or DSU trial has run, and the TUR GZH4 firmware filename and hashes are unverified. **Model correction:** the card above said SM-S906B; upstream `target/g0q/config.sh` line 13 names the target firmware `SM-S906E`, and SM-S906B is the Exynos Galaxy S22+ (codename `g0s`), not g0q. The guides use SM-S906E. |

## Facts source

Family, upstream repo/branch and UN1CA version come from
[`../soc-families.json`](../soc-families.json) (checked 2026-11-23 from
the upstream `target/` table). Model verified 2026-11-25 against
the device's own `target/g0q/config.sh` in the upstream repo
(line 13: `TARGET_FIRMWARE="SM-S906E/TUR/..."`): the model is
SM-S906E, not SM-S906B. SM-S906B is the Exynos Galaxy S22+
(codename `g0s`). SoC sm8450 is confirmed by the same file
(line 11: `TARGET_PLATFORM="sm8450"`).

## Guides in this folder

- [Unlock the bootloader](unlock-bootloader.md)
- [Flash TWRP](flash-twrp.md)
- [Root](root.md)
- [Flash the stock ROM](flash-stock.md)
- [Flash the HyperOS GSI](flash-gsi.md)
- [Flash UN1CA](flash-un1ca.md)
- [Flash a custom kernel](flash-kernel.md)

Each file is standalone: prerequisites, steps, checks, troubleshooting.
Do not copy the m51 values: every device fact differs.
