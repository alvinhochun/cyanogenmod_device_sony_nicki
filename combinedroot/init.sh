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

# Sanity
cd /

# Relocate busybox for easy deletion
execl /sbin/busybox cp -f /sbin/busybox /boot/busybox
execl /boot/busybox rm -rf /sbin

# Set up necessary filesystems
execl /boot/busybox mkdir -m 755 -p /dev
# Logging to kmsg
execl /boot/busybox mknod -m 644 /dev/kmsg c 1 11
log "/dev/kmsg set up for logging"
execl /boot/busybox mknod -m 666 /dev/null c 1 3
execl /boot/busybox mkdir -m 755 -p /dev/block
execl /boot/busybox mknod -m 644 /dev/block/mmcblk0p26 b 179 26
execl /boot/busybox mkdir -m 755 -p /dev/input
# Used to check volume up key (device name: fih_gpio-keys)
execl /boot/busybox mknod -m 644 /dev/input/event0 c 13 64
execl /boot/busybox mkdir -m 755 -p /sys
execl /boot/busybox mount -t sysfs sysfs /sys
execl /boot/busybox mkdir -m 755 -p /proc
execl /boot/busybox mount -t proc proc /proc
execl /boot/busybox mkdir -m 755 -p /cache
execl /boot/busybox mount -t ext4 /dev/block/mmcblk0p26 /cache

log "Combined root boot script started at `/boot/busybox date`"

BOOTMODE="boot"

# Checks kernel cmdline. When reboot with command "recovery", some data will be
# stuffed to the hardware and the bootloader will append it to the cmdline as
# the command "warmboot".
# See kernel source arch/arm/mach-msm/restart_7k.c at msm_reboot_call
#
# 0x77665502 means "recovery"
[ "`/boot/busybox sed 's/.* warmboot=0x77665502 .*/r/' /proc/cmdline`" == "r" ] && BOOTMODE="recovery" && log "reboot says recovery"

# Checks if the "/cache/recovery/boot" file exists
[ -f /cache/recovery/boot ] && BOOTMODE="recovery" && log "cache/recovery/boot says recovery"

# Still asks user (whatever)
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

# Checks if volume up is pressed
/boot/busybox hexdump /keyev.log | /boot/busybox sed -n '/0001 0073 0001 0000$/p' > /keymatch.log
[ -s /keymatch.log ] && BOOTMODE="recovery" && log "User says recovery"

execl /boot/busybox rm -f /keyev.log
execl /boot/busybox rm -f /keymatch.log

# If booting recovery, light cyan LEDs
if [ $BOOTMODE == recovery ]; then
	log "Booting into recovery"
	led_green_on
	led_blue_on
fi

log "About to cleanup and boot..."

# Cleanup
execl /boot/busybox mount -o remount,ro /cache
execl /boot/busybox umount /cache
execl /boot/busybox rm -rf /cache
execl /boot/busybox umount /proc
execl /boot/busybox rm -rf /proc
execl /boot/busybox umount /sys
execl /boot/busybox rm -rf /sys
execl /boot/busybox rm -rf /dev
execl /boot/busybox rm -f /init

# Extract ramdisk and delete the remaining things
execl /boot/busybox zcat /boot/$BOOTMODE.gz | /boot/busybox cpio -i
execl /boot/busybox rm -rf /boot/boot.gz
execl /boot/busybox rm -f /boot/recovery.gz
execl /boot/busybox rm -f /boot/busybox
execl /boot/busybox rmdir /boot

# Hands over to the new /init and farewell
log "Handing over to new /init..."
execl exec /init

# Should never reach here...

# It seems that after busybox sleep is executed, the device cannot reboot
# normally with busybox reboot. So leave it alone and hope it will be ok.
log "Init doesn't run! FAIL"

