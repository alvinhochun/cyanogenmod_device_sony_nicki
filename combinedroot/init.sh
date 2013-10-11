#!/sbin/busybox sh
#
# Boot script to boot Android or recovery.
# This script is needed because the Xperia M does not have a partition
# for recovery.
#

# By the way, this is currently a dummy script. WIP.

# Reboots to bootloader (fastboot) so that people who mistakenly flashed this
# can easily reflash a proper boot image.
/sbin/busybox reboot bootloader

