# m51-performance — porter performance pack for the Galaxy M51

A porter-side override pack: modified copies of four upstream files that
the workflow copies over the upstream checkout before `make_rom.sh` runs.
It fixes the lag causes diagnosed in
`research/06-performance-lag-m51.md` and
`research/06c-frame-rate-60.md` — without touching upstream's repo, so the
fixes ride along with every build and survive upstream updates (until
upstream moves a file; see "Maintenance" below).

## User scope decision (binding, 2026-11-24)

Keep **all** UN1CA flagship features, remove **blur effects only**.
That is why this pack contains F1, F2, F3, F5, P0 and P1 — and
deliberately does **not** contain F4 (see "Not implemented" below).

## How it is applied

`.github/workflows/build.yml`, step "Apply porter performance patches",
runs between "Checkout upstream UN1CA fork" and "Set up build
environment":

```
bash patches/m51-performance/apply-performance-patches.sh <upstream-dir> <device>
```

The script copies the four override files below over the upstream
checkout (relative paths preserved), verifies each copy landed
byte-identical and carries the `PORTER OVERRIDE` marker, and fails
loudly if an upstream target file no longer exists. It is m51-only: any
other device codename is skipped with a clear message.

This pack is **not** an upstream module: it is never fed to
`apply_modules.sh`. The `module.prop` next to it exists because the
repo's `scripts/validate-patches.py` requires one for every directory
under `patches/`.

## Overrides

All line numbers are against upstream
Arnav3078/UN1CA-SM7150@`seventeen` as read on 2026-11-24 (the same
revision Build ROM #5 used). Upstream files were verified to exist at
those paths via the GitHub API before the pack was written.

### F1 — Relax the thermal caps

**File:** `target/m51/dvfs/siop_model.xml` (installed into the ROM as
`siop_m51_sm7150.xml` by `unica/patches/dvfs/customize.sh:74–89`).
**Evidence:** research/06 §3. Temperatures are in 0.1 °C; each limiter
lists thresholds and the value that applies from each threshold up
(the last value persists above the top threshold).

| Location | Upstream | Override | Why |
|---|---|---|---|
| AP `CPUFreqMax` (:79) | cap 1.7088 GHz from 35 °C (`temp="350:380"`) | cap engages at 45 °C (`temp="450:480"`) | The phone sits at 35–38 °C in ordinary use in India, so the cap was engaged most of the time, not just under load |
| AP `GPUFreqMax` (:80) | cap 565 MHz from 35 °C | cap 650 MHz from 45 °C | 565 MHz is below the Adreno 618's ~700 MHz max; 650 MHz is still a cap, just a less punishing one |
| `SIPStart` / `AppStart` / `Badge` / `WakeUp` CPU (`:93–99`) | cap from 55 °C (`550:600:620`) | engage 5 °C later (`600:650:670`) | App launches were throttled while the phone was merely warm |
| Same four scenarios, GPU | cap 565 MHz from 55 °C (`550:600`) | cap 650 MHz from 60 °C (`600:650`) | Same treatment as the AP caps |
| `GameThermalGpuControl` id `-3` (:146) | hottest tier 267 MHz | hottest tier 430 MHz | The game floor: 267 MHz is what makes games stutter within minutes |
| `GameThermalGpuControl` id `-2` (:147) | hottest tier 355 MHz | hottest tier 430 MHz | Raised alongside `-3` so the tier ordering stays monotonic (the floor is 430 MHz; `-3` must not undercut `-2`) |

**Untouched on purpose:** the `overheatcontrol` complex (the real
overheat protection), the `DISPLAY` brightness limiter, `AppInstallDelay`,
`CameraFps`, and the game **CPU** tiers. Risk: more heat and battery
drain — the 730G is an 8 nm chip that tolerates 45 °C easily, but
validate with a thermal log on-device (research/06 §15 step 3).

### F2 — Live blur off by default

**File:** `target/m51/patches/tweaks/customize.sh`.
**Evidence:** research/06 §4. Upstream forced blur on in two blocks and
in `floating_feature.xml`; this override turns all three off.

- **Blur block (:72–97):** `persist.sys.unica.nativeblur` `true` →
  `false`, `ro.surface_flinger.supports_background_blur` `1` → `0`
  (vendor + system). The `ro.sf.blurs_are_expensive --delete` lines
  are **removed** — the system's own "blur is expensive" cost flag is
  left in place so the system can decline blur on cost grounds.
  Hardware-acceleration and SkiaGL renderer choices in the same block
  (`debug.egl.hw`, `debug.sf.hw`, `ro.hwui.use_vulkan=false`,
  `debug.hwui.renderer=skiagl`) are **unchanged** — they are not blur.
- **Tuning block (:198–224):** the same four prop values are changed
  there too. This is the part research/06's F2 line range (72–97)
  missed: the tuning block runs **after** the blur block in the same
  script and re-asserts `nativeblur=true` /
  `supports_background_blur=1`. `SET_PROP` replaces the value in place
  (upstream `scripts/utils/common_utils.sh:649`), so the last call
  wins — an F2 that only touched 72–97 would have been silently
  undone by this block.
- **`floating_feature.xml` block (:188–196):** the three blur feature
  flags are forced `FALSE` instead of `TRUE`
  (`3D_SURFACE_TRANSITION_FLAG`, `CAPTURED_BLUR`, `PARTIAL_BLUR`).
  Research/06's F2 named only lines 72–97, but the flags are the same
  blur enablement in the same file, and the user scope is "no blur
  effects" — leaving them `TRUE` would still advertise blur features
  the renderer cannot (and should not) provide.

Expected effect: the single largest GPU-load reduction available
without touching the kernel — every blur surface (notification shade,
quick panel, recents, dialogs) stops being rendered live per frame on
the Adreno 618.

### F3 — Restore stock zram, drop swappiness 100

**File:** `target/m51/patches/tweaks/customize.sh`.
**Evidence:** research/06 §5.

- The `zramsize=0` rewrite (:10–17) is **deleted**: the stock m51
  fstab value survives. No size is invented — restoring stock is the
  safe move; measure before tuning further.
- `sys.sysctl.swappiness` `100` → `60` in all four places
  (:79, :87, :206, :219). Research/06 offered "drop the overrides or
  set 60"; 60 is set explicitly because it is deterministic (the
  AOSP default) and the ROM then has a known value rather than
  whatever the vendor default happens to be. With no zram, swappiness
  100 was incoherent: the kernel was told to prefer swapping while
  having nowhere to swap to.

Expected effect: fewer low-memory-killer kills on the 6 GB variant —
warm app switches instead of cold starts.

### F3-daemon — Neutralise the daemon that undoes F3 at boot (added 2026-11-24)

**File:** `unica/mods/settings/system/bin/carbon_power_engine`
(Arnav's 5.3.0+ Performance Profile engine, installed by the
`unica/mods/settings` mod).
**Evidence:** research/09-arnav-un1ca.md §1.4. Build-time props are
not the last word: `carbon_power_engine boot` runs `apply_zram()`,
which does `sysctl -w vm.swappiness=100` at **every boot** — after
init applies the F3 prop — so on build #7 (5.4.0) the effective
runtime swappiness was 100, not the F3 value 60. The prop alone
cannot fix this; the daemon has to be patched (or removed — it is
not removed, because the Performance Profiles are a flagship
feature the user scope keeps).

- `apply_zram()`: `vm.swappiness` `100` → `60` — the only change in
  this file. The other five sysctls in the function
  (`vfs_cache_pressure=50`, `watermark_boost_factor=0`,
  `watermark_scale_factor=150`, `dirty_ratio=20`,
  `dirty_background_ratio=5`) are **unchanged**: they are VM tuning,
  not the F3 value, and the pack does not invent new values for them.
  (The function name is misleading — it touches no zram at all, only
  sysctls. The actual zram restore is the F3 `zramsize=0` deletion
  above; the daemon does not set a zram size.)
- The daemon itself, its three power modes, the `unica-gpu` daemon,
  and the `carbon_power.rc` init service are **unchanged** — only the
  one swappiness write is aligned with F3. Performance mode's
  `force_rail_on`/`force_clk_on`/`force_bus_on` still hold the SoC
  hot against F1's caps; that is a separate, user-visible trade-off,
  not a bug this pack fixes.

Verify on a booted device, not from the prop: `cat
/proc/sys/vm/swappiness` must read `60` after a reboot. If it reads
`100`, the daemon override did not land (or upstream moved the file
and the apply script failed the build — which is the intended
behaviour).

### F5 — Keep the stock perf configs

**File:** `target/m51/patches/tweaks/customize.sh` (:1–4).
**Evidence:** research/06 §7.

The `DELETE_FROM_WORK_DIR "vendor" "etc/hyper"` / `"etc/perf"` lines
are **deleted**. Those directories hold the Qualcomm perfd /
performance-HAL configuration (boost tables, per-app hints). Deleting
them removed the capping — the stated intent — but also the
*boosting*: with no perf config, the perf HAL cannot raise
frequencies on touch, app launch, or scroll. Effect is unproven from
code alone (the files live in the m51 stock firmware, not in git) —
measure with and without (research/06 §15).

### P1 — Explicit SurfaceFlinger 60 Hz props

**File:** `target/m51/patches/display/vendor.prop` (applied by
upstream `READ_AND_APPLY_PROPS`).
**Evidence:** research/06c §6 (P1).

Upstream's 7 lines are kept verbatim, and three props are added:

```
ro.surface_flinger.enable_frame_rate_override=false
ro.surface_flinger.use_content_detection_for_refresh_rate=false
ro.surface_flinger.game_default_frame_rate_override=60
```

Why this is not redundant: the legacy backport
(`unica/patches/legacy/customize.sh` `BACKPORT_SF_PROPS`) only
*adds* these props if they are missing — it never overwrites a value
the stock m51 vendor `build.prop` already carries. If the stock
vendor prop ships any of them as `true`, the ROM would keep `true`.
An explicit override closes that hole. Even in the worst case this
cannot produce 120 fps: the HWC only reports 60 Hz modes (06c §2).

### P0 — Build-time 60 Hz assertion (separate file, same fix set)

Not in this directory: `scripts/assert-60hz.sh`, run by the workflow
step "Assert 60 Hz pin (no 120 leaks)" after "Build ROM" (full mode
only). It greps the assembled work dir — the patched files exactly as
they are packed into the partition images — and fails the build if:

- the built `floating_feature.xml` (system, and vendor if present)
  has `HFR_DEFAULT_REFRESH_RATE` other than 60, `HFR_MODE` other
  than 0, or `HFR_SUPPORTED_REFRESH_RATE` listing any rate above 60;
- the built `vendor/build.prop` has
  `ro.surface_flinger.enable_frame_rate_override=true`.

The work dir is checked rather than the flashable zip because the
target-files zip contains partition *images* (EROFS), not plain files
— unpacking them in CI would need EROFS extraction tooling that is
not guaranteed on the runner. The work-dir files are the exact files
packed into those images, so the check is equivalent. On-device
proof is `getprop` / `dumpsys SurfaceFlinger` (06c §7).

## Not implemented (deliberately)

| Item | Why not |
|---|---|
| **F4** — stop re-adding Knox / SecureFolder / Now Brief / Personal Data Engine / Moments / SmartSuggestions | User scope (2026-11-24): keep **all** UN1CA flagship features, remove blur effects only. F4 would remove SecureFolder and Now Brief. Not applied, not gated behind a profile — left exactly as upstream ships it. |
| **F6** — Smooth Motion / SF phase offset on (`display/vendor.prop:3–4`) | A/B test only (research/06 §14). Unmeasured effect; do not ship without frame-time numbers. |
| **F7** — animation scale 0.5× | Perception only, not a performance fix; and animation scale is a Settings value, not a build prop. |
| **F8** — Vulkan renderer (`skiavk`) | Unproven on Adreno 618 with 2020-era vendor blobs; may be slower or broken. Test on-device first. |
| **P2** — seed `peak/min_refresh_rate=60` at first boot | Belt-and-braces only: the patched `SettingsProvider` already seeds these from the 60 default (06c §3.2). Skipped unless a device read shows the settings diverging. |
| **P3** — `vendor.display.use_smooth_motion=1` (SmoMo frame interpolation) | Experiment only. It is video-playback interpolation, not UI frame generation; zero effect on UI lag, and it adds composer load. Never in the default build. |

Also not proposed (research/06 §14): raising the refresh rate (60 Hz
hardware ceiling), changing the kernel governor (unverifiable from the
public tree — the LostPrime defconfig is not in the kernel repo),
switching EROFS to ext4 (no evidence it helps).

## Validation (local, before Build ROM #6)

- `bash -n` + `shellcheck` clean on `apply-performance-patches.sh`
  and `scripts/assert-60hz.sh`.
- `python3 scripts/validate-workflows.py` — 0 errors (after the two
  new workflow steps were added).
- `python3 scripts/validate-patches.py` — 0 errors (this pack's
  `module.prop` satisfies the per-module check; the pack has no
  `*.patch` files and no top-level `customize.sh`, so no patch checks
  apply to it).
- Override `customize.sh`: `bash -n` clean; diffed against upstream —
  the only changes are the F2/F3/F5 edits listed above.
- Override `siop_model.xml`: parses as XML (`xml.etree`); diffed
  against upstream — only the F1 limiter changes listed above.
- Override `vendor.prop`: upstream 7 lines verbatim + the 3 P1 props.
- Override `carbon_power_engine`: `bash -n` clean; diffed against
  upstream — the only changes are the `PORTER OVERRIDE` header comment
  and the `vm.swappiness` 100 → 60 line. Upstream path verified via
  the GitHub API (HTTP 200) at `Arnav3078/UN1CA-SM7150@seventeen`
  (`unica/mods/settings/system/bin/carbon_power_engine`, 7,397 B).
- `scripts/assert-60hz.sh` was exercised against fake work dirs
  (passing case + each failure case) — see its header comment.
- Upstream target paths verified via the GitHub API (HTTP 200) at
  `Arnav3078/UN1CA-SM7150@seventeen` before the pack was written.

## What is still unproven

Nothing in this pack is proven until measured on a real m51
(research/06 §15): flash, wait for background dexopt to finish,
then `dumpsys gfxinfo` frame times, thermal + frequency logs
(`/sys/class/thermal/`, `scaling_cur_freq`, `kgsl-3d0/gpuclk`),
LMK kill counts, and A/B each fix separately. The first measured
numbers on this device will be ours — the community evidence has no
FPS numbers anywhere.

## Maintenance

- If upstream changes any of the four overridden files, the apply
  script still copies the pack's copy over it (the copy is
  unconditional). Re-read the upstream diff on the next build failure
  and re-apply the same edits to the new copy — the README table
  above lists the exact upstream lines each change touches.
- If upstream *moves* or *deletes* one of the four files, the apply
  script fails the build loudly instead of silently dropping the fix.
  Update the pack (new path, or drop the override with a README note)
  — do not work around the failure by deleting the check.
- If upstream fixes any of these issues itself (e.g. blur off by
  default), delete the corresponding override here and note it in
  this README — do not keep a stale override that fights upstream.
