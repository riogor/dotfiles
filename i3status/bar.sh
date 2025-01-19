#!/bin/sh

home="/home/riogor"
bg_bar="#282A36"
bg=$bg_bar
bg_prev=$bg

# Print a left caret separator
# @params {string} $1 text color, ex: "#FF0000"
# @params {string} $2 background color, ex: "#FF0000"
separator() {
	echo -n "{"
	echo -n "\"full_text\":\"\"," # CTRL+Ue0b2
	echo -n "\"separator\":false,"
	echo -n "\"separator_block_width\":0,"
	echo -n "\"border\":\"$bg_bar\","
	echo -n "\"border_left\":0,"
	echo -n "\"border_right\":0,"
	echo -n "\"border_top\":2,"
	echo -n "\"border_bottom\":2,"
	echo -n "\"color\":\"$1\","
	echo -n "\"background\":\"$2\""
	echo -n "}"
}

common() {
	echo -n "\"border\": \"$bg_bar\","
	echo -n "\"separator\":false,"
	echo -n "\"separator_block_width\":0,"
	echo -n "\"border_top\":2,"
	echo -n "\"border_bottom\":2,"
	echo -n "\"border_left\":0,"
	echo -n "\"border_right\":0"
}

wifi() {
	local str=$(iwconfig wlp2s0|awk '/Link Quality/{split($2,a,"=|/");print int((a[2]/a[3])*100)"%"}')
	local essid=$(iwgetid -r)

	if [ -z "${essid}" ]; then
		bg="#E53935"
	else
		bg="#1976D2"
	fi

	separator $bg $bg_prev

	echo -n ",{"
	echo -n "\"name\":\"id_wifi\","

	if [ -z "${essid}" ]; then
		echo -n "\"full_text\":\" no / connection \","
	else
		echo -n "\"full_text\":\" $str / $essid \","
	fi

	echo -n "\"background\":\"$bg\","

	common
	echo -n "},"

	bg_prev=$bg
}

disk() {
	local disk_usage=$(df --output=used,size -BM $1 | tr -dc '\n 0-9' | tail -n 1 | awk '{printf("%.1f", $1/$2 * 100.0)}')

	echo -n ",{"
	echo -n "\"name\":\"id_disk$1\","
	echo -n "\"full_text\":\"  $1:$disk_usage% \","
	echo -n "\"background\":\"$bg\","

	common

	echo -n "}"
}

memory() {
	local ram=$(free | grep Mem | awk '{printf("%.1f", $3/$2 * 100.0)}')

	echo -n ",{"
	echo -n "\"name\":\"id_memory\","
	echo -n "\"full_text\":\"  $ram%\","
	echo -n "\"background\":\"#3949AB\","

	common

	echo -n "}"
}

cpu() {
	local cpu=$(top -bn1 | grep "Cpu(s)" | \
			sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
			awk '{print 100 - $1""}'
	)

	echo -n ",{"
	echo -n "\"name\":\"id_cpu\","
	echo -n "\"full_text\":\"  $cpu% \","
	echo -n "\"background\":\"#3949AB\","

	common

	echo -n "},"
}

mydate() {
	local date_str=$(date "+%a %d/%m/%g %H:%M")

	bg="#E0E0E0"
	separator $bg $bg_prev

	echo -n ",{"
	echo -n "\"name\":\"id_date\","
	echo -n "\"full_text\":\"  $date_str \","
	echo -n "\"color\":\"#000000\","
	echo -n "\"background\":\"$bg\","

	common

	echo -n "},"

	bg_prev=$bg
}

battery0() {
	if [ ! -f /sys/class/power_supply/BAT0/uevent ]; then
		return 0
	fi

	prct=$(cat /sys/class/power_supply/BAT0/uevent | grep "POWER_SUPPLY_CAPACITY=" | cut -d'=' -f2)
	charging=$(cat /sys/class/power_supply/BAT0/uevent | grep "POWER_SUPPLY_STATUS" | cut -d'=' -f2) # POWER_SUPPLY_STATUS=Discharging|Charging
	icon="󰁹"
	if [ "$charging" == "Charging" ]; then
		icon="󰂄"
	fi

	bg="#FFBB33"
	local color="#000000"

	if (( prct < 10 )); then
		bg="#f00000"
		local color="#ffffff"
	fi

	separator $bg $bg_prev

	echo -n ",{"
	echo -n "\"name\":\"id_battery\","
	echo -n "\"full_text\":\" ${icon} ${prct}% \","
	echo -n "\"color\":\"$color\","
	echo -n "\"background\":\"$bg\","

	common

	echo -n "},"

	bg_prev=$bg
}

volume() {
	bg="#673AB7"
	if $(pamixer --get-mute); then
		bg="#f00000"
	fi

	vol=$(pamixer --get-volume)

	separator $bg $bg_prev

	echo -n ",{"
	echo -n "\"name\":\"id_volume\","
	if $(pamixer --get-mute); then
		echo -n "\"full_text\":\" 󰖁 ${vol}% \","
	else
		echo -n "\"full_text\":\" 󰕾 ${vol}% \","
	fi
	echo -n "\"background\":\"$bg\","

	common

	echo -n "},"

	bg_prev=$bg
}

logout() {
	bg=$bg_bar
	separator $bg $bg_prev

	echo -n ",{"
	echo -n "\"name\":\"id_logout\","
	echo -n "\"full_text\":\"  \""
	echo -n "}"
}

# https://github.com/i3/i3/blob/next/contrib/trivial-bar-script.sh
echo '{ "version": 1, "click_events":true }'     # Send the header so that i3bar knows we want to use JSON:
echo '['                    # Begin the endless array.
echo '[]'                   # We send an empty first array of blocks to make the loop simpler:

# Now send blocks with information forever:
(while :;
do
	bg=$bg_bar
	bg_prev=$bg

	echo -n ",["

	wifi
	bg_prev=$bg

	bg="#2E7D32"
	separator $bg $bg_prev
	disk "/home"
	disk "/mnt/shared"
	disk "/"
	bg_prev=$bg

	bg="#3949AB"
	echo -n ","
	separator $bg $bg_prev
	memory
	cpu
	bg_prev=$bg

	battery0

	volume

	mydate

	logout

	echo "]"
	sleep 5
done) &

# click events
while read line;
do
	# echo $line > /home/you/gitclones/github/i3/tmp.txt
	# {"name":"id_vpn","button":1,"modifiers":["Mod2"],"x":2982,"y":9,"relative_x":67,"relative_y":9,"width":95,"height":22}


	#WIFI
	if [[ $line == *"name"*"id_wifi"* ]]; then
		alacritty -e nmtui &

	#RAM
	elif [[ $line == *"name"*"id_memory"* ]]; then
		alacritty -e btop &

	# CPU
	elif [[ $line == *"name"*"id_cpu"* ]]; then
		alacritty -e btop &

	#VOLUME
	elif [[ $line == *"name"*"id_volume"* ]]; then
		pactl set-sink-mute @DEFAULT_SINK@ toggle

	# TIME
	elif [[ $line == *"name"*"id_date"* ]]; then
		alacritty -e $home/.config/i3status/click_time.sh &

	#LOGOUT
	elif [[ $line == *"name"*"id_logout"* ]]; then
		$home/.config/i3/rofi-i3exit.sh &

	fi
done
