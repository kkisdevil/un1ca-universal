# Galaxy A72 (a72q)

Device card for the Galaxy A72 in the UN1CA Universal porter.

| Fact | Value |
|---|---|
| Codename | `a72q` |
| Model | `SM-A725F` |
| Marketing name | Galaxy A72 |
| SoC family | `sm7125` (Snapdragon 720G) |
| Primary upstream | `salvogiangri/UN1CA` branch `sixteen`, UN1CA 3.2.1 |
| UN1CA base | 3.2.1 |
| Guide status | **Researched 2026-11-25** - all 7 procedure files are filled from this device's own sources. Nothing has been flashed or tested on a live A72 yet: unlock, TWRP, root, stock flash, GSI, UN1CA and kernel are all procedures to run, not reports of working installs. Open TODOs are marked in each file. |

## Facts source

Family, upstream repo/branch and UN1CA version come from
[`../soc-families.json`](../soc-families.json) (checked 2026-11-23 from
the upstream `target/` table). Model and SoC are confirmed against
the device's own `target/a72q/config.sh` in the upstream repo
(lines 5 to 8: Galaxy A72, a72q, sm7125, SM-A725F/BTU).

## Verified device facts (2026-11-25)

| Fact | Value |
|---|---|
| Display | 90 Hz default, 60/90 Hz supported (`config.sh` lines 34 to 36) |
| Fingerprint | In-display optical, `google_touch_display_optical,settings=3` (`config.sh` line 31). NOT side-mounted. |
| Stock firmware (latest, BTU) | PDA `A725FXXSBFYC1`, CSC `A725FOXMBFYC1`, Android 14 / One UI 6.1, patch 2025-03-01, bootloader B (11) |
| Stock kernel | Linux 4.14.190-perf (`4.14.190-perf-28694960-abA725FXXSBFYC1`) |
| Recovery | Official TWRP 3.7.1_12-0-a72q (2024-02-18, 43.6 MB) |
| UN1CA | Upstream 3.2.1 (2026-09-29), MD5 `13914f15f057d1ff4c941a91832eaedf` |
| Super partition | 10,292,822,016 B (`config.sh` line 13) |
| SIM | Single SIM tray (`config.sh` line 39) |

## What remains TODO

- No live A72 work yet: no unlock, TWRP flash, root run, stock
  flash, DSU trial, UN1CA flash, or kernel build has been done in
  front of us. Every guide says so where it matters.
- Stock firmware zip not downloaded or hashed by us (SamMobile
  and Samfw publish conflicting MD5s for the BTU zip; build date
  is 2025-03-05 per SamFrew vs 2025-03-10 per SamMobile).
- Boot partition size unknown (not in `config.sh`).
- No porter UN1CA build for a72q yet; only the upstream 3.2.1
  release is recorded. No a72q fix pack, no custom kernel build.
- GSI super-layout fit and the a72q Permissiver step are
  unverified.


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
