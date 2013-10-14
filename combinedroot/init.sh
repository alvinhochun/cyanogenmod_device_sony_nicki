#!/sbin/busybox sh
#
# Boot script to boot Android or recovery.
# This script is needed because the Xperia M does not have a partition
# for recovery.
#

# Function definitions
# klog: Logs to /boot.log and kmsg so the log can be seen by last_kmsg
log () {
	echo "$*" >> /boot.log
	[ -c /dev/kmsg ] && echo "init: $*" > /dev/kmsg
	[ -d /cache ] && echo "$*" >> /cache/combinedroot.log
}
# execl: Logs the executed command and its error code
execl () {
	log "execl: $*"
	$*
	log "execl: ret=$?"
}

# Device-specific function definitions
# led_<color>_<on|off>: Switch on/off an LED
led_red_on () {
	log "Switching on red LED"
	[ -f /sys/class/led/fih_led/control ] && echo "01 0 1" > /sys/class/led/fih_led/control
}
led_red_off () {
	log "Switching off red LED"
	[ -f /sys/class/led/fih_led/control ] && echo "01 0 0" > /sys/class/led/fih_led/control
}
led_green_on () {
	log "Switching on green LED"
	[ -f /sys/class/led/fih_led/control ] && echo "01 1 1" > /sys/class/led/fih_led/control
}
led_green_off () {
	log "Switching off green LED"
	[ -f /sys/class/led/fih_led/control ] && echo "01 1 0" > /sys/class/led/fih_led/control
}
led_blue_on () {
	log "Switching on blue LED"
	[ -f /sys/class/led/fih_led/control ] && echo "01 2 1" > /sys/class/led/fih_led/control
}
led_blue_off () {
	log "Switching off blue LED"
	[ -f /sys/class/led/fih_led/control ] && echo "01 2 0" > /sys/class/led/fih_led/control
}
# mount_cache: Mount /cache
mount_cache () {
	execl /boot/busybox mkdir -m 755 -p /dev/block
	execl /boot/busybox mknod -m 644 /dev/block/mmcblk0p26 b 179 26
	execl /boot/busybox mkdir -m 755 -p /cache
	execl /boot/busybox mount -t ext4 /dev/block/mmcblk0p26 /cache
}
# umount_cache: Unmount /cache
umount_cache () {
	execl /boot/busybox mount -o remount,ro /cache
	execl /boot/busybox umount /cache
	execl /boot/busybox rm -rf /cache
	execl /boot/busybox rm -f /dev/block/mmcblk0p26
}
# should_enter_recovery: Check and decide whether to enter recovery
#   returns: 0 if should enter recovery, 1 if not
should_enter_recovery () {
	# Checks the previous reboot request
	# On reboot some data will be stuffed to the hardware and the bootloader
	# will append it to the cmdline as "warmboot".
	# See kernel source arch/arm/mach-msm/restart_7k.c at msm_reboot_call
	#
	# 0x77665502 means "recovery"
	[ "`/boot/busybox sed 's/.* warmboot=0x77665502 .*/r/' /proc/cmdline`" = "r" ] && log "reboot says recovery" && return 0

	# Create the device used to get key input event
	execl /boot/busybox mkdir -m 755 -p /dev/input
	# device: fih_gpio-keys
	execl /boot/busybox mknod -m 644 /dev/input/event0 c 13 64

	# Asks user (detect Volume Up key press)
	# Write key events to /keyev.log
	/boot/busybox cat /dev/input/event0 > /keyev.log &

	# Pink LED indication
	led_red_on
	led_blue_on
	execl /boot/busybox sleep 1
	led_red_off
	led_blue_off

	# Kill the cat process (kill is shell builtin)
	execl kill $!

	# Checks if Volume Up is pressed
	/boot/busybox hexdump /keyev.log | /boot/busybox sed -n '/0001 0073 0001 0000$/p' > /keymatch.log
	if [ -s /keymatch.log ]; then
		log "User says recovery"
		execl /boot/busybox rm -f /keyev.log /keymatch.log
		return 0
	else
		execl /boot/busybox rm -f /keyev.log /keymatch.log
		return 1
	fi
}

# Sanity
cd /

# Relocate busybox for easy deletion, since some ramdisks contain /sbin/busybox
execl /sbin/busybox cp -f /sbin/busybox /boot/busybox
execl /boot/busybox rm -rf /sbin

# Set up necessary filesystems
execl /boot/busybox mkdir -m 755 -p /dev
# Logging to kmsg
execl /boot/busybox mknod -m 644 /dev/kmsg c 1 11
log "/dev/kmsg set up for logging"
execl /boot/busybox mknod -m 666 /dev/null c 1 3
execl /boot/busybox mkdir -m 755 -p /sys
execl /boot/busybox mount -t sysfs sysfs /sys
execl /boot/busybox mkdir -m 755 -p /proc
execl /boot/busybox mount -t proc proc /proc
mount_cache

log "Combined root boot script started at `/boot/busybox date`"

BOOTMODE="boot"

# Checks if the "/cache/recovery/boot" file exists
[ -f /cache/recovery/boot ] && BOOTMODE="recovery" && log "cache/recovery/boot says recovery" && execl /boot/busybox rm -f /cache/recovery/boot

should_enter_recovery && BOOTMODE="recovery"

# If booting recovery, light cyan LEDs
if [ $BOOTMODE == recovery ]; then
	log "Booting into recovery"
	led_green_on
	led_blue_on
fi

log "About to cleanup and boot..."

# Cleanup
umount_cache
execl /boot/busybox umount /proc
execl /boot/busybox rm -rf /proc
execl /boot/busybox umount /sys
execl /boot/busybox rm -rf /sys
execl /boot/busybox rm -rf /dev
execl /boot/busybox rm -f /init

# Extract ramdisks and delete them
execl /boot/busybox zcat /boot/$BOOTMODE.gz | /boot/busybox cpio -i
execl /boot/busybox rm -f /boot/boot.gz /boot/recovery.gz

# Hands over to the new /init and farewell
log "Handing over to new /init..."
execl exec /init

# Should never reach here...
# Try to reboot then.
log "Init doesn't run! FAIL"
execl /boot/busybox reboot &

