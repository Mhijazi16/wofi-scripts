#!/bin/bash

declare -A scripts

scripts["🍶 Push Infra Image"]="cd /home/ka1ser/coldrelay/infra_service/ && push-img"

SELECTED=$(printf "%s\n" "${!scripts[@]}" | wofi -d)

if [[ -n "$SELECTED" ]]; then
  CMD="${scripts[$SELECTED]}"
  result=$(eval "$CMD")
  notify-send "$SELECTED" "$result"
fi
