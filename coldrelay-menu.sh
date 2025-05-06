#!/bin/bash

declare -A services 

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
