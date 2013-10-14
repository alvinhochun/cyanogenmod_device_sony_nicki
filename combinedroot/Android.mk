#
# This makefile is responsible for making the boot image which combines the
# boot ramdisk and recovery ramdisk together in a single ramdisk. It is required
# because the Xperia M does not have a dedicated recovery partition.
#

LOCAL_PATH := $(call my-dir)

# The directory to make the combined root filesystem
NICKI_COMBINED_ROOT_OUT := $(PRODUCT_OUT)/combinedroot/root

# The init file for the combined root filesystem

# The normal root ramdisk, can either be built or prebuilt
ifeq ($(strip $(NICKI_RAMDISK_PREBUILT)),)
NICKI_BOOT_RAMDISK := $(INSTALLED_RAMDISK_TARGET)
else
NICKI_BOOT_RAMDISK := $(NICKI_RAMDISK_PREBUILT)
endif

# The init executable source, can be overriden in BoardConfig.mk
ifeq ($(strip $(NICKI_COMBINED_ROOT_INIT_SRC)),)
NICKI_COMBINED_ROOT_INIT_SRC := $(LOCAL_PATH)/init.sh
endif

# The location of the static busybox
STATIC_BUSYBOX_BINARY := $(PRODUCT_OUT)/utilities/busybox

# Make the combined root filesystem, with the init executable
NICKI_COMBINED_ROOT_TS := $(PRODUCT_OUT)/combinedroot/timestamp

$(NICKI_COMBINED_ROOT_TS): $(NICKI_BOOT_RAMDISK) \
		$(recovery_ramdisk) \
		recoveryimage \
		$(NICKI_COMBINED_ROOT_INIT_SRC) \
		$(STATIC_BUSYBOX_BINARY)
	@echo -e ${CL_CYN}"----- Making combined root filesystem ------"${CL_RST}
	$(hide) mkdir -p $(NICKI_COMBINED_ROOT_OUT)
	$(hide) mkdir -p $(NICKI_COMBINED_ROOT_OUT)/sbin
	$(hide) cp -f $(STATIC_BUSYBOX_BINARY) $(NICKI_COMBINED_ROOT_OUT)/sbin/busybox
	$(hide) mkdir -p $(NICKI_COMBINED_ROOT_OUT)/boot
	$(hide) cp -f $(NICKI_BOOT_RAMDISK) $(NICKI_COMBINED_ROOT_OUT)/boot/boot.gz
	$(hide) cp -f $(recovery_ramdisk) $(NICKI_COMBINED_ROOT_OUT)/boot/recovery.gz
	$(hide) cp -f $(NICKI_COMBINED_ROOT_INIT_SRC) $(NICKI_COMBINED_ROOT_OUT)/init
	$(hide) chmod 755 $(NICKI_COMBINED_ROOT_OUT)/init
	$(hide) touch $@
	@echo -e ${CL_CYN}"----- Made combined root filesystem --------"$(NICKI_COMBINED_ROOT_OUT)${CL_RST}

# The combined ramdisk
NICKI_COMBINED_RAMDISK := $(PRODUCT_OUT)/ramdisk-combined.img

$(NICKI_COMBINED_RAMDISK): $(NICKI_COMBINED_ROOT_TS)
	$(call pretty,"Target combined ram disk: $@")
	$(hide) $(MKBOOTFS) $(NICKI_COMBINED_ROOT_OUT) | $(MINIGZIP) > $@

# The combined boot image

# == Arguments for making boot image ==
INTERNAL_COMBINEDIMAGE_ARGS := \
	$(addprefix --second ,$(INSTALLED_2NDBOOTLOADER_TARGET)) \
	--kernel $(INSTALLED_KERNEL_TARGET) \
	--ramdisk $(NICKI_COMBINED_RAMDISK)

BOARD_KERNEL_CMDLINE := $(strip $(BOARD_KERNEL_CMDLINE))
ifdef BOARD_KERNEL_CMDLINE
  INTERNAL_COMBINEDIMAGE_ARGS += --cmdline "$(BOARD_KERNEL_CMDLINE)"
endif

BOARD_KERNEL_BASE := $(strip $(BOARD_KERNEL_BASE))
ifdef BOARD_KERNEL_BASE
  INTERNAL_COMBINEDIMAGE_ARGS += --base $(BOARD_KERNEL_BASE)
endif

BOARD_KERNEL_PAGESIZE := $(strip $(BOARD_KERNEL_PAGESIZE))
ifdef BOARD_KERNEL_PAGESIZE
  INTERNAL_COMBINEDIMAGE_ARGS += --pagesize $(BOARD_KERNEL_PAGESIZE)
endif

NICKI_COMBINED_IMAGE := $(PRODUCT_OUT)/combined.img

$(NICKI_COMBINED_IMAGE): $(NICKI_COMBINED_RAMDISK) \
		$(INSTALLED_KERNEL_TARGET) \
		$(MKBOOTIMG)
	@echo -e ${CL_CYN}"----- Making combined boot image ------"${CL_RST}
	$(hide) $(MKBOOTIMG) $(INTERNAL_COMBINEDIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE),raw)
	@echo -e ${CL_CYN}"Made combined boot image: $@"${CL_RST}

# You know, the things
.PHONY: combinedramdisk
combinedramdisk: $(NICKI_COMBINED_RAMDISK)

.PHONY: combinedimage
combinedimage: $(NICKI_COMBINED_IMAGE)

