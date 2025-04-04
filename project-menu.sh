#!/bin/bash

declare -A projects
projects["🧊 ColdRelay Core"]="/home/ka1ser/coldrelay/core_service/"
projects["🥝 Infra Deployer"]="/home/ka1ser/coldrelay/infra_service/"
projects["🫐 Hyprland Dotfiles"]="/home/ka1ser/.config/hypr/default/"
projects["🌵 Wofi Scripts"]="/home/ka1ser/.config/wofi/scripts/"
projects["🌋 Neovim Configs"]="/home/ka1ser/.config/nvim/"

project=$(printf "%s\n" "${!projects[@]}" | wofi -n -d -p "Search > ")
path=("${projects[$project]}")

if [[ -n "$path" ]]; then
  cd ${path} && nohup neovide . && disown && exit
fi
