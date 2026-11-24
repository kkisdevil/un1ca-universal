# M51 stock firmware — what we have and where it lives

Galaxy M51 (SM-M515F), India (INS). This file is the record for the
official stock firmware this project uses as its base: for the UN1CA
porter (source firmware) and for the HyperOS port (vendor/blob
reference and the known-good image to return to).

## The firmware

| Field | Value |
|---|---|
| Model | SM-M515F (Galaxy M51, codename `m51`) |
| Region / CSC | INS (India) — CSC `M515FODM6DXJ1` (ODM multi-CSC) |
| PDA / AP | `M515FXXU6DXJ1` |
| Modem / CP | `M515FXXU6DXJ1` |
| Full FUS version string | `M515FXXU6DXJ1/M515FODM6DXJ1/M515FXXU6DXJ1/M515FXXU6DXJ1` |
| Build number | `SP1A.210812.016.M515FXXU6DXJ1` |
| Android / One UI | Android 12 (API 31) / One UI 4.1 |
| Security patch | 2024-05-01 |
| Changelist | 23974102 |
| Build date | 2024-10-03 (uploaded 2024-10-15) |
| Bootloader | 6 — after flashing this, the phone will NOT accept firmware with bootloader 5 or lower (anti-rollback) |
| Kernel | `4.14.190-23974023-abM515FXXU6DXJ1` |
| Chipset | Qualcomm SM7150 (Snapdragon 730G) |
| Server file name | `SM-M515F_2_20241004032751_smm7rurrx5_fac.zip` |
| Size | ~7.1 GB (zip) |

## DXJ1 vs DXJ2 — resolved 2026-11-24

DXJ1 and DXJ2 are the **same build** (same date 2024-10-03, same
changelist 23974102, same 2024-05-01 patch). They differ only by CSC
group:

- **DXJ1** — the 36-region group, including **INS (India)**, BTU, XEF,
  NPB, BKD, PAK and the rest. This is the correct firmware for our
  phone.
- **DXJ2** — the 6-region Latin America group only: BVO, CHO, MXO,
  PEO, TPA, ZTO (Brazil, Chile, Mexico, Peru, Panama, Bolivia).

Any listing that calls DXJ2 "the latest M51 firmware" is giving the
global newest PDA string, not the build for INS. For INS, **DXJ1 is
the latest official firmware**, and no newer build has appeared for
this model since (updates have most likely ended).

## Why FUS checkupdate lies about this

Both `samloader` (Python) and `samloader-rs` `check-update` with no
IMEI report **DXE3** as the latest for INS. That is a stale track:
FUS keys "latest" off the device IMEI/TAC, and a no-IMEI query gets
an old answer. Verified live 2026-11-24: Python samloader and
samloader-rs 2.2.0 both return
`M515FXXS6DXE3/M515FODM6DXE3/M515FXXS6DXE1/M515FXXS6DXE3` for INS.
**Never trust a no-IMEI checkupdate.** The true latest was confirmed
against the SamFrew listings for INS (DXJ1 marked "Latest") and the
DXJ1 firmware page's identifiers.

## Download source and method

- Source: Samsung FUS (Firmware Update Server), direct from Samsung.
- Tool: **samloader-rs 2.2.0** (`topjohnwu/samloader-rs`, release
  2026-09-25, `samloader-v2.2.0-linux-x86_64.zip`, 3,384,967 B).
  No IMEI or serial needed (that requirement was removed in v2.0.0).
- Command used:
  `samloader download -m SM-M515F -r INS -v M515FXXU6DXJ1/M515FODM6DXJ1/M515FXXU6DXJ1 -d <out-dir>`
  (the `-v` value must be the PDA/CSC/MODEM triple — a bare PDA
  makes the tool panic with "Info request invalid").
- The Python `samloader` can NOT do this download: its `download`
  command refuses without an IMEI/serial. Its `checkupdate` is the
  only part that works without one, and it returns the stale DXE3.
- The download is resumable: samloader-rs writes a `.part` file and
  re-running the same command resumes it.

## Verification (done on the VM after download)

- Zip integrity: `unzip -t` — clean.
- Contents: the zip extracts to the 5 Odin files `BL`, `AP`, `CP`,
  `CSC`, `HOME_CSC` (all `.tar.md5`).
- Each `.tar.md5` verified with `samloader verify-md5` (Odin checks
  the same trailing MD5 before flashing).
- Hashes of the downloaded zip (computed on the VM, 2026-11-25 ~00:54 IST):

| File | Size (bytes) | MD5 | SHA-256 |
|---|---|---|---|
| `SM-M515F_2_20241004032751_smm7rurrx5_fac.zip` | 5,964,436,871 | `d3afc8d09f0bf94faaeccfd29517c9df` | `0e71ca19c9d2af6eb8b63e9882218792f855d90326893312bdfa4e1ff5ab50c5` |

Contents (verified with `unzip -l`): BL (59,770,992 B), AP
(6,628,669,567 B), CP (46,069,869 B), HOME_CSC (419,389,640 B),
CSC (419,410,115 B) — 5 files, 7,573,310,183 B extracted. That
extracted total is what SamFrew's "7.1 GB" label refers to; the zip
itself is 5.96 GB. Each `.tar.md5`'s trailing MD5 was checked with
`samloader verify-md5` on 2026-11-25 ~01:00 IST — **all 5 passed**
(BL, AP, CP, CSC, HOME_CSC); the zip's own CRCs are clean too
(`unzip` exit 0). Full record in `firmware.log`.

## Where the binary lives

The firmware (~7.1 GB) **cannot live in a GitHub repo** — GitHub
rejects any single file over 100 MB. It lives in two places:

1. **This VM:** `~/workspace/firmware/m51-latest/`
   (`SM-M515F_2_20241004032751_smm7rurrx5_fac.zip` plus
   `download.log` and the `samloader-rs` 2.2.0 tool under
   `~/workspace/firmware/tools/`).
2. **Google Drive (shareable home) — DONE, verified 2026-11-25
   ~01:50 IST:** `backups/m51-hyperos/firmware/` (folder id
   `1p-6znbYCrBtKXbkYzo01nQfsHO9O3WUy`). The Drive CLI cannot
   multipart-upload multi-GB files (a 3.1 GB upload failed twice
   with Google 500), so the zip went up in **6 verified 1 GiB
   parts** — every part checked on Drive by size + md5Checksum,
   and an independent folder listing confirms the total is exactly
   5,964,436,871 bytes:

   | Part | Size (bytes) | MD5 |
   |---|---|---|
   | `...fac.zip.part00` | 1,073,741,824 | `b4db01d89b9be36b07d80fe2e63a48dd` |
   | `...fac.zip.part01` | 1,073,741,824 | `65456155c88e2abff51c2fdcb112f734` |
   | `...fac.zip.part02` | 1,073,741,824 | `604c267d91753a145c3cec46e8f7b473` |
   | `...fac.zip.part03` | 1,073,741,824 | `f028eee3ef62649ab68e40025c322211` |
   | `...fac.zip.part04` | 1,073,741,824 | `928f902d8cfda5a24579797d1b125f70` |
   | `...fac.zip.part05` | 595,727,751 | `67a46ed347a940ae5288621e20f50998` |

   To get the firmware back: download all 6 parts into one folder
   and run `cat SM-M515F_2_20241004032751_smm7rurrx5_fac.zip.part?? > SM-M515F_2_20241004032751_smm7rurrx5_fac.zip`,
   then `sha256sum` it — expect
   `0e71ca19c9d2af6eb8b63e9882218792f855d90326893312bdfa4e1ff5ab50c5`.
   `firmware.log` sits in the same Drive folder. The `backups`
   folder is the Drive home our other backups use
   (`yuzora:backups/...`); 5 TB available. rclone v1.60.1 is
   installed on the VM, but the `yuzora:` remote itself lives on
   Oracle1 — recreating it here needs a one-time OAuth step, so
   the chunked CLI upload is the route that actually ran.

The repos (m51-hyperos, un1ca-universal) hold only this record and
the flashing guide — never the binary.

## What this firmware is for in this project

- **UN1CA porter:** DXJ1 is the stock firmware the m51 target is
  built from (the Arnav `seventeen` config targets
  `SM-M515F/BVO/357563172596302` — the same DXJ1-era base).
- **HyperOS port:** DXJ1 is the blob reference. The frozen vendor
  blobs in the a71-devs trees are DXE3-era; DXJ1 carries the same
  2024-05-01 patch and changelist 23974102, so the expected diff
  against the frozen 913 is small (see `docs/blob-refresh.md`).
- **Recovery:** this is the known-good image to return the phone to
  stock. Flashing it **replaces TWRP with the stock recovery** —
  see the flashing guide's TWRP section before doing it.

## Logger — every step of this flow is logged

The firmware flow (version check → download → verify → Drive
upload) runs through a structured logger, so any failure can be
replayed from the log alone instead of re-doing the whole flow.

- **Logger:** `scripts/firmware-logger.sh` (sourced by
  `scripts/fetch-firmware.sh`, the re-runnable driver for the whole
  flow). Both files live in this repo and in `un1ca-universal`
  (`scripts/` in each). Small text files only — no binaries.
- **Format:** one line per event —
  `2026-11-24T23:56:11+05:30 [INFO] [download] message key=value`
  — IST timestamp, level (`INFO` / `WARN` / `ERROR`), stage
  (`version-check`, `download`, `verify`, `drive`, `logger`), then
  the message and `key=value` fields.
- **What it logs, deeply:**
  - version-check: region, tool + version, the raw checkupdate
    response verbatim, the SamFrew/samfirm cross-check evidence,
    and the pinned version in use;
  - download: source (Samsung FUS), model/region/version, resume
    state, progress checkpoints, speed/duration, completion, and
    the hash computed vs the expected reference;
  - verify: zip size, every zip entry, BL/AP/CP/CSC/HOME_CSC
    presence, MD5/SHA-256 computed vs reference, and the
    trailing-MD5 check result for each `.tar.md5`;
  - drive: method, each part's bytes + MD5, upload duration,
    full error text on failure, retries, and the final Drive path
    + hashes once verified on Drive.
- **Where the log lives:**
  - Local (working copy): `~/workspace/firmware/m51-latest/firmware.log`
  - Drive (with the firmware): `backups/m51-hyperos/firmware/firmware.log`
  - The pre-logger steps (2026-11-24 23:54–00:56 IST) were
    retrofitted into the same file from the live session notes
    with their real timestamps — the log says so in its header.
- **How to read it:** `grep` by stage or level, e.g.
  `grep '\[ERROR\]' firmware.log` for failures,
  `grep '\[drive\]' firmware.log` for the upload history,
  `grep 'verify' firmware.log` for the verification record.
- **How to re-run a failed step from the log:** the log names the
  exact command and inputs for every step. The driver is
  idempotent — re-running `bash scripts/fetch-firmware.sh` skips
  completed steps (the download resumes from its `.part` file;
  Drive parts already present by name+size are not re-uploaded)
  and re-does only what failed. To re-run one step only:
  - version-check: `bash scripts/fetch-firmware.sh --check-only`
  - download+verify only: `bash scripts/fetch-firmware.sh --skip-drive`
  - Drive only: re-run the full script — steps 1–3 are skipped as
    complete and only the upload runs.

## Sources

- SamFrew INS listing + DXJ1 firmware page (identifiers, file name,
  size, CSC features): https://samfrew.com/model/SM-M515F/region/INS/
- samfirm.shop M51 page (global newest PDA string DXJ2, 42 regions)
- samloader-rs releases: https://github.com/topjohnwu/samloader-rs/releases
