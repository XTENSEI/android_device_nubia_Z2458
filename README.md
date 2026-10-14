# OrangeFox Tree For Nubia V70 Design (Z2458)

| | |
|---|---|
| Device | Nubia V70 Design, sold as ZTE Blade V70 Design |
| Model | Z2458, stock name `P606F17_2` |
| SoC | Unisoc T606, board `ums9230_6h10` |
| Display | 720 x 1600 |
| Android | 14, MyOS 14, kernel 5.15.151 |
| Recovery | vendor_boot, boot header v4, virtual A/B |

## Checks

`[X]` works, `[?]` untested, `[-]` does not work. Nothing is flashed yet, so every
line below is untested.

### Blocking checks

- [?] Correct screen/recovery size
- [?] Working touch, screen
- [?] Backup to internal/microSD
- [?] Restore from internal/microSD
- [?] Format data
- [?] Reboot to system
- [?] ADB
- [?] Decrypt `/data` with the PIN
- [?] Correct date
- [?] Battery level
- [?] Temperature

### Medium checks

- [?] update.zip sideload
- [?] Screen goes off and on
- [?] F2FS/EXT4, exFAT, NTFS
- [?] All important partitions in the mount/backup lists
- [?] microSD format and partition
- [?] Vibrator
- [?] Touch tap haptics
- [?] Input devices via USB-OTG, keyboard and mouse
- [?] USB mass storage export
- [?] MTP export

### Minor checks

- [?] Reboot to bootloader
- [?] Reboot to recovery
- [?] Poweroff
- [?] Fastbootd
- [?] Screenshot
- [?] Set brightness
- [?] Terminal and logcat
- [?] RNDIS
- [?] Flashlight

## Clone

    git clone -b fox-14.1 https://github.com/XTENSEI/android_device_nubia_Z2458 device/nubia/Z2458

## Build

Run the `OrangeFox Build` workflow from the Actions tab. It syncs fox-14.1, clones
this tree, applies everything under `patches/`, and uploads the vendor_boot image as
a release asset. `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` repository secrets add
the build notifications; it builds without them.

Locally, sync fox-14.1, clone the tree to `device/nubia/Z2458`, copy `patches/`
over the workspace the way the workflow does, then:

    export ALLOW_MISSING_DEPENDENCIES=true
    . build/envsetup.sh
    lunch twrp_Z2458-ap2a-eng
    mka adbd vendorbootimage

## Flash

Unlock the bootloader first, and keep the stock `vendor_boot` aside.

    fastboot flash vendor_boot vendor_boot.img
    fastboot reboot recovery

## Resources

- [OrangeFox](https://gitlab.com/OrangeFox) - the recovery this is built from
- [TeamWin Recovery Project](https://github.com/TeamWin) - minuitwrp GUI base
- [Android Open Source Project](https://github.com/aosp-mirror/platform) - the platform tree
- [Massatriof16](https://github.com/Massatriof16) - Unisoc UMS9230 reference trees and the
  [recovery builder workflow](https://github.com/Massatriof16/Action-Recovery-Builder) this CI forks
- [naden01](https://github.com/naden01) - TWRP device trees, the layout of this README
