# SpiderGirl-OS HIDL→AIDL HAL-swap patterns (reference, no code)

Source: SpiderGirl-OS — an AstroROM fork (One UI 8.5) with a working m51
objective. The only repo in the Mehedi deep-dive with proven-green m51
builds recently (5/5 success, Oct 23–24 2026). Full deep-dive:
`research/08c-mehedi-other-repos.md` (in the m51-hyperos repo), SpiderGirl
section. Credit: AstroROM / SpiderGirl-OS.

This file documents the PATTERNS only. No SpiderGirl code is vendored
here: its HAL swaps are binary swaps from other devices' blobs, and
copying them would import binaries we have not verified. The patterns
are what transfers to our HyperOS port (6-layer plan, L4 HAL bridges).

## The pattern, in general

A HIDL HAL on the m51 vendor cannot be consumed by a system that expects
the AIDL version of the same HAL. SpiderGirl's answer: take the AIDL
version of that HAL from a newer Samsung device whose vendor stack is
close (Galaxy S22 `r9q` blobs), install the service binary + its libs
into the m51 vendor image, and rewrite the VINTF manifest and the
compatibility matrix so the system sees the AIDL HAL instead of the HIDL
one. The rewrites are `sed` edits to the manifest + matrix files — small,
reviewable, and the part worth copying exactly.

## The three working swaps (as documented in the dive)

| HAL | From HIDL (m51) | To AIDL (donor) | How |
|---|---|---|---|
| Lights | HIDL lights service | `vendor.samsung.hardware.light-service` binary + `lib64/vendor.samsung.hardware.light-V1-ndk_platform.so` from r9q (S22) | `light/Replace-Light-HAL.sh`: binary swap + manifest sed |
| Vibrator | HIDL vibrator 2.2 | AIDL vibrator-service from r9q | `vibrator/Replace-Vibrator-HAL.sh`: HIDL 2.2 → AIDL + manifest sed |
| Camera (snap) | HIDL snap camera | AIDL snap HAL v3 from r9q, with manifest + compatibility-matrix sed rewrites | `camera/Fix-Camera.sh`: Polarr libs from a73xq + stock ArcSoft libs + AIDL snap v3; portrait preview fix; `ueventd.rc` diff; midas + singletake blobs from source |

Plus the **FCM 4→5 bump with configstore removal** (`fcm/` in the same
objective): raise the framework compatibility matrix level and remove
the configstore HAL the newer matrix no longer expects. That is the
recipe our port plan's Phase 0 / L4 needs if the m51 vendor FCM level
has to move (open check: Hyper371 says the vendor manifest is
target-level 5, our Phase 0 audit says 6 — read the real manifest
before bumping anything).

## What NOT to take from SpiderGirl

- **The lights swap itself: do NOT apply it to our HyperOS port.**
  It is a binary swap from r9q — a black box — and it CONFLICTS with
  our source-built AIDL lights HAL (the forked `hardware/samsung` with
  the no-op NOTIFICATIONS light, already built). Keep our source-built
  HAL; borrow the swap *pattern* for other HALs, never the r9q lights
  binary. Never apply both.
- **Its RIL "fix":** only a 1.4→1.5 manifest string change — it breaks
  at runtime if 1.5 methods are actually called. A manifest string is
  not a HAL.
- **Its kernel:** an unpinned raw URL + third-party zip with no hash
  check. Same trap as every unpinned download in FETCH-SPEC.md.
- **The vendored samloader binary:** verify it before trusting it
  (same rule as `samfirm.js` in `vendor/borrowed/projectarcadex/`).
- **Delivery:** GoFile/PixelDrain, not GitHub artifacts. Not our route.

## How to use this doc

When the HyperOS port reaches a HAL that the system expects as AIDL
and the m51 vendor only has as HIDL, follow the pattern: (1) find the
AIDL service + libs on the closest newer Samsung donor (r9q first);
(2) install them into the vendor image; (3) sed the VINTF manifest and
the compatibility matrix; (4) verify with the VINTF parser precheck
(Hyper371's method) before any device test. If a source-built
replacement exists (as it does for lights), prefer it over the binary
swap.
