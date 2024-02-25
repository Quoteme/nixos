#!/usr/bin/env bash

MIN_BATTERY=5
WARNING_TIMEOUT=60 # 60 seconds

# Function to get current battery level
get_battery_level() {
	upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | grep -o '[0-9]*'
}

# Function to check if the AC power is connected
is_ac_connected() {
	grep -q 'Charging' /sys/class/power_supply/BAT0/status
}

# Function to display warning
show_warning() {
	zenity --warning --text="Battery low: $BATTERY_LEVEL% remaining. The system will hibernate in one minute unless plugged in." --title="Low Battery Warning" --timeout=$WARNING_TIMEOUT
}

# Main loop
while true; do
	BATTERY_LEVEL=$(get_battery_level)

	if [ "$BATTERY_LEVEL" -le "$MIN_BATTERY" ]; then
		show_warning

		# Recheck battery level and AC status after timeout
		BATTERY_LEVEL=$(get_battery_level)
		if [ "$BATTERY_LEVEL" -le "$MIN_BATTERY" ] && ! is_ac_connected; then
			systemctl hibernate
		fi
	fi

	sleep 1m # Check every minute
done
