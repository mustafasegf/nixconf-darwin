#!/usr/bin/env bash

# Rofi power menu for Qtile

lock="    Lock"
logout="    Logout"
shutdown="    Shutdown"
reboot="    Reboot"
sleep_opt="   Sleep"

selected_option=$(echo "$lock
$logout
$sleep_opt
$reboot
$shutdown" | rofi -dmenu -i -p "Power" \
	-font "Symbols Nerd Font 12" \
	-width "15" \
	-lines 4 -line-margin 3 -line-padding 10 -scrollbar-width "0")

if [ "$selected_option" == "$lock" ]; then
	loginctl lock-session
elif [ "$selected_option" == "$logout" ]; then
	qtile cmd-obj -o cmd -f shutdown
elif [ "$selected_option" == "$shutdown" ]; then
	systemctl poweroff
elif [ "$selected_option" == "$reboot" ]; then
	systemctl reboot
elif [ "$selected_option" == "$sleep_opt" ]; then
	systemctl suspend
fi
