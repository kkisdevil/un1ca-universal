# Galaxy A71 (a71)

Device card for the Galaxy A71 in the UN1CA Universal porter.

| Fact | Value |
|---|---|
| Codename | `a71` |
| Model | `SM-A715F` |
| Marketing name | Galaxy A71 |
| SoC family | `sm7150` (Snapdragon 730) |
| Primary upstream | `Arnav3078/UN1CA-SM7150` branch `seventeen`, UN1CA 5.4.0 |
| UN1CA base | 5.4.0 |
| Guide status | **Researched 2026-11-25**  -  all 7 procedure files are filled from this device's own sources. Remaining TODOs are listed in each file. Biggest open item: the UN1CA installer refuses afaneh92's TWRP, which is the only TWRP found for this phone (see [flash-un1ca.md](flash-un1ca.md)). No a71 build has been run, flashed, or tested by us. |
| Target firmware | `SM-A715F/ROM/352641111234568` (UN1CA target) |
| Latest stock firmware | `A715FXXSBDXB1`, Android 13 / One UI 5.1, patch 2024-02-01, changelist 27100863, bootloader 11 |
| UN1CA target | SDK 33, shipping API 29, board API 30; boot 64 MB, DTBO 10 MB, super 8,053,063,680 B |
| Fingerprint | In-display optical (udfps_optical), sensor at 540\|2105\|90, max 4 enrolments |
| Kernel | Paradigm kernel in UN1CA (boot.img 49,889,280 B); our own build would use the crDroid sm7150 tree (4.14.357-openela) with `a71_defconfig` |
| TWRP | Unofficial, by afaneh92 (latest named build `twrp-3.7.0_11-1_afaneh92-a71`); no official TWRP |

## Facts source

Family, upstream repo/branch and UN1CA version come from
[`../soc-families.json`](../soc-families.json) (checked 2026-11-23 from
the upstream `target/` table). Model and SoC are the standard public
spec for this device, confirmed against the device's own
`target/a71/config.sh` in the upstream repo (Arnav `seventeen`,
identical in Mehedi `sixteen`; full read 2026-11-25). Target
firmware, SDK, partitions, DVFS names, fingerprint sensor, and the
patch list are from that same file and from `target/a71/installer/`
and `target/a71/patches/` (directory listings, 2026-11-25). Latest
stock firmware (A715FXXSBDXB1) is from the Samfw and SamMobile
listings (2026-11-25); the firmware zip has not been downloaded or
verified by us. Fingerprint sensor position is from the a71-devs
device trees (lineage-22.2). TWRP is from the afaneh92 XDA thread.
Kernel facts are from the UN1CA kernel release API and the
a71-devs BoardConfig files.

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
