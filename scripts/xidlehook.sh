#!/usr/bin/env bash

# Only exported variables can be used within the timer's command.
export PRIMARY_DISPLAY="$(xrandr | awk '/ primary/{print $1}')"

# Run xidlehook
xidlehook \
	`# Don't lock when there's a fullscreen application` \
	--not-when-fullscreen \
	`# Don't lock when there's audio playing` \
	--not-when-audio \
	`# Dim the keyboard after 10 seconds, undim if user becomes active` \
	--timer 10 \
	'/etc/nixos/scripts/save_kbd_brightness.sh' \
	'brightnessctl --device="asus::kbd_backlight" --restore' \
	`# Dim the screen after 120 seconds, undim if user becomes active`
# --timer 120 \
# 'brightnessctl --save; brightnessctl set 1%' \
# 'brightnessctl --restore' \
# `# Finally, suspend an hour after it locks` \
# --timer 3600 \
# 'systemctl suspend' \
# ''
