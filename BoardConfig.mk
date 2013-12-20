USE_CAMERA_STUB := true

# inherit from the proprietary version
-include vendor/sony/nicki/BoardConfigVendor.mk

TARGET_ARCH := arm
TARGET_NO_BOOTLOADER := true
TARGET_BOARD_PLATFORM := msm8960
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := krait
TARGET_ARCH_VARIANT := armv7-a-neon
ARCH_ARM_HAVE_TLS_REGISTER := true

#TARGET_BOOTLOADER_BOARD_NAME := nicki
TARGET_BOOTLOADER_BOARD_NAME := qcom

BOARD_KERNEL_CMDLINE := panic=3 console=ttyHSL0,115200,n8 androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x3F ehci-hcd.park=3
BOARD_KERNEL_BASE := 0x80200000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_MKBOOTIMG_ARGS := --ramdisk_offset 0x02000000

# fix this up by examining /proc/mtd on a running device
BOARD_BOOTIMAGE_PARTITION_SIZE := 0x01400000
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 0x01400000
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 1258291200   # 0x4B000000
BOARD_USERDATAIMAGE_PARTITION_SIZE := 2235547136 # 0x853FBE00
BOARD_FLASH_BLOCK_SIZE := 2097152

TARGET_PREBUILT_KERNEL := device/sony/nicki/kernel
TARGET_KERNEL_SOURCE := kernel/sony/nicki
TARGET_KERNEL_CONFIG := proj_S3A_user_alvin_defconfig

BOARD_HAS_NO_SELECT_BUTTON := true

NICKI_RAMDISK_PREBUILT := device/sony/nicki/stock-boot-ramdisk.gz
NICKI_COMBINED_INIT_LOGO := device/sony/nicki/logo.rle

TARGET_RECOVERY_FSTAB = device/sony/nicki/fstab.qcom

TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"
BOARD_CUSTOM_RECOVERY_KEYMAPPING := ../../device/sony/nicki/recovery/recovery_keys.c
BOARD_CUSTOM_GRAPHICS := ../../../device/sony/nicki/recovery/graphics.c
RECOVERY_NAME := Xperia M/M Dual CWM-based Recovery
TARGET_RECOVERY_INITRC := device/sony/nicki/recovery/init.rc
BOARD_RECOVERY_HANDLES_MOUNT := true
