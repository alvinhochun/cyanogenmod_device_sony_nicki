#include <stdlib.h>

// The devices to init for Xperia M
const char *mr_init_devices[] = {
	// framebuffer device
	"/sys/class/graphics/fb0",

	// storage devices
	"/sys/dev/block*",
	"/sys/devices/platform/msm_sdcc.1*",
	"/sys/devices/platform/msm_sdcc.3*",
	"/sys/devices/platform/msm_hsusb_host*",
	"/sys/devices/virtual/misc/fuse",

	// input
	"/sys/class/misc/uinput",
	"/sys/class/input/input0",
	"/sys/class/input/input1",
	"/sys/class/input/input2",
	"/sys/class/input/event0",
	"/sys/class/input/event1",
	"/sys/class/input/event2",

	// adb
	"/sys/class/tty/ptmx",
	"/sys/class/misc/android_adb",
	"/sys/class/android_usb/android0/f_adb",

	NULL
};
