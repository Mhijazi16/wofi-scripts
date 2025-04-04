#!/bin/sh


monitors=("HDMI-A-1" "HDMI-A-2" "eDP-1" "eDP-2") 
SELECTED=$(printf "Monitor %s\n" "${monitors[@]}" | wofi --dmenu)
monitor=$(echo "$SELECTED" | cut -d ' ' -f2)

options=("🪖 Enable" "⛑️ Disable")
SELECTED=$(printf "%s\n" "${options[@]}" | wofi --dmenu)

if [[ "$SELECTED" == "${options[0]}" ]]; then
  hyprctl keyword monitor "$monitor",1920x1080@60,0x0,1
else
  hyprctl keyword monitor "$monitor",disable
fi
