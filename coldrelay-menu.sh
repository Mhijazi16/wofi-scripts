#!/bin/bash

declare -A services 

services["🪓 Othamani Fronend"]="/home/ka1ser/othmani/furniture-agent/"
services["🧰 Othmani Backend"]="/home/ka1ser/othmani/VoiceAgent/"
services["⚒️ Reveno Tools"]="/home/ka1ser/reveno/reveno_tools/"
services["🪖 Reveno Engine"]="/home/ka1ser/reveno/Workflow-Engine-SDK/"
services["💴 Core Service"]="/home/ka1ser/coldrelay/core_service/"
services["💵 Subscription Service"]="/home/ka1ser/coldrelay/subscription_management_service/"
services["💷 Users Service"]="/home/ka1ser/coldrelay/user_management_service/"
services["💶 Frontend"]="/home/ka1ser/coldrelay/Frontend/"

SELECTED=$(printf "%s\n" "${!services[@]}" | wofi -n -d -p "Search > ")

[[ -z "$SELECTED" ]] && exit 1

cd "${services["$SELECTED"]}"
if [[ "$SELECTED" == "💶 Frontend" ]]; then
   kitty npm run dev
else
  kitty 
fi
