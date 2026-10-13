#
# Copyright (C) 2026 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/nubia/Z2458

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common TWRP stuff.
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit from Z2458 device
$(call inherit-product, device/nubia/Z2458/device.mk)

PRODUCT_DEVICE := Z2458
PRODUCT_NAME := twrp_Z2458
PRODUCT_BRAND := nubia
PRODUCT_MODEL := Z2458
PRODUCT_MANUFACTURER := nubia

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="P606F17_2-user 14 UP1A.231005.007 20241210.102244 release-keys"

BUILD_FINGERPRINT := nubia/P606F17_2/P606F17:14/UP1A.231005.007/20241210.102244:user/release-keys
