# FETCH-SPEC — pinned fetch spec for everything the build pulls that is NOT vendored

Anything the build downloads at build time must be pinned here: exact
repository + commit/tag, exact URL, and a checksum wherever one exists.
A build must never depend on an unpinned "latest" — that is how Build
ROM #4 died (an unauthenticated API call hit the rate limit and the
kernel URL came back empty) and how a moved file breaks a build
silently. If a row below says "unpinned", that is a known gap, not an
accepted state — pin it before relying on it.

Rule of thumb for what goes here vs in `vendor/`: if it fits in the repo
and its licence allows redistribution, it is vendored (see
`vendor/README.md`). If it is too big, proprietary, or a whole repo, it
is fetched at build time and pinned here.

## 1. Inventory — every external thing the build pulls, at a glance

| # | Thing | Source | Pin | Size | Licence | How the build gets it |
|---|---|---|---|---|---|---|
| 1 | Upstream UN1CA fork (whole tree) | Arnav3078/UN1CA-SM7150 | branch `seventeen`, commit `f6790355358fe9a83df4db080f3c8f7360c63d7f` | repo 4.0 GB (shallow checkout, much less) | GPL-3.0 | `actions/checkout` into `./upstream`, `submodules: recursive`, `fetch-depth: 1` |
| 2 | m51 target (the part we modify) | same as 1, `target/m51/` | same commit | 7.8 MB total; 65 text files ~300 KB vendored, 9 proprietary binaries ~7.5 MB NOT vendored | GPL-3.0 / Samsung proprietary (binaries) | Vendored copy in `vendor/arnav-un1ca-sm7150/target-m51/`; binaries from the upstream checkout (verified by `use-vendored-target.sh`) |
| 3 | Kernel (LostPrime m51-ksu) | kurtnettle/android_kernel_samsung_sm7150 releases | `releases/latest`, asset matching `m51-ksu*.zip` — **unpinned by version** (see §3) | ~20 MB | NOASSERTION (repo); kernel code itself GPL-2.0 | Upstream `patches/kernel/customize.sh` via GitHub API with `$GITHUB_TOKEN`; pre-flight step in the workflow resolves the same URL up front |
| 4 | DXJ2 bootloader/modem firmware set | mehedihjoy0/M51-FIRMWARES | branch `main`, commit `a060572e864c69a53ce2d8382b9c099edbfb5bfe` (2026-07-04) | repo ~179 MB; 27 partition blobs | none (no licence file) | Upstream `target/m51/installer/customize.sh` clones it into `out/cache/M51-FIRMWARES` at build/install time; the zip flashes modem/vbmeta/etc. (never recovery) |
| 5 | Source firmware (Galaxy S23) | Samsung FUS via samloader | `SM-S911B/INS/352404911234563` (string from `target/m51/config.sh`); actual build downloaded is whatever FUS reports latest for that model/CSC | 16.7 GB | Samsung proprietary | `scripts/download_fw.sh` → samloader |
| 6 | Target firmware (Galaxy M51) | Samsung FUS via samloader | `SM-M515F/BVO/357563172596302` | 5.41 GB | Samsung proprietary | `scripts/download_fw.sh` → samloader |
| 7 | Extra firmware (Galaxy S21 FE) | Samsung FUS via samloader | `SM-G990B/EUX/353718681234563` | 8.79 GB | Samsung proprietary | `scripts/download_fw.sh` → samloader |
| 8 | Python samloader (old) | ananjaser1211/samloader | source tarball from GitHub codeload, `master` — **unpinned by commit** (see §3) | ~45 KB source | (check repo licence before redistributing) | `external/samloader` submodule (row 10) + venv in `build_dependencies.sh`; gone from PyPI (404 since 2026-11-24) — do not `pip install samloader` |
| 9 | samloader-rs (replacement) | topjohnwu/samloader-rs | release `2.0.0`, asset `samloader-v2.0.0-linux-x86_64.tar.xz` | 2,328,736 B | (check repo licence) | `scripts/fetch-samloader-rs.sh` (pinned + SHA-256 verified); NOT yet wired into `download_fw.sh` — see §3 |
| 10 | External submodules (build tools) | UN1CA/external_android-tools, iBotPeaches/Apktool, sekaiacg/erofs-utils, UN1CA/external_img2sdat, ananjaser1211/samloader, UN1CA/external_signapk | commits in §2 | whole repos (checked out shallow by the workflow) | Apache-2.0 (android-tools, apktool), GPL-2.0/Apache-2.0 (erofs-utils), MIT (img2sdat) | `actions/checkout` with `submodules: recursive` |
| 11 | apktool jar (smali/baksmali source) | built from row 10 (Apktool submodule) | submodule pin (row 10) | jar built at build time | Apache-2.0 | `build_dependencies.sh` (`external/make.sh`); `install-smali-tools.sh` runs baksmali/smali from it |
| 12 | smali thin jars (fallback) | Maven Central, `org.smali` 2.5.2 | version `2.5.2` | small | (smali licence) | `install-smali-tools.sh` fallback if the apktool jar drops the smali classes |
| 13 | apksigner | Android SDK build-tools r34, dl.google.com | `r34` | ~61 MB | Android SDK licence | `install-smali-tools.sh` |
| 14 | JDK 17 | Temurin via actions/setup-java@v6 | `java-version: '17'`, distribution `temurin` | ~200 MB | GPL-2.0+CE | workflow step "Set up JDK 17" |
| 15 | apt packages | Ubuntu 24.04 (noble) archives | package names, no version pins (see §3) | — | various | `scripts/setup-tools.sh`: attr ccache clang ffmpeg gh libbrotli-dev libbz2-dev libgtest-dev libprotobuf-dev libunwind-dev libpcre2-dev libzstd-dev lld protobuf-compiler webp jq curl python3 |
| 16 | GitHub Actions | actions/checkout@v7, actions/setup-java@v6, actions/cache@v4, actions/upload-artifact@v4, nick-fields/retry@v4, jlumbroso/free-disk-space@main, rokibhasansagar/slimhub_actions@main | major-version tags (v7/v6/v4); the last two are `@main` — **unpinned** (see §3) | — | various | workflow steps |
| 17 | Qwen 2.5 0.5B GGUF (offline local AI) | HuggingFace `Qwen2.5-0.5B-Instruct-GGUF`, file `qwen2.5-0.5b-instruct-q4_k_m.gguf` | model revision unpinned (see §3) | ~350–400 MB | (model licence — check before redistributing) | NOT a build input: downloaded on first use on the device (Settings → Offline Local AI). Listed here so nobody mistakes it for a bundled model. |

Not a build input, listed so it is not confused with one: the kernel
toolchain proton-clang (kdrag0n/proton-clang, master @
`9fb011b183fe7e69b04b873ef6533b4b077e3c5e`, Clang 13.0.0) belongs to the
m51 HyperOS kernel build (m51-hyperos repo), not to this UN1CA build —
the UN1CA build downloads the prebuilt LostPrime kernel zip (row 3)
instead of building a kernel.

## 2. External submodule pins (Arnav seventeen @ f679035535)

Read live 2026-11-24 from the GitHub tree API
(`git/trees/seventeen:external?recursive=1`). These are the commits the
workflow's `submodules: recursive` checkout records — they move only
when Arnav's tree records a new submodule commit.

| Submodule path | Upstream repo | Pinned commit |
|---|---|---|
| `external/android-tools` | UN1CA/external_android-tools | `f9bef94306f93be88b0cf98f9eeb0e24fc7b6aa8` |
| `external/apktool` | iBotPeaches/Apktool | `52d1cbd62ba4fb1872b1923642b4f92bb3cd7969` |
| `external/erofs-utils` | sekaiacg/erofs-utils | `620bf019a3eb6a9a2d8fa807a3034e5cc2b38d8a` |
| `external/img2sdat` | UN1CA/external_img2sdat | `fc05bbf92bc0218d86145e85145a3fbdcbad0ce6` |
| `external/samloader` | ananjaser1211/samloader | `3c372007945d4f3f165433a1d5ae40523d7f68bf` |
| `external/signapk` | UN1CA/external_signapk | `9c6884257be8855cb7d8ab9c2a20db9b90a44227` |

`scripts/build_dependencies.sh` is a one-line redirect to
`../external/make.sh` — the real dependency build lives in the
submodule tree (external/make.sh), not in Arnav's `scripts/`.

## 3. Pinned fetch specs (exact URLs + checksums)

### samloader-rs v2.0.0 (the firmware-download replacement)

- URL: `https://github.com/topjohnwu/samloader-rs/releases/download/2.0.0/samloader-v2.0.0-linux-x86_64.tar.xz`
- Size: 2,328,736 B
- SHA-256: `7c6514028f20d5ea0eb57d6f872eee41b3a52336eabac6379b15a01a06ed7a79`
- Fetch: `bash scripts/fetch-samloader-rs.sh [dest-dir]` (verifies size +
  SHA-256, extracts `samloader`)
- Use: `samloader download --model <MODEL> --region <CSC>` — no IMEI or
  serial needed (the old Python samloader needed both).
- **Status: fetched by script, NOT yet wired into the build.** Arnav's
  `download_fw.sh` still calls the old Python samloader from the venv
  built by `build_dependencies.sh`. Switching `download_fw.sh` to
  samloader-rs is a planned change (it also answers the open question
  of whether samloader-rs returns DXJ2 for INS without an IMEI — our
  blob-refresh work found a no-IMEI query returns the stale DXE3
  latest; verify the downloaded firmware version before trusting a
  build to it).
- Newer releases exist (2.2.0 as of 2026-11-24). Do not bump the pin
  until a release is verified against the same flow.

### LostPrime kernel — latest release, asset pattern (unpinned by version)

- API: `https://api.github.com/repos/kurtnettle/android_kernel_samsung_sm7150/releases/latest`
- Asset pattern: `m51-ksu*.zip` (file `LostPrime-Kernel-m51.zip`, ~20 MB)
- Auth: `$GITHUB_TOKEN` (Bearer) — the workflow exports it at job level
  and the "Pre-flight kernel release" step resolves the same URL up
  front so a failure lands in seconds, not 1h25m into the build
  (Build ROM #4).
- **Known trap:** the Nov 11 release is self-flagged corrupted
  ("This build is corrupted", assets only ~3.5 MB vs the usual ~20 MB).
  `releases/latest` points at the newest release — if a future release
  is corrupted the same way, the pre-flight step will still pass (an
  asset exists) and the build will fail later. Pin a known-good release
  tag if this bites again.

### M51-FIRMWARES (DXJ2 bootloader/modem set)

- Repo: `https://github.com/mehedihjoy0/M51-FIRMWARES`, branch `main`,
  commit `a060572e864c69a53ce2d8382b9c099edbfb5bfe` (2026-07-04),
  repo ~179 MB, 27 partition blobs (raw images, NOT Odin firmware).
- The installer clones it into `out/cache/M51-FIRMWARES` and flashes
  modem, vbmeta, abl, aop, apdp, bksecapp, cmnlib(64), devcfg, dsp,
  hyp, keymaster, msadp, optics, prism, qupfw, secdata, storsec, tz,
  uefisecapp, vk, xbl, xbl_config, apnhlos. **No recovery flash.**
  It also deletes any packaged `recovery.img` from the zip ("Never
  package or overwrite user's custom recovery").
- **Never flash these blobs by hand** — they are raw partition images;
  flashing the wrong one is brick-risky. They only ever go in through
  the installer's edify script.

### Python samloader source (unpinned by commit — gap)

- Repo: `https://github.com/ananjaser1211/samloader` (submodule pin
  `3c372007945d4f3f165433a1d5ae40523d7f68bf` — that IS the pin for the
  code the build uses; the "unpinned" gap is only the source-tarball
  workaround used locally for blob-refresh work, which fetches
  `master` from codeload without a commit).
- Gone from PyPI (404 since 2026-11-24). Do not `pip install samloader`.

### Unpinned items (known gaps — pin before relying on them)

- `jlumbroso/free-disk-space@main` and `rokibhasansagar/slimhub_actions@main`:
  `@main` moves. Pin to a commit SHA when either is next touched.
- apt packages in `setup-tools.sh`: names only, no version pins.
  Ubuntu 24.04 archives move slowly, but a pin would be a snapshot
  (acceptable risk for a build image that is itself dated).
- Qwen GGUF model revision: unpinned; the model is downloaded
  on-device on first use, not at build time.
- The `gh` CLI (used by `release_rom.sh` / `build_incremental.sh`) and
  the `static_resources` release repo: the OTA scripts resolve
  `<owner>/static_resources` and fork `UN1CA/static_resources` if it
  does not exist — retarget to OUR release repo before ever running
  them with `release_rom=true` (see `vendor/arnav-un1ca-sm7150/README.md`).

## 4. Size / licence reasons (why each non-vendored item stays out)

- **Firmware (~30.9 GB/build)**: GitHub rejects any single file over
  100 MB; free LFS is 1 GB storage / 1 GB bandwidth. Samsung firmware
  is also proprietary. Build-time download only.
- **Built ROM (~10.9 GB)**: artifact with 7-day retention, not source.
- **Toolchains (JDK 17, build-tools r34, proton-clang)**: GBs, fetched
  at build time from their vendors.
- **Proprietary binaries (RIL .so files, Odin, Samsung firmware)**:
  never in this GPL-3.0 repo. The RIL binaries come from the upstream
  checkout; Odin and the official firmware are covered by the flashing
  guide in `docs/BUILD-GUIDE.md` (named sources, not committed files).
