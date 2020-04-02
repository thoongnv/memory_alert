#!/usr/bin/env bash
# Alert on high memory usage. Copyright (c) 2018, thoong
# Usage
	# - ./memory_alert.sh INTERVAL LEFT_MEMORY(Mb)
	# - ./memory_alert.sh 3 1024

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus

INTERVAL=${1:-3}
LEFT_MEMORY=${2:-512}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
WARNING_ICON_PATH="$SCRIPT_DIR/warning.png"

get_left_memory() {
	# get available memory
	echo `free -m | awk 'FNR == 2 {print $7}'`
}

send_notification() {
	# send gnome notification
	[ -z $REMAIN_MEMORY ] && message="HIGH MEMORY USAGE!" || message="HIGH MEMORY USAGE! REMAIN: $REMAIN_MEMORY(MB)"
	[ -f "$WARNING_ICON_PATH" ] && /usr/bin/notify-send -i $WARNING_ICON_PATH "$message" || /usr/bin/notify-send "$message"
}

main() {
	# loop to monitor after an interal
	while true;
	do
		available_mem=$(get_left_memory)
		if [ $available_mem -le $LEFT_MEMORY ]
		then
			REMAIN_MEMORY=($available_mem - $LEFT_MEMORY)
			# send alert
			send_notification
		fi
		sleep $INTERVAL
	done
}

main
