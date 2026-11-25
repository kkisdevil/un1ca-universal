> Mirror of the verified m51 guides. Canonical home is the [m51-hyperos repo](https://github.com/kkisdevil/m51-hyperos) (`docs/devices/m51/`); if the two copies disagree, that copy wins.

# Galaxy M51 - SM-M515F

Device card for the m51. Every procedure in this folder is written
for this phone only. Do not use these files on any other model.

## Facts

| Fact | Value |
|---|---|
| Model | **SM-M515F** (Galaxy M51, international) |
| Codename | m51 |
| SoC | Qualcomm Snapdragon 730G (**SM7150**, `sm6150` platform) |
| RAM / storage | 6 GB / 128 GB |
| Battery | 7,000 mAh |
| Display | 6.7" Super AMOLED Plus, **60 Hz** (the panel reports only 60 Hz modes) |
| Fingerprint | Side-mounted, at `1080\|800\|350` |
| Stock OS | Android 12 / One UI 4.1, build `SP1A.210812.016.M515FXXU6DXJ1`, patch 2024-05-01 |
| Stock firmware (latest, INS) | PDA `M515FXXU6DXJ1`, CSC `M515FODM6DXJ1`, modem `M515FXXU6DXJ1`, bootloader **6** |
| Kernel | Linux 4.14 (stock; our custom build is 4.14.357-openela) |
| Vendor | Frozen at Android 12, VNDK 31, FCM target-level 6, 913 proprietary blobs |
| Partitions | Dynamic partitions (super: system, vendor, product, system_ext, odm) |
| Recovery | Unofficial TWRP 3.7.0_11-0 (verified) |
| Bootloader | Unlocked on our phone. Knox tripped permanently, Widevine L3. |

## Procedures

Do them in this order the first time: unlock, TWRP, then root,
stock, GSI, UN1CA, or kernel as needed.

| Step | File |
|---|---|
| 1. Unlock the bootloader (once) | [unlock-bootloader.md](unlock-bootloader.md) |
| 2. Flash TWRP | [flash-twrp.md](flash-twrp.md) |
| 3. Root with Magisk (or APatch) | [root.md](root.md) |
| 4. Flash the stock ROM | [flash-stock.md](flash-stock.md) |
| 5. Flash HyperOS (GSI) | [flash-gsi.md](flash-gsi.md) |
| 6. Flash UN1CA | [flash-un1ca.md](flash-un1ca.md) |
| 7. Flash the custom kernel | [flash-kernel.md](flash-kernel.md) |

## The rules that apply to every procedure here

- **Back up first.** Unlocking wipes the phone. A stock flash with
  the CSC file wipes the phone. A GSI or UN1CA flash needs a Format
  Data. Assume a wipe. Back up EFS in TWRP before any flashing.
- **Never let anything overwrite the recovery partition.** Our
  phone runs TWRP. Check every tar you flash for a `recovery.img`
  entry first.
- **Never relock the bootloader** with TWRP, Magisk, or any custom
  image installed. Never write to the bootloader partitions
  (`aboot` / `xbl` / `sbl`) from root.
- **Check the phone first.** Settings, About phone, Software
  information: model must read **SM-M515F** and the service
  provider software version must show **INS**.

## Status (honest)

| Track | Status |
|---|---|
| HyperOS GSI | Spring GSI verified and mirrored; DSU trial not started |
| UN1CA ROM | Build #8 green; not flashed or tested |
| Custom kernel | Build #8 green (7/7 gates); boot test owed |
| Lights HAL | Forked, no-op light committed; build run #27 in flight |
| Fingerprint | RE done: AIDL v4, two-prop fix; not tested on device |
| Stock firmware | DXJ1 INS downloaded, verified, on Drive |

Full status with evidence: the repo root
[README.md](https://github.com/kkisdevil/m51-hyperos#readme) §11. Deep guides for each
procedure: [../../install.md](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/install.md) (GSI),
[../../dsu-trial.md](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/dsu-trial.md) (DSU trial),
[../../FLASHING-GUIDE.md](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/FLASHING-GUIDE.md) (stock),
[../../FIRMWARE.md](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/FIRMWARE.md) (firmware record),
[../../LOGGING-GUIDE.md](https://github.com/kkisdevil/m51-hyperos/blob/main/docs/LOGGING-GUIDE.md) (logging).
