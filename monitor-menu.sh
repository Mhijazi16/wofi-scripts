#!/bin/sh

monitors=("HDMI-A-1" "HDMI-A-2" "eDP-1" "eDP-2") 
SELECTED=$(printf "Monitor %s\n" "${monitors[@]}" | wofi --dmenu -p "Select Monitor:")
monitor=$(echo "$SELECTED" | cut -d ' ' -f2)

options=("🪖 Enable" "⛑️ Disable")
SELECTED=$(printf "%s\n" "${options[@]}" | wofi --dmenu -p "Action:")

if [[ "$SELECTED" == "${options[0]}" ]]; then
  hyprctl dispatch dpms on "$monitor"
  notify-send "💻 $monitor enabled"
else
  hyprctl dispatch dpms off "$monitor"
  notify-send "💤 $monitor disabled"
fi
