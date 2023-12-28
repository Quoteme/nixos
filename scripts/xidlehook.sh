#!/usr/bin/env bash

# Only exported variables can be used within the timer's command.
export PRIMARY_DISPLAY="$(xrandr | awk '/ primary/{print $1}')"

# 'cat /sys/devices/pci0000:00/0000:00:08.1/0000:08:00.3/usb1/1-3/1-3:1.0/0003:0B05:19B6.0001/leds/asus::kbd_backlight/brightness > /tmp/savedKeyboadBacklight; echo 0 > /sys/devices/pci0000:00/0000:00:08.1/0000:08:00.3/usb1/1-3/1-3:1.0/0003:0B05:19B6.0001/leds/asus::kbd_backlight/brightness' \
# 'cat /tmp/savedKeyboadBacklight > /sys/devices/pci0000:00/0000:00:08.1/0000:08:00.3/usb1/1-3/1-3:1.0/0003:0B05:19B6.0001/leds/asus::kbd_backlight/brightness' \

# Run xidlehook
xidlehook \
	`# Don't lock when there's a fullscreen application` \
	--not-when-fullscreen \
	`# Don't lock when there's audio playing` \
	--not-when-audio \
	`# Dim the keyboard after 10 seconds, undim if user becomes active` \
	--timer 10 \
	'brightnessctl --device="asus::kbd_backlight" --save; brightnessctl --device="asus::kbd_backlight" set 0' \
	'brightnessctl --device="asus::kbd_backlight" --restore' \
	`# Dim the screen after 120 seconds, undim if user becomes active` \
	--timer 120 \
	'brightnessctl --save; brightnessctl set 1%' \
	'brightnessctl --restore' \
	`# Finally, suspend an hour after it locks` \
	--timer 3600 \
	'systemctl suspend' \
	''
