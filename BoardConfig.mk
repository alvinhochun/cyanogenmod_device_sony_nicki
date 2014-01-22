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
TARGET_USERIMAGES_USE_EXT4 := true

TARGET_PREBUILT_KERNEL := device/sony/nicki/kernel
TARGET_KERNEL_SOURCE := kernel/sony/nicki
TARGET_KERNEL_CONFIG := proj_S3A_user_alvin_defconfig

BOARD_HAS_NO_SELECT_BUTTON := true

NICKI_RAMDISK_PREBUILT := device/sony/nicki/stock-boot-ramdisk.gz
NICKI_COMBINED_INIT_LOGO := device/sony/nicki/logo.rle

TARGET_RECOVERY_FSTAB = device/sony/nicki/recovery/twrp.fstab

TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"
TW_BOARD_CUSTOM_GRAPHICS := ../../../device/sony/nicki/recovery/twrp_graphics.c
TARGET_RECOVERY_INITRC := device/sony/nicki/recovery/init.rc

DEVICE_RESOLUTION := 480x854

# /data/media
RECOVERY_SDCARD_ON_DATA := true

TW_EXTERNAL_STORAGE_PATH := "/external_sd"
TW_EXTERNAL_STORAGE_MOUNT_POINT := "external_sd"

TW_HAS_NO_RECOVERY_PARTITION := true
TW_INCLUDE_JB_CRYPTO := true

TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_MAX_BRIGHTNESS := 255

BOARD_UMS_LUNFILE := "/sys/class/android_usb/f_mass_storage/lun/file"

# MultiROM
MR_DPI := hdpi
MR_KEXEC_MEM_MIN := 0x85000000
MR_KEXEC_MEM_MAX := 0x87ffffff
MR_INIT_DEVICES := device/sony/nicki/multirom/init_devices.c

MR_PRODUCT_DEVICE := nicki

MR_SDCARD_BLOCK_DEV := mmcblk1
MR_SDCARD_PART_PREFIX := mmcblk1p
MR_USBDISK_BLOCK_DEV := sda
MR_USBDISK_PART_PREFIX := sda

