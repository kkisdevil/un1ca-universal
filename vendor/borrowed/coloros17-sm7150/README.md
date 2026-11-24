# vendor/borrowed/coloros17-sm7150 — pieces borrowed from Arnav's ColorOS 17 port

Source: Arnav3078/ColorOS17-SM7150, branch `main` @ `7c46e3c` (all 15
commits on 2026-11-10), GPL-3.0. Credits: toraidl (ColorOS porting
research/tools), OPPO & OnePlus, "All SM7150 developers". Files here are
byte-identical to that commit (SHA-256 recorded below). Full deep-dive:
`research/09b-arnav-ports.md` §2 (in the m51-hyperos repo).

## Files

| File | SHA-256 | What it is | Use in OUR build |
|---|---|---|---|
| `patch_boot.py` (6,943 B) | `7554310cbeb39fc2d2ebae0a321848eb0b6a75f686e1a0cb35000537c682cbfd` | Pure-Python (stdlib-only) boot-image tool: parses a boot image header (v2), appends `androidboot.selinux=permissive` to the cmdline, gunzips the ramdisk, walks the CPIO entries, patches `fstab.default` / `fstab.qcom` / `fstab.sm7150`, rebuilds + re-gzips. Warns (does not fail) if no fstab is found. | The permissive-boot-image tool for the HyperOS port (L1). Adapt the partition list when using it (drop the `my_*` entries, keep system/system_ext/product EROFS). Not used by the UN1CA build — vendored here because it is the reusable tool from this deep-dive. |
| `m51.cil` (1,195 B) | `76859a988d986c1044739a9536fa570ba4a871846763d814346891ef072d860e` | Minimal sepolicy bridge template: binder `call`/`transfer` allows between system_server and hal_fingerprint/sensors/audio/allocator/composer defaults, plus fingerprintd data-file rules. | Template for the HyperOS port's L4 sepolicy bridging (compare with Hyper371's full offline `secilc` compile). |
| `device.prop` (843 B) | `3506e94ceb817fcde8bf4319962528090b652d279b7521c3ed9a33b9415cb237` | Fingerprint mapping: `ro.oplus.display.fp.type=0`, `persist.vendor.fingerprint.type=side`, `persist.sys.fp.side=true`, `ro.hardware.fingerprint=m51` — points the donor's in-display biometric stack at the standard `android.hardware.biometrics.fingerprint@2.1` HAL. | Pattern for the HyperOS port Phase 3 (disable the optical UI paths, keep the HIDL path). |
| `tweaks.prop` (4,663 B) | `2de1ed9f5caff969efce91348f9578792c56fb65246dc80e5bcb5842a4c766e7` | VoLTE bypass (`persist.vendor.radio.ims_retry=0`, `persist.dbg.volte_avail_ovr=0`, `vt/wfc_avail_ovr=0` — disables the IMS retry loops "to save battery"), plus blur/perf props. | The VoLTE **bypass** as the documented fallback for the HyperOS port's IMS problem (vs Floss IMS per-carrier, vs OneOS's staged Samsung IMS). It stops the crash loops and keeps calls on 3G/CSFB — and gives up VoLTE entirely. Record it as the fallback, not the goal. |

## What was NOT taken (and why)

- The ColorOS port itself (`port_coloros.sh`, `make_super.sh`, the
  workflow): a ColorOS pipeline, not a UN1CA input. Its fstab recipe
  (ICE→encryptable, strip AVB, EROFS entries, `nofail`), EROFS repack
  (`mkfs.erofs --all-root --file-contexts`, LZ4HC), super sizing
  (lpmake, `resize2fs -M`, hard-fail on overflow), TEE neutralisation,
  and recovery-overwriter removal are documented as patterns in the
  deep-dive (§2) — copy the pattern into the HyperOS port work, not
  the scripts verbatim.
- **Recovery-overwriter removal** (the TWRP mechanism, worth naming
  here because it governs every flash we do): ColorOS's
  `port_coloros.sh` §3 deletes `recovery-from-boot.p`,
  `bin/install-recovery.sh`, `etc/init/vendor_flash_recovery.rc`
  from the vendor image — stock vendor tries to restore stock recovery
  on boot, and removing these three files is how a port *keeps* TWRP.
  Add this as a step to every install/flash checklist.
- The "working" claims (Dual SIM, LTE, SMS, Wi-Fi, BT): **unproven** —
  0 releases, no test report, no boot log. The 5 green runs prove the
  packaging pipeline, not that the ROM boots. Do not repeat the claims
  as facts.
- The unpinned toolchain (`setup_tools.sh` downloads lpmake/lpunpack +
  lib64 from `toraidl/coloros_port` raw URLs, no hashes): pin + hash
  before reuse. KernelSU-on-by-default: a root decision that is not
  ours to inherit silently. `my_*` donor partitions: donor bloat, do
  not import the pattern.
