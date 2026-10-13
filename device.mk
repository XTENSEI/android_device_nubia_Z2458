#
# Copyright (C) 2026 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/nubia/Z2458

# OrangeFox About page
OF_MAINTAINER := XTENSEI

# Enable Virtual A/B OTA
ENABLE_VIRTUAL_AB := true
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)

# Dynamic Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# A/B OTA postinstall (P671L parity)
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=erofs \
    POSTINSTALL_OPTIONAL_system=true

# OTA / fastbootd packages (P671L parity)
PRODUCT_PACKAGES += \
    otapreopt_script \
    cppreopts.sh \
    update_engine \
    update_verifier \
    update_engine_sideload

PRODUCT_PACKAGES_DEBUG += \
    update_engine_client

PRODUCT_PACKAGES += \
    libion.recovery \
    android.hardware.fastboot@1.0-impl-mock \
    android.hardware.fastboot@1.0-impl-mock.recovery \
    fastbootd

# Boot control HAL + health
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service \
    bootctrl.ums9230

# Security (AIDL NDK packages for keymint decrypt)
PRODUCT_PACKAGES += \
    android.hardware.security.secureclock-V1-ndk \
    android.hardware.security.sharedsecret-V1-ndk

# Gatekeeper (stock android.hardware.gatekeeper@1.0-service.trusty)
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper-V1-ndk

# Keymint (stock android.hardware.security.keymint@2.0-unisoc.service.trusty)
PRODUCT_PACKAGES += \
    android.hardware.security.keymint-V3-ndk

# Keystore2
PRODUCT_PACKAGES += \
    android.system.keystore2

# Trusty TEE libs (Unisoc secure world IPC)
PRODUCT_PACKAGES += \
    libkeymint \
    libtrusty \
    libgatekeeper
