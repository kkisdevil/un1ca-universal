# vendor/borrowed/projectarcadex — pieces borrowed from ProjectArcadeX

Source: SameerAlSahab/ProjectArcadeX, branch `sixteen` (updated
2026-10-13), MIT. "Script based rom patcher which downloads firmware,
applies ota, patches and create a flashable Samsung ROM zip for all
supported devices." Full deep-dive: `research/09c-arnav-stars.md` §2 (in
the m51-hyperos repo). MIT code borrowed into our GPL-3.0 project stays
GPL-3.0 — credit + licence note required either way (this file is the
note).

**Do NOT use ProjectArcadeX as a ROM base for m51.** It has 9 objectives,
all S-series (`b0q, b5q, dm1q, dm2q, dm3q, q2q, r9q, r9q2, r9s`),
platforms Exynos 2100 + SD 8550 only — zero m51/sm7150 mentions
anywhere. A forced m51 build gets no kernel handling and no platform
patches: an unbootable zip. The files below are the borrowable methods,
not the ROM.

## Files

| File | SHA-256 | What it is | Use in OUR build |
|---|---|---|---|
| `auto_gen.sh` (11,165 B) | `d8a3cceb47419b1d308899c932b770666700ccccc9ed184402f66cf5569c0329` | `GENERATE_CONFIG`: derives device facts from the STOCK firmware's own XMLs/properties instead of hand-writing them — HFR mode, MDNIE mode, dual speaker, supported refresh rates, auto-brightness level, fingerprint sensor type, brand name, SIOP policy filename, vendor release/SDK, VNDK version. Objective files carry a commented override list for all of these. | Porter improvement candidate: derive, don't declare. Our porter hand-writes `devices/<codename>.json` from the upstream `target/<codename>/config.sh`; `auto_gen.sh` is the pattern for generating that manifest from the stock firmware itself. Open check: it reads sensor TYPE, not position — it does not solve the m51 two-panel fingerprint-position problem. |
| `samfirm.js` (441,159 B) | `fc9101fec550b48b7f52be0a67757e13f6f3092f9dfa544c3494056457f515d8` | Vendored copy of jesec/samfirm.js 0.3.0 (Jesse Chan, GPL-3.0-or-later): a streaming downloader/decryptor/extractor for Samsung firmware, direct from Samsung's servers. Bundled single-file Node script (`#!/usr/bin/env node`, webpack bundle). Run: `samfirm.js -m <model> -r <region> -i <IMEI>`. | Third firmware-download route (alongside samloader-rs and Python samloader). **Verify its hash against jesec's releases before trusting it as a download route** — this copy is ArcadeX's vendored build, and a bundled file cannot be hash-checked against source. Open check from the deep-dive. |

## Patterns documented (not vendored as code)

- **`EXEC_SCRIPT` md5 marker caching** (`build.sh`): a patch step
  re-runs only if its hash changed — idempotent re-runs. Adopt the
  pattern for porter steps that re-run across builds.
- **Knox smalipatches as study material** (`arcadex/knox/`:
  Fix-KnoxGuard, Bypass-Integrity-Verification, Fix-Secure-Folder,
  Fix-SHealth-App): smalipatches that FIX Knox apps on custom ROMs
  (different from removing them — relevant to our keep-everything
  scope). Study only; do not adopt blindly.
- **`prebuilts/` tooling** (simg2img, lpunpack, lpmake, erofs-utils,
  apktool, smali/baksmali, signapk with aosp_testkey): the image tools
  our blob-refresh work noted missing on this VM. Not vendored here
  (binaries + test-key signing); the pattern is "vendor the tools with
  hashes", which FETCH-SPEC.md applies to our own toolchain pins.
- **Encryption-removal step** (`Remove-samsung-encrytion.sh`, DFE): a
  deliberate security-model change (decrypted only), not a default. Do
  not inherit it silently.
