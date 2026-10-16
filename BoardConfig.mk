#
# Copyright (C) 2026 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/nubia/Z2458
# For building with minimal manifest
ALLOW_MISSING_DEPENDENCIES := true

# Build hacks
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

# A/B
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    init_boot \
    vendor_boot \
    dtbo \
    system \
    system_ext \
    product \
    vendor \
    odm \
    system_dlkm \
    vendor_dlkm \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor \
    vbmeta_odm \
    vbmeta_system_ext

TARGET_SCREEN_HEIGHT := 1600
TARGET_SCREEN_WIDTH := 720

# vendor_boot configuration
TARGET_NO_RECOVERY := true
BOARD_BOOT_HEADER_VERSION := 4
BOARD_USES_GENERIC_KERNEL_IMAGE := true
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true
BOARD_RAMDISK_USE_LZ4 := true

# Assert
TARGET_OTA_ASSERT_DEVICE := Z2458

# Platform
TARGET_BOARD_PLATFORM := ums9230
BOARD_USES_SPRD_HARDWARE := true

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a75

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv7-a-neon
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a55

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := Z2458
TARGET_NO_BOOTLOADER := true

# Display
TARGET_SCREEN_DENSITY := 320

# Touch + trusty stack - loader only insmods whitelisted modules
TW_LOAD_VENDOR_MODULES := "zte_tpd.ko trusty-tui.ko ion_ipc_trusty.ko lcd_state_notify.ko"
# Load from recovery ramdisk, not vendor_dlkm
TW_LOAD_VENDOR_BOOT_MODULES := true
BOARD_KERNEL_SEPARATED_DTBO := true

# Kernel / vendor_boot
TARGET_NO_KERNEL := true
BOARD_VENDOR_BASE := 0x00000000
BOARD_VENDOR_CMDLINE := 'console=ttyS1,115200n8 bootconfig bootconfig'
BOARD_VENDOR_BOOTCONFIG := $(DEVICE_PATH)/bootconfig
BOARD_PAGE_SIZE := 4096
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x05400000
BOARD_TAGS_OFFSET := 0x00000100
BOARD_HEADER_SIZE := 2128
TARGET_PREBUILT_DTB := $(DEVICE_PATH)/prebuilt/dtb.img
BOARD_DTB_SIZE := 147784
BOARD_DTB_OFFSET := 0x01f00000
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --base $(BOARD_VENDOR_BASE)
BOARD_MKBOOTIMG_ARGS += --vendor_cmdline $(BOARD_VENDOR_CMDLINE)
BOARD_MKBOOTIMG_ARGS += --pagesize $(BOARD_PAGE_SIZE) --board ""
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --kernel_offset $(BOARD_KERNEL_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --dtb $(TARGET_PREBUILT_DTB)
BOARD_MKBOOTIMG_ARGS += --dtb_offset $(BOARD_DTB_OFFSET)
BOARD_MKBOOTIMG_ARGS += --vendor_bootconfig $(BOARD_VENDOR_BOOTCONFIG)

# Partitions
BOARD_SYSTEMIMAGE_PARTITION_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_FLASH_BLOCK_SIZE := 262144
BOARD_HAS_LARGE_FILESYSTEM := true
TARGET_COPY_OUT_VENDOR := vendor
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 104857600

BOARD_SUPER_PARTITION_SIZE := 6510608384
BOARD_SUPER_PARTITION_GROUPS := group_unisoc_a
BOARD_GROUP_UNISOC_A_PARTITION_LIST := system system_ext product vendor odm vendor_dlkm system_dlkm
BOARD_GROUP_UNISOC_A_SIZE := 6505365504

TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery.fstab
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop

# Verified Boot
BOARD_AVB_ENABLE := true
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --set_hashtree_disabled_flag
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 4

BOARD_SUPPRESS_SECURE_ERASE := true

# Anti-rollback
PLATFORM_SECURITY_PATCH := 2099-12-31
VENDOR_SECURITY_PATCH := 2099-12-31
PLATFORM_VERSION := 14.0.0
PLATFORM_VERSION_LAST_STABLE := $(PLATFORM_VERSION)

# Sign vendor_boot with avb test key
BOARD_AVB_VENDOR_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_VENDOR_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_VENDOR_BOOT_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VENDOR_BOOT_ROLLBACK_INDEX_LOCATION := 1

# TWRP configuration
TW_INCLUDE_FASTBOOTD := true
TW_THEME := portrait_hdpi
TW_NO_SCREEN_BLANK_ON_BOOT := true
TW_NO_SCREEN_TIMEOUT := true
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_USE_TOOLBOX := true
TW_INCLUDE_REPACKTOOLS := true
TW_EXCLUDE_APEX := true
TW_EXCLUDE_DEFAULT_USB_INIT := true
TARGET_USES_LOGD := true
TWRP_INCLUDE_LOGCAT := true
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_LIBRESETPROP := true
TW_INCLUDE_LPTOOLS := true
TW_INCLUDE_AVBCTL := true
TW_INCLUDE_ZSTD := true
TW_BRIGHTNESS_PATH := "/sys/class/backlight/sprd_backlight/brightness"
TW_MAX_BRIGHTNESS := 255
TW_DEFAULT_BRIGHTNESS := 200

# No timed_output vibrator, evdev FF device only (re-verify on device)
TW_USE_FF_VIBRATOR := true

# Status bar icons off the punch-hole camera (kl4 values, re-check at 720x1600)
TW_CUSTOM_CPU_POS := "300"
TW_CUSTOM_CLOCK_POS := "70"
TW_CUSTOM_BATTERY_POS := "790"

# Crypto on: stock keymint AIDL V2 (keymint@2.0-unisoc.service.trusty), HIDL gatekeeper 1.0
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
BOARD_USES_METADATA_PARTITION := true
TW_USE_FSCRYPT_POLICY := 2
TW_FORCE_KEYMASTER_VER := true
OF_DEFAULT_KEYMASTER_VERSION := 2
TW_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES += \
    $(TARGET_OUT_SHARED_LIBRARIES)/android.hardware.gatekeeper@1.0 \
    $(TARGET_OUT_SHARED_LIBRARIES)/android.hardware.gatekeeper-V1-ndk \
    $(TARGET_OUT_SHARED_LIBRARIES)/android.hardware.security.keymint-V2-ndk \
    $(TARGET_OUT_SHARED_LIBRARIES)/android.hardware.security.keymint-V3-ndk \
    $(TARGET_OUT_SHARED_LIBRARIES)/android.hardware.security.secureclock-V1-ndk \
    $(TARGET_OUT_SHARED_LIBRARIES)/android.hardware.security.sharedsecret-V1-ndk \
    $(TARGET_OUT_SHARED_LIBRARIES)/android.system.keystore2-V4-ndk \
    $(TARGET_OUT_SHARED_LIBRARIES)/lib_android_keymaster_keymint_utils \
    $(TARGET_OUT_SHARED_LIBRARIES)/libcppbor_external \
    $(TARGET_OUT_SHARED_LIBRARIES)/libcppcose_rkp \
    $(TARGET_OUT_SHARED_LIBRARIES)/libgatekeeper \
    $(TARGET_OUT_SHARED_LIBRARIES)/libkeymaster_messages \
    $(TARGET_OUT_SHARED_LIBRARIES)/libkeymaster_portable \
    $(TARGET_OUT_SHARED_LIBRARIES)/libkeymint \
    $(TARGET_OUT_SHARED_LIBRARIES)/libpuresoftkeymasterdevice \
    $(TARGET_OUT_SHARED_LIBRARIES)/libsoft_attestation_cert \
    $(TARGET_OUT_SHARED_LIBRARIES)/libtrusty \
    $(TARGET_OUT_SHARED_LIBRARIES)/libtrustyHalHelper \
    $(TARGET_OUT_SHARED_LIBRARIES)/vendor.sprd.hardware.trusty-V1-ndk \
    $(TARGET_OUT_SHARED_LIBRARIES)/vendor.sprd.hardware.trusty@1.0
