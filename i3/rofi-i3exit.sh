#!/bin/bash

res=$(rofi -theme glue_pro_blue -font "JetBrains Mono Nerd Font Bold 14" -dmenu < ~/.config/i3/rofi-i3exit-options)

if [ "$res" = "lock" ]; then
    loginctl lock-session
fi

if [ "$res" = "logout" ]; then
    i3-msg exit
fi
if [ "$res" = "restart" ]; then
    systemctl reboot
fi
if [ "$res" = "shutdown" ]; then
    systemctl poweroff -i
fi

exit 0
