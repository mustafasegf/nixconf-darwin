#!/usr/bin/env bash

if [[ "$1" == "up" ]]; then
	brightnessctl -q set 25+
elif [[ "$1" == "down" ]]; then
	brightnessctl -q set 25-
fi

brightness="$(brightnessctl get)"
notify-send "Brightness" "$brightness" -i "multimedia-volume-control"
