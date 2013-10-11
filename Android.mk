LOCAL_PATH := $(call my-dir)

ifneq ($(filter nicki,$(TARGET_DEVICE)),)

include $(LOCAL_PATH)/combinedroot/Android.mk

endif

