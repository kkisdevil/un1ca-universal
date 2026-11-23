# Booting complete Linux natively on Android phones — feasibility for Galaxy M51 (SM7150)

Research date: 2026-11-23. Read-only research, public sources only. No repo created.
Companion file: `04-uefi-dualboot.md` (UEFI / dual-boot side of the same question).

## Verdict up front

**Yes, complete Linux can boot natively on a phone — but NOT on the Galaxy M51 today, and not by installing something ready-made.**

- **Native Linux on phones is real and proven** — on a short list of devices, mainly Xiaomi/Pixel/OnePlus with Qualcomm Snapdragon SoCs, via postmarketOS (now renamed **Nura**) with a mainline kernel + U-Boot as a second-stage bootloader with EFI/systemd-boot.
- **The SM7150 (Snapdragon 730/730G/732G) SoC itself is one of the better-supported SoCs** for this: there is a generic `qcom-sm7150` port, a `sm7150-mainline` kernel (v7.2 branch, active June 2026) and U-Boot releases covering 6 devices.
- **The M51 has no Linux port at all.** No postmarketOS/Nura device page, no Droidian/Ubuntu Touch port, no mainline device tree (`sm7150-samsung-m51.dts` does not exist), no U-Boot board support, no Halium port. Zero search hits for "M51 + postmarketOS/Droidian/Ubuntu Touch".
- **The closest relative, the Galaxy A71 (same SM7150, same a71-devs Android base), is *almost* there but not merged:** device-tree PRs for A71 are open and unmerged in both `sm7150-mainline/linux` (#44) and `sm7150-mainline/u-boot` (#2), and A71 is absent from the latest U-Boot release (2025-12-02). A71 was announced as "coming soon" in April 2025 and still has not landed.
- **Closest real option for m51, ranked:** (1) a **Halium (Droidian / Ubuntu Touch) port** reusing the existing unofficial LineageOS 21/23 device trees for m51 + the 4.14 downstream kernel — the realistic first boot, but still a real porting project with a downstream kernel, not mainline; (2) a **mainline postmarketOS port** starting from the A71 DT work and adapting it to m51 — the proper long-term path, but weeks–months of expert kernel/device-tree work, and several phone features (camera, modem calls, fingerprint) would likely not work at first; (3) **Termux / proot / UserLAnd** — Linux userland *inside* Android, available today, but explicitly NOT native boot (see §1).
- **Do not start a repo promising "Linux on m51" yet.** The honest next step is the A71 device-tree merge + an m51 DT adapted from it, tested on a spare m51. A repo should be created only when the user says so after reading this verdict.

---

## 1. What "complete Linux natively" actually means

| Approach | What boots | Native? |
|---|---|---|
| **Native boot (postmarketOS/Nura, Mobian, Droidian, Ubuntu Touch)** | The phone's bootloader loads a Linux kernel + a full Linux rootfs (Alpine/Debian/Ubuntu). Android is gone (or kept only as a second boot entry). Real `systemd`, real package manager, real kernel drivers, no Android runtime in the way. | **Yes — this is the goal** |
| **Termux** | Android app; a Linux userland (Alpine-based `pkg`) running as an unprivileged Android app, on top of the Android kernel. No root, no unlocked bootloader needed. | No |
| **proot / chroot (UserLAnd, Linux Deploy, Andronix)** | A Linux distro userland in a container/chroot *inside* Android, sharing the Android kernel. | No |
| **VM (e.g. VM apps, QEMU on Android)** | Linux as a guest inside Android. Slow, no direct hardware access. | No |

The distinction matters because the hard part is **not** the userland — any ARM64 distro rootfs will run — it is the **kernel + bootloader + device tree + firmware** for that exact phone. Android's kernel is a heavily patched downstream fork (m51 runs Linux 4.14.190); a native Linux distro wants either a mainline kernel (drivers rewritten/upstreamed) or a Halium shim over the Android kernel (see §2).

## 2. The two real paths to native Linux on a phone

### 2a. Mainline kernel — postmarketOS / Nura, Mobian, DanctNIX

- **postmarketOS** (Alpine-based, `pmbootstrap` build tool) targets upstream/mainline kernels wherever possible. As of 2026 the project has renamed itself **Nura** (wiki moved to `wiki.nura.eco`, `nura.eco`); the old postmarketOS name still appears in packages (`linux-postmarketos-qcom-sm7150`, `pmbootstrap`).
- UIs: Phosh, Plasma Mobile, GNOME Mobile, Sxmo, etc. — 15+ interfaces, 210+ devices in the database, but quality varies enormously by device; the genuinely well-supported devices in 2026 are OnePlus 6/6T (SDM845), Pixel 3a, PinePhone/Librem 5, and a handful of others.
- **Mainline pros:** up-to-date kernel, no vendor kernel forever, long-term maintainable. **Cons:** every driver must be rewritten/upstreamed; sensors, camera, fingerprint and sometimes GPU/Wi-Fi lag or never arrive; VoLTE is a problem on both paths.
- The modern SM7150 flow is the template for what "native" looks like now (see §4): **U-Boot as a second-stage bootloader, chainloaded from the stock bootloader, providing a real EFI environment, with systemd-boot picking the kernel + device tree.** The kernel is then a normal EFI-booted Linux kernel, like on a PC.

### 2b. Halium / libhybris — Droidian, Ubuntu Touch (UBports), Sailfish OS

- **Halium** boots a minimal stripped-down Android (vendor + downstream kernel) underneath a real Linux distro. The Linux side talks to the manufacturer's proprietary drivers through **libhybris**: camera, GPS, modem etc. go through the mini-Android.
- **Droidian** = Debian/Mobian + Halium; **Ubuntu Touch** = Ubuntu + Lomiri + Halium (OTA 2.0 is Ubuntu 24.04 LTS based). Both need a working **LineageOS / Android device tree + kernel** as their base — so a phone with no LineageOS tree is a much harder Halium target, and a phone *with* one (a71, m51) is a feasible one.
- **Halium pros:** much better hardware support out of the gate (vendor blobs keep working), daily-drivable sooner. **Cons:** stuck on the downstream Android kernel forever (4.14 for m51), and on the vendor's Android version for the Halium base (Halium 10/11/12/13).

## 3. Samsung phones and native Linux — the general picture

- **Samsung is a hard vendor for this.** No fastboot — flashing is via **Heimdall / Odin in Download Mode**. Unlocking the bootloader **trips Knox permanently** (voids warranty, kills Samsung Pay / Secure Folder permanently). US/carrier Snapdragon Samsung phones have locked bootloaders and cannot be unlocked at all — do not buy one for this.
- **Samsung devices that do have mainline work** (device trees exist in the `sm7150-mainline/linux` tree and/or pmaports) are mostly old or flagship:
  - Old MSM8916: Galaxy A3/A5 (2015), E7, Grand Max — historically the best-supported Samsung family in postmarketOS.
  - **SDM845: Galaxy S9/S9+ (starqlte)** — Droidian officially supports the S9 (Qualcomm); postmarketOS has `sdm845-samsung-starqltechn`.
  - **SM8250: Galaxy S20 (r8q, x1q)** — device trees in mainline (`sm8250-samsung-common.dtsi`).
  - **SM8450: Galaxy S22 (r0q)** and **SM8550: Galaxy S23 (q5q)** — device trees in mainline.
  - **Exynos:** essentially no mainline path; Exynos Samsung phones are served only by Halium ports (e.g. Ubuntu Touch for S20+ Exynos, Note 10+ Exynos — old, often discontinued).
- **Samsung-specific gotchas found in real ports:** no fastboot (Heimdall only, and Droidian's generic `flash_all.sh` does not work on Samsung), the `dtbo` partition must be backed up and erased to boot mainline Linux (or Android will not boot again without restoring it), and on SM7150 the boot partition layout is special (see §4).
- **Ubuntu Touch on Samsung:** only a handful of community ports, most old/discontinued. The S20+ (Exynos 9830, y2s) has a maintainer building 24.04; the A50 has a community Halium-based Ubuntu Touch 26.04 port; the Note 10+ (Exynos 9825) port is stuck on 16.04 Xenial.

## 4. The SM7150 SoC — the good news

This is the strongest part of the story. The SM7150 is genuinely mainlined by a dedicated community, `sm7150-mainline` (GitHub org).

### 4.1 Kernel — `sm7150-mainline/linux`

- Fork of torvalds/linux, "WIP Mainline kernel for Qualcomm SM7150". Default branch **v7.2**, last pushed **2026-06-27**. 107 stars.
- Device trees present in the v7.2 tree (`arch/arm64/boot/dts/qcom/`), verified live 2026-11-23:
  - `sm7150-google-sunfish.dts` — Pixel 4a
  - `sm7150-xiaomi-davinci` (Mi 9T / Redmi K20), `-surya` (POCO X3 NFC), `-sweet` (Redmi Note 10 Pro), `-toco` (Mi Note 10 Lite), `-tucana` (Mi Note 10), plus `sm7150.dtsi` and `sm7150-xiaomi-common.dtsi`
  - **No Samsung device tree at all** — no `sm7150-samsung-a71.dts`, no `sm7150-samsung-m51.dts`, no A80.
- **SM7150 is not upstream in the mainline kernel yet** (as of the v7.3 cycle): a kernel-mailing-list thread (Oct 2026) notes "SM7150 support is not upstream yet; I am running v7.3 with the sm7150-mainline patches on top", and reports a v7.3 regression where SM7150 no longer boots (RPMh regulator readback). The v7.1-based tree boots fine. Treat the kernel as a moving, out-of-tree fork, not a stable upstream target.
- The pmaports kernel package is `linux-postmarketos-qcom-sm7150` (6.13.4 in the `sm7150-mainline/pmaports` fork, branch `generic`, last pushed 2025-03-04 — that fork is stale; the live kernel work is in `sm7150-mainline/linux`).

### 4.2 U-Boot / EFI — `sm7150-mainline/u-boot`

- U-Boot as a **second-stage bootloader**: the stock bootloader chainloads U-Boot (disguised as a Linux kernel in the `boot` partition); U-Boot then provides a real **EFI environment** and boots the kernel with **systemd-boot**, picking the right device-tree blob.
- New partition layout for SM7150 (from the March 2025 generic-port migration): `boot` = Android boot image containing U-Boot; `cache` (or another >256 MB non-firmware partition) = the boot/EFI partition with U-Boot, kernel and DTBs; `userdata` = rootfs. This layout is **incompatible** with the old layout — a fresh install is required, no migration.
- **U-Boot release 2025-12-02 (5th release), verified live:** supported devices are exactly 6 — Pixel 4a (sunfish), Mi 9T/K20 (davinci), Mi Note 10 (tucana), Mi Note 10 Lite (toco), POCO X3 NFC (surya), Redmi Note 10 Pro (sweet). **No Samsung device.**
- `deviceinfo` for the generic port (`device-qcom-sm7150`, `deviceinfo_format_version 0`): `deviceinfo_gpu_accelerated="true"`, `deviceinfo_flash_method="fastboot-bootpart"`, kernel partition = `cache`, system = `userdata`, `deviceinfo_generate_systemd_boot="true"`, `deviceinfo_boot_filesystem="fat32"`, `deviceinfo_rootfs_image_sector_size="4096"` (UFS). Note: `fastboot-bootpart` assumes fastboot — on a Samsung the flashing step has to be translated to Heimdall/Download Mode.

### 4.3 What actually works on SM7150 today (Xiaomi/Pixel)

From the Nura/postmarketOS wiki pages for the supported devices (e.g. Mi Note 10 Lite, `xiaomi-toco`, community tier, mainline: yes, kernel 7.1_rc3-1, generic port `qcom-sm7150`):
- Flashing, USB networking (telnet in initramfs / SSH in booted system), internal storage (UFS): **Works**
- U-Boot as secondary bootloader, mainline U-Boot: **Works**; primary-bootloader replacement: **Broken** (chainload only)
- Full-disk encryption: **Partial**
- The same pattern holds for the miatoll (SM7125, Redmi Note 9S) community port: Wi-Fi, cellular voice+data, audio, GPU, sensors work; fingerprint, NFC, hardware video decode broken; camera fixable.
- Expect the same shape on any new SM7150 device: display/USB/storage/Wi-Fi first, modem audio and camera later, fingerprint/NFC probably never.

## 5. Galaxy A71 — the nearest relative, and how close it is

- **A71 (SM-A715F, SM7150-AA Snapdragon 730, a71)** is the m51's sister device in the UN1CA/SM7150 world, and it has the strongest Linux foothold of any SM7150 Samsung:
  - **Device-tree PRs exist but are NOT merged:** `sm7150-mainline/linux#44` "Add support for Samsung Galaxy A71" — **open, unmerged**; `sm7150-mainline/u-boot#2` "Add device-tree for Samsung Galaxy A71" — **open, unmerged**, waiting on linux#44 (checked live 2026-11-23).
  - **Downstream FDT exists:** `sm7150-mainline/downstream-fdt` contains an FDT "found on sm7150 devices: Samsung A71 PROJECT Rev0.6 (SM-A715F)" — i.e. the stock downstream device tree, a usable starting point for writing the mainline DT, not a mainline DT itself.
  - **Announced as "coming soon" (April 2025, linmob weekly update 17/2025):** "our sm7150-mainline kernel (and therefore also U-Boot) currently supports [6 Xiaomi/Pixel devices] and will soon also support: Xiaomi Mi 11 Lite 4G, Redmi Note 12 Pro 4G, **Samsung Galaxy A71, Samsung Galaxy A80**". As of Nov 2026 that has not landed in the kernel tree or in a U-Boot release.
  - **Ubuntu Touch port for A71: discontinued, untested.** XDA thread "[CLOSED][DISCONTINUED] UBPORT / Ubuntu Touch Port for Samsung Galaxy A71" (BaoNamm, Aug 2025): Halium 10.x, image built but **not tested on an actual device**, needs a downgrade to OneUI 2.5 GSI, "no phone has the same SoC on Halium 11+", project closed. Do not treat it as a working port.
  - **Android base is excellent:** LineageOS officially supports a71 (maintainer Haky86), crDroid/evolution-X current — so a Halium base for a71 is available, unlike for many phones.

## 6. Galaxy M51 — the actual verdict

**No Linux port exists for the M51. Nothing to install, nothing to flash.**

Checked 2026-11-23:
- No postmarketOS/Nura wiki page for `samsung-m51` (wiki search: no results).
- No Droidian or Ubuntu Touch port found (search: no results).
- No `sm7150-samsung-m51` device tree in `sm7150-mainline/linux` v7.2, no m51 entry in `sm7150-mainline/u-boot` (no PR, no release entry), no m51 firmware package in the `sm7150-mainline` org, no m51 FDT in `downstream-fdt`.
- **What m51 *does* have, which makes a port conceivable:**
  - Same SoC as the supported devices (SM7150-AB Snapdragon 730G, Kryo 470, Adreno 618) and same SoC family as A71.
  - An unofficial but real Android base: **LineageOS 21 (Android 14, June 2024, `a71-devs`)** and **LineageOS 23.0/23.2 (Android 16, Dec 2025, unofficial beta)** for m51, built on `a71-devs/android_device_samsung_m51` + `a71-common` + `android_kernel_samsung_a71` (4.14.x) + vendor blobs. That is the Halium base a Droidian/Ubuntu Touch port would need.
  - Samsung's own kernel source for M515F (e.g. M515FXXU1ATH4) is published on GitHub.
  - Stock firmware: One UI 4.1 / Android 12, kernel 4.14.190, bootloader v6 (M515FXXS6DXE3, May 2024).
- **What m51 does *not* have, and would have to be created:** a mainline device tree (panel, touchscreen, battery/charging, USB, Wi-Fi/BT firmware paths, sensors — m51's panel, fingerprint (side-mounted, different from a71) and 7000 mAh battery/charging are all device-specific), a U-Boot board/DT entry, a firmware package (or proof that `msm-firmware-loader` can pull firmware from the Android partitions on this device, as it now does on Xiaomi SM7150), and anyone who has booted it.
- **Realistic effort:** Halium port (Droidian/UT) reusing the a71-devs LineageOS trees — a focused porting project, plausibly boot-to-UI in weeks with someone who knows Halium, with camera/modem as the long tail. Mainline postmarketOS port — start by getting the A71 DT merged, then adapt panel/touch/battery for m51; expect weeks–months of kernel work and a first boot that has display + USB + maybe Wi-Fi, not a daily driver.

## 7. What a native Linux boot needs (checklist for any Samsung)

1. **Unlockable bootloader** — international/unlocked Samsung only; US Snapdragon locked = impossible. Unlock trips Knox permanently.
2. **A kernel** — mainline (with the SoC's drivers upstreamed or in a fork like `sm7150-mainline/linux`) or downstream Android kernel (4.14 for m51) via Halium.
3. **A device tree** for the exact model — SoC `.dtsi` + per-device `.dts` (panel, touch, PMIC, charging, audio codec, sensors). This is the bulk of the work for a new device.
4. **A bootloader that can load it** — on SM7150: U-Boot as second stage, EFI + systemd-boot; on Samsung: chainloaded from the stock bootloader, flashed via Heimdall, `dtbo` backed up and erased.
5. **Firmware blobs** — Wi-Fi/BT (ath10k), modem, Adreno GPU, camera ISP. Either packaged (nonfree firmware repos per device) or loaded from the Android partitions by `msm-firmware-loader`.
6. **A rootfs + UI** — pmbootstrap (postmarketOS/Nura) or a Halium rootfs (Droidian/UT) + Phosh/Plasma Mobile/Lomiri.
7. **Per-feature bring-up, in order:** serial/USB networking → display → storage → Wi-Fi → audio → sensors → modem/calls → camera → fingerprint/NFC (often never).

## 8. Dual-boot / UEFI note (see also 04-uefi-dualboot.md)

- There is **no PC-style UEFI firmware** on a Samsung phone and no GRUB menu at power-on. The UEFI-like layer is **U-Boot's EFI implementation**, chainloaded as a second stage — that is the "UEFI kind of boot manager" for this hardware, and on SM7150 it already works (systemd-boot, EFI variables).
- Dual-boot (Android + Linux) is therefore **partition-based, not firmware-based**: keep Android's partitions, put the Linux boot/EFI partition on `cache` (or another spare >256 MB partition) and the Linux rootfs on `userdata`, and select the OS by which boot image U-Boot/systemd-boot loads — or, more simply and safely at first, boot Linux from a separate slot and keep a full stock-firmware backup + the `dtbo` backup so Android can be restored.
- Do not promise "dual-boot" until a single-boot Linux image boots on the device first.

## 9. Recommended path if the user says go

1. **Do not create the repo yet** — the user said he will decide after this verdict.
2. If he says go, the repo should be scoped **m51-first, SM7150-family second** (not "universal Samsung"): `m51-linux` with (a) the A71 DT work carried over and adapted, (b) a Halium/Droidian branch reusing `a71-devs` LineageOS trees as the fast path, (c) a mainline branch tracking `sm7150-mainline/linux`.
3. First milestone is not a distro — it is **a kernel that boots to a shell over USB networking** on a spare m51, using the A71 DT as the starting point.
4. Credits to carry into any repo: postmarketOS/Nura project + `sm7150-mainline` (Danila Tikhonov, David Wronek, Jens Reidel and contributors), U-Boot project, Halium/UBports/Droidian, `a71-devs` (Haky86 and the m51 LineageOS bring-up), LineageOS, and the A71 Ubuntu Touch attempt (BaoNamm).

## Sources (checked 2026-11-23)

- postmarketOS/Nura — https://postmarketos.org/ ; wiki https://wiki.postmarketos.org/wiki/Devices (now https://wiki.nura.eco/ ; Anubis-blocked direct fetch, search-indexed pages used)
- Nura wiki, Xiaomi Mi Note 10 Lite (xiaomi-toco, SM7150, community, mainline) — https://wiki.nura.eco/wiki/Xiaomi_Mi_Note_10_Lite_(xiaomi-toco)
- Nura, "Existing SM7150 device packages removed in favour of generic package" (2025-03-09) — https://nura.eco/edge/2025/03/09/sm7150-generic-migration/
- sm7150-mainline org — https://github.com/sm7150-mainline (linux, u-boot, pmaports, downstream-fdt, nightly-builds)
- sm7150-mainline/linux, branch v7.2, `arch/arm64/boot/dts/qcom/` — verified live via GitHub API 2026-11-23 (no Samsung DT)
- sm7150-mainline/linux PR #44 "Add support for Samsung Galaxy A71" — open, unmerged; sm7150-mainline/u-boot PR #2 "Add device-tree for Samsung Galaxy A71" — open, unmerged
- sm7150-mainline/u-boot release 2025-12-02 — https://github.com/sm7150-mainline/u-boot/releases/tag/2025-12-02 (6 devices, no Samsung)
- sm7150-mainline/downstream-fdt — https://github.com/sm7150-mainline/downstream-fdt/blob/HEAD/README.md (Samsung A71 FDT listed)
- sm7150-mainline/pmaports, branch `generic` — `device/community/device-qcom-sm7150/deviceinfo`, `device/community/linux-postmarketos-qcom-sm7150/APKBUILD` (kernel 6.13.4, last push 2025-03-04)
- linmob weekly update 17/2025 — https://linmob.net/weekly-update-17-2025/ (A71/A80 "will soon also support")
- Droidian supported devices — https://github.com/droidian-images/droidian/releases ; Droidian state, week 25 2023 (S9 starqlte) — https://droidian.org/blog/state-of-droidian-week-25-2023/
- Halium related projects — https://docs.halium.org/en/latest/project/Related-projects.html
- Ubuntu Touch for Galaxy A71, XDA (closed/discontinued, Halium 10, untested) — https://xdaforums.com/t/rom-a715f-port-dev-ubport-ubuntu-touch-port-for-samsung-galaxy-a71.4754085/
- LineageOS 21 for Galaxy M51 (unofficial, a71-devs, 2024-06-19) — https://xdaforums.com/t/rom-14-0-unofficial-stable-20240619-lineageos-21-for-samsung-galaxy-m51-ss-ds.4677735/
- LineageOS 23.0 for Galaxy M51 (unofficial beta, 2025-12-25) — https://xdaforums.com/t/rom-16-0-unofficial-beta-lineageos-23-0-for-samsung-galaxy-m51-m51.4773520/
- Termux vs postmarketOS explainer — https://www.bigiron.cc/guides/old-android-phone-as-a-server-termux-vs-postmarketos
- postmarketOS device support in 2026 — https://www.bigiron.cc/guides/postmarketos-device-support-in-2026-what-to-buy
- Samsung Galaxy Tab S7+ Droidian port (SM8250, Halium 11, Heimdall) — https://github.com/mukahraman/galaxy-tab-s7-plus-droidian/blob/HEAD/README.md
