# UEFI-style boot manager / dual-boot for Samsung — research + verdict

Date: 2026-11-23. Research only — no repo created, no code written, no device touched.
Scope: Samsung in general, Galaxy M51 (SM-M515F, Snapdragon 730G / SM7150) in particular.
Question from the user: can we have a UEFI-kind-of boot manager / dual-boot, and can a
complete Linux run natively on the phone? If yes, make a new GitHub repo for it
(universal Samsung, or at least m51).

## Short verdict

**Universal Samsung dual-boot / UEFI boot manager: NOT feasible.** There is no
UEFI in Samsung's boot chain, no GRUB, no ESP, and every historical project that
tried this is dead. Any boot manager is per-SoC and per-device work.

**For m51 specifically: feasible in principle, but a large new porting project,
not a config change.** The SoC-level pieces are moving in the right direction
(SM7150 mainline kernel work 2023–2025, U-Boot for SM7150 on Xiaomi devices),
but there is **no m51 port of anything** — no postmarketOS device page, no
lk2nd support, no EFIDroid port, no Ubuntu Touch / Droidian port. Expect months
of kernel + bootloader work and a test m51 in hand; it cannot be finished
purely in GitHub Actions, because the result must be booted on real hardware.

**What is feasible right now, cheaply:** Linux in a container/chroot on top of
Android (Termux/proot, Android Virtualization Framework) — runs today, no boot
manager needed. That is *not* native boot, see §6.

**Repo recommendation:** do not create a "universal Samsung dual-boot" repo —
the name would promise something that does not exist. If a repo is made at all,
make **one, m51-only, research-stage** repo (e.g. `m51-linux-boot`): U-Boot /
lk2nd port + mainline kernel device tree + postmarketOS port, with dual-boot
as a later milestone, not the first one.

---

## 1. How Samsung actually boots (why there is no UEFI/GRUB to hook into)

A PC boots: firmware (BIOS/UEFI) → reads an EFI System Partition → runs
`BOOTX64.EFI` / GRUB → kernel. A Samsung phone boots nothing like that:

```
BootROM (SoC ROM, verifies the next stage) → XBL/SBL (Qualcomm secondary
bootloader) → ABL (Samsung's application bootloader; Download Mode / Odin lives
here) → TrustZone / secure world → Android boot.img (kernel + ramdisk)
```

- There is **no UEFI firmware, no EFI System Partition, no GRUB**, and no
  standard boot-menu hook. Samsung's ABL is proprietary and signed; the chain
  of trust is BootROM → XBL → ABL → boot.img, each stage verifying the next.
  ("aboot is the first component which may opt to break the chain — and this is
  what is meant by boot loader unlocking" — newandroidbook.com, reverse
  engineering aboot.)
- Samsung has **no fastboot**. Flashing is via Download Mode with Odin /
  Heimdall. Any second-stage bootloader has to be *disguised as an Android
  boot image* and loaded by the stock bootloader — it cannot replace it.
- **Unlocking is the gate, and it is shrinking.** Unlocking (OEM unlocking in
  Developer options → unlock in Download mode) disables signature checks and
  wipes the phone. US Samsung models do not show the unlock option at all, and
  One UI 8 was found in 2025 to remove the OEM-unlock toggle. (thecustomrom.com
  unlock guide, checked Nov 2026.)
- **Knox trips permanently.** The moment anything custom boots, the Knox
  warranty e-fuse burns — irreversible, even if the bootloader is re-locked.
  Samsung Pay and Secure Folder stop working permanently; Play Integrity
  `MEETS_DEVICE_INTEGRITY` fails, so banking apps / tap-to-pay can break.
  Verified Boot moves to the ORANGE (unlocked) state.
- **A/B slots are not dual-boot.** Two ROMs cannot be dual-booted by putting
  one in slot A and one in slot B: they share userdata, and Verified Boot /
  vbmeta ties the slots together. Real dual-boot needs either a repartition
  (device-specific, can brick) or a patched boot image redirecting each ROM's
  data into separate folders. (thecustomrom.com, "Dual Boot Custom ROMs: Why
  A/B Slots Do Not Work", Nov 2026.)

Consequence: a "UEFI boot manager" on Samsung is never a drop-in GRUB. It is
always a **second-stage bootloader smuggled inside the boot partition**, and it
must be ported per SoC and per device (panel, storage, keys, display init).

---

## 2. The old dual-boot projects — all dead

| Project | What it was | Status | Samsung / m51 support |
|---|---|---|---|
| **EFIDroid** (m11kkaa, https://github.com/efidroid) | 2nd-stage bootloader on EDK2/UEFI, built on Qualcomm Little Kernel. Boot menu, multiboot slots, could chain-load GRUB. The closest thing to what was asked for. | **Dead.** Beta 0.1, Mar 2017. ARM64 rewrite never finished; "the old code probably wouldn't support Android 8.x and 9" (XDA, 2018). GitHub org: core repos last pushed 2018; a few infra repos touched 2021–2022, no device work since. | Samsung ports only: Galaxy S5 (klte) and Note 4 / Note Edge (trlte), both Snapdragon, both 2017. **No m51, no SM7150, no modern Samsung.** |
| **DualBootPatcher** (chenxiaolong, https://github.com/chenxiaolong/DualBootPatcher) | Patcher app + patched boot image; secondary ROMs in data slots. | **Discontinued.** Last upstream activity Aug 2018. "DualBootPatcher in general has been discontinued, so there will be no support for [Android 10]" (XDA, A5 2017 thread). | Device-specific builds only (S4, A5 2017, S9+ Snapdragon, …). **No m51.** |
| **MultiROM** (Tassadar) | kexec-hardboot based multiboot recovery + boot menu. | **Dead ~2017.** Broken by Android 8 "early mount" — "crashes MultiROM when they boot". | Old devices only (Nexus, Galaxy S3/Note 3 era). **No m51.** |
| **TWRP-MB / kexec-hardboot** (mkasic, various XDA ports) | Modded TWRP that kexec-boots ROM images from internal/external storage via loop devices. | **Dead, 2014–2017 era.** Per-device kernel patches (kexec-hardboot, hardboot-reserve) + a userspace loader. No maintainer, no Android 10+ support. | Note 8 (Exynos 4412), Galaxy S3, Note 3 Exynos. **No m51.** |

There is **no maintained, general-purpose dual-boot manager for Android in
2026**. If a dual-boot repo is started, it is starting from dead code, not
from a living upstream.

---

## 3. The modern pattern — lk2nd and U-Boot as second-stage bootloaders

This is the only live approach, and it is how mainline Linux gets onto
Qualcomm phones today.

### 3a. lk2nd — alive, but not for SM7150

- **What:** second-stage bootloader based on Qualcomm Little Kernel.
  Packed into an Android boot image, loaded by the stock bootloader as if it
  were a kernel. Gives the phone a real **fastboot interface** (which Samsung
  lacks), a **boot menu** (Volume keys), device detection, and booting of
  mainline kernels via `extlinux.conf` or a boot image in the boot partition.
  Source: https://github.com/msm8916-mainline/lk2nd
- **Status:** actively maintained — last push 2026-11-22 (checked live via
  GitHub API). ~80+ devices across MSM8916, MSM8952/8953, MSM8974, MSM8996…
- **Samsung devices in lk2nd:** Galaxy A3/A5 (2015), J5 (2016), J8, A6+,
  S4 Mini VE, Tab A — all 2015–2018, all old SoCs.
- **m51 / SM7150: NOT supported.** No SM7150 platform, no m51 device tree.
  Porting means: a new platform entry + an m51 device tree (model,
  `qcom,msm-id` / `qcom,board-id` from the downstream kernel, panel, keys,
  storage) + testing on hardware. lk2nd is the right *template* for an
  m51 boot manager; it is not a ready-made one.

### 3b. U-Boot as second-stage bootloader — the postmarketOS SM7150 route

- **What:** U-Boot disguised as a Linux kernel in the `boot` partition, with
  its own EFI implementation. It can then boot a kernel with **systemd-boot**,
  pick the right device tree, and boot from an EFI system partition.
- **Status for SM7150:** real and recent. In March 2025 postmarketOS/Nura
  switched its SM7150 devices to U-Boot as second-stage bootloader, with a
  **generic device package** — "as long as a device is supported by the
  SM7150 Linux kernel fork and U-Boot, it can boot postmarketOS with *no
  changes* needed in postmarketOS" (https://nura.eco/edge/2025/03/09/sm7150-generic-migration/).
  Layout after the switch: `boot` = Android boot image containing U-Boot;
  `cache` (or another >256 MB partition) = EFI system partition with U-Boot,
  kernel and DTBs; `userdata` = rootfs.
- **But:** the SM7150 devices in that migration are **Xiaomi** (davinci /
  Redmi K20, surya / Poco X3 NFC). **No Samsung device is in it, and m51 is
  not.** A standalone GitHub repo `pathpass2/sm7150-uboot` (created Aug 2025,
  pushed Nov 2025) exists, but it is a single small repo with no description —
  not an established project, do not treat it as a ready U-Boot port for m51.
- This is the most promising *architecture* for an m51 dual-boot: U-Boot in
  `boot`, EFI partition with two entries (UN1CA/Android and Linux), rootfs in
  `userdata`/SD. It still needs the m51 U-Boot port + device tree first.

---

## 4. Booting a complete Linux natively — the OS side

"Complete Linux natively" means: **mainline (or close-to-mainline) Linux
kernel + a GNU/Linux userspace** (Alpine/Debian/Ubuntu), booting directly —
not a chroot under Android. The options:

| OS | How it boots on phones | m51 status |
|---|---|---|
| **postmarketOS / Nura** (Alpine-based, pmbootstrap) | Mainline kernel where possible, downstream kernel otherwise. 210+ devices. | **No m51.** `wiki.nura.eco/wiki/Samsung_Galaxy_M51` returns **404** (checked live 2026-11-23). No `device-samsung-m51` in pmaports. SM7150 generic package covers Xiaomi only. |
| **Mobian** (Debian + Phosh) | Mainline kernel only. | No m51; mainline-only devices (Pixel 3a, OnePlus 6, Fairphone…). |
| **Ubuntu Touch** (UBports, Lomiri) | Halium/libhybris on top of the **Android vendor kernel** — Linux userspace, Android drivers. 111 devices listed; featured: Volla, Nothing Phone 1, Fairphone 4/5, Pixel 3a, OnePlus 6/6T, Poco X3 NFC. | **No m51.** Old Samsung S7 was supported historically; nothing current. |
| **Droidian** (Debian + Phosh) | Halium/libhybris, like Ubuntu Touch. | No m51 port. |
| **Sailfish OS** | Halium-based community ports. | No m51. |
| **Mainline kernel for SM7150** | The SoC itself is being mainlined: pinctrl (2023), gcc/camcc/dispcc/videocc (2024), rpmhpd, qfprom, UFS PHY, DisplayPort (2025) — all merged or in flight. Xiaomi mainline kernels exist (Mi 11 Lite 4G / courbet, Redmi Note 10 Pro / sweet, Pixel 4a). | SoC support is real and progressing, but **no Samsung m51 device tree exists in mainline**. Panel, side fingerprint, camera, modem, battery/charging, sensors are all per-device work still to be done. |

What breaks on a native-Linux m51 port (expect all of these at first):
camera (Samsung ISP, no mainline driver), modem / calls / VoLTE (Qualcomm
modem firmware + IMS), side-mounted fingerprint, Samsung-specific sensors,
GPU acceleration (Adreno 618 — freedreno is progressing on SM7150 but not
complete), battery/thermal, and anything Knox/Secure-Folder related (gone by
design). This is the normal shape of a first mainline port: boots, display,
USB, storage, Wi-Fi first; phone features much later, if ever.

---

## 5. The one shipping dual-boot — Volla (and why it does not transfer)

Volla Phone 22 / X23 / Quintus ships a real **multiboot**: Volla OS (AOSP)
as primary, with Ubuntu Touch / Sailfish / Droidian / Manjaro installable from
Volla OS settings onto a **microSD card**; a boot manager at startup lets you
pick. It works because Volla controls the hardware, ships an unlockable
bootloader, and built the boot manager into its own OS. Caveats from the
UBports forum: it only works if the phone came with Volla OS, and Volla OS 12
broke multiboot (working on 11.1).

**It does not transfer to Samsung.** There is no Volla boot manager for
Samsung hardware, no SD-card boot path in Samsung's ABL, and Samsung's
verified-boot chain would reject it. Volla is useful only as a *reference
design*: primary OS + second OS on separate storage + a boot menu in the
primary OS's bootloader stage.

---

## 6. What "Linux on the phone" can mean — don't confuse the three levels

1. **Linux under Android (works today, no boot work):** Termux, proot/chroot,
   Android Virtualization Framework. A full Debian/Ubuntu userspace runs as
   an app/container while Android still owns the hardware. Good for a pocket
   Linux terminal; it is **not** booting Linux, and Android apps/hardware
   stay in charge.
2. **Linux userspace on the Android kernel (Halium):** Ubuntu Touch / Droidian.
   Native-feeling Linux UI, but still the old vendor Android kernel underneath
   — no kernel updates, and it needs a per-device Halium port (none for m51).
3. **Native Linux (the real thing):** mainline kernel + GNU/Linux userspace,
   booted by lk2nd/U-Boot. This is §4. Nothing exists for m51 yet.

Samsung DeX is none of the above — it is Android with a desktop UI.

---

## 7. What exists for m51 today (the foundation any dual-boot would stand on)

- Bootloader **is unlockable** on the international SM-M515F (non-US, before
  One UI 8 removed the toggle). Unlock wipes the phone and trips Knox.
- **TWRP 3.5.1** exists for m51; unofficial **LineageOS 17.1 / 18.1 / 21**
  builds exist (EOL/unofficial). Known issues on those builds: VoLTE does not
  work, proximity sensor partial, SELinux permissive, FM radio — i.e. the
  device boots custom Android kernels, but Samsung-specific hardware is
  already fragile on AOSP, and would be worse on mainline Linux.
- UN1CA-SM7150 (the ROM this project builds) is itself proof that m51 boots
  a heavily modified One UI — the Android side of a dual-boot is solvable.
  The missing half is entirely the Linux/bootloader side.

---

## 8. Verdict, in the user's terms

### Universal Samsung dual-boot / UEFI repo?
**No. Do not make it.** There is no universal mechanism: no UEFI, no GRUB,
no common second-stage bootloader across Samsung SoCs (Qualcomm vs Exynos
vs older), and every historic attempt is dead. A repo named for universal
Samsung dual-boot would be a promise the code cannot keep. The honest
universal piece is only the *pattern* (second-stage bootloader in `boot` +
EFI entries + separate rootfs), and that pattern still needs a port per SoC
family — exactly like the UN1CA porter.

### At least for m51?
**Yes, as a research-stage project — but it is a big one.** The realistic
order of work:
1. **m51 device tree for the mainline SM7150 kernel** — panel, storage, USB,
   keys. Boots to a shell first; display later.
2. **Second-stage bootloader port** — U-Boot (following the Nura SM7150
   pattern) or lk2nd (following the msm8916-mainline pattern). This is the
   actual "boot manager": a menu at power-on choosing Android or Linux.
3. **postmarketOS/Nura port** for m51 on top of (1)+(2) — single-boot Linux
   first.
4. **Dual-boot only after (3) works:** keep UN1CA/Android in its partitions,
   Linux rootfs in `userdata` or SD, U-Boot/systemd-boot entries for both.
   Repartitioning the internal flash is the risky step; SD/microSD first if
   the bootloader supports it (m51 has a microSD slot — useful).

Needs: a test m51 device in hand (cannot be validated in GitHub Actions
alone), kernel/bootloader developers, and months — not a weekend. What breaks:
Knox (permanent), camera, modem/VoLTE, fingerprint, Play Integrity, Samsung
Pay/Secure Folder, and any warranty.

### What to do with the repo decision
- **Recommended:** one new repo, **m51-only, research-stage**, e.g.
  `m51-linux-boot` — scope: U-Boot/lk2nd port + mainline device tree +
  postmarketOS port, dual-boot as a later milestone. No "universal" in the
  name, no promises about other Samsung models.
- **Not recommended:** a second, separate "universal dual-boot" repo, and
  not a build repo that claims to produce a flashable dual-boot zip yet.
- **Zero-cost alternative, available today:** Linux under Android
  (Termux/proot) on the m51 running UN1CA — no repo, no flashing, no Knox
  risk beyond what UN1CA already trips.

---

## 9. Sources (checked 2026-11-23)

- Samsung boot chain / aboot: https://newandroidbook.com/Articles/aboot.html
- Android boot vs Linux, partitions, DTB: https://forum.xda-developers.com/android/general/info-boot-process-android-vs-linux-t3785254
- Bootloader unlock, Knox, One UI 8: https://thecustomrom.com/guides/unlock-bootloader
- Verified Boot, Knox e-fuse, ORANGE state: https://awakewiki.org/platform-abuse/verified-boot/
- EFIDroid (project, dead): https://github.com/efidroid — XDA threads https://xdaforums.com/t/efidroid-for-the-samsung-galaxy-note-4-note-edge-snapdragon-variants.3575300/ and https://xdaforums.com/t/unofficial-efidroid-for-samsung-galaxy-s5-qualcomm.3580980/page-3
- DualBootPatcher: https://github.com/chenxiaolong/DualBootPatcher — XDA https://xdaforums.com/t/unofficial-patcher-app-dualbootpatcher-for-galaxy-a5-2017-exynos.3896148/page-2
- A/B slots are not dual-boot: https://thecustomrom.com/guides/dual-boot-custom-rom
- lk2nd (alive): https://github.com/msm8916-mainline/lk2nd
- postmarketOS/Nura SM7150 U-Boot migration: https://nura.eco/edge/2025/03/09/sm7150-generic-migration/
- postmarketOS devices: https://wiki.postmarketos.org/wiki/Devices — m51 page 404 at https://wiki.nura.eco/wiki/Samsung_Galaxy_M51 (checked live)
- Linux on phones, Halium vs mainline: https://fabricio.prose.sh/linux-on-mobile-devices and https://linmob.net/resources/
- Ubuntu Touch devices: https://ubports.com/switch-to-ubuntu-touch (111 devices, no m51)
- Volla multiboot: https://forums.ubports.com/topic/8136/dual-boot-on-volla-22/10 and https://www.manual.nz/volla/phone-22/manual?p=6
- m51 custom ROMs (TWRP, LineageOS 17.1/18.1/21): https://forum.xda-developers.com/t/rom-11-0-oneui-3-1-unofficial-lineageos-18-1-for-samsung-m51.4252011/
- kexec-hardboot / TWRP multiboot (historical): https://xdaforums.com/t/dev-n5110-twrp-mb-multiboot-boot-roms-recovery-from-int-ext-flash-cards.2558783/

## 10. Open questions for the user (decide before any repo is created)

1. Is the goal **dual-boot Android + Linux on your own m51**, or a **reusable
   boot manager for many Samsungs**? The first is a real (if large) project;
   the second is not feasible — see verdict.
2. Do you have a **spare m51** to test on? A dual-boot port will brick-loop
   the test phone repeatedly; it must not be your daily phone.
3. Is losing **Knox / Samsung Pay / Secure Folder / Play Integrity** on that
   phone acceptable? It is permanent and unavoidable.
4. Would **Linux under Android (Termux/proot)** satisfy the "Linux on my
   phone" part for now, while the native port is researched? It needs no repo
   and no flashing.
