#!/bin/bash

declare -A projects
projects["🛰️ Terminal kit"]="/home/ka1ser/github/terminal-kit/"
projects["🧊 ColdRelay Core"]="/home/ka1ser/coldrelay/core_service/"
projects["🧿 Coldrealy Frontend"]="/home/ka1ser/coldrelay/Frontend/"
projects["💰 Subscription Service"]="/home/ka1ser/coldrelay/subscription_management_service//"
projects["🥝 Infra Deployer"]="/home/ka1ser/coldrelay/infra_service/"
projects["🫐 Hyprland Dotfiles"]="/home/ka1ser/.config/hypr/default/"
projects["🌵 Wofi Scripts"]="/home/ka1ser/.config/wofi/scripts/"
projects["🌋 Neovim Configs"]="/home/ka1ser/.config/nvim/"
projects["🐫 Open Postgres"]="docker ps | grep \"postgres \" | awk '{print \$NF}'"
projects["⛈️ Problem Solving "]="/home/ka1ser/Problem-Solving/"
projects["🧪 Search Simulator"]="/home/ka1ser/Search-Simulator/"
projects["🥷 User Management"]="/home/ka1ser/coldrelay/user_management_service/"
projects["👺 ColdRelay ENV"]="neovide /home/ka1ser/coldrelay/core_service/.env"
projects["👺 Infra ENV"]="neovide /home/ka1ser/coldrelay/infra_service/.env"
projects["👺 Subscription ENV"]="neovide /home/ka1ser/coldrelay/subscription_management_service/.env"
projects["👺 User Management ENV"]="neovide /home/ka1ser/coldrelay/user_management_service/.env"

project=$(printf "%s\n" "${!projects[@]}" | wofi -n -d -p "Search > ")

path=("${projects[$project]}")
if [[ -n "$path" ]]; then
  if [[ "$project" == "🐫 Open Postgres" ]]; then

    # only first time 
    # docker run --name coldrelay -p 5432:5432 -e POSTGRES_PASSWORD=secret \
    #   -v postgres_data:/var/lib/postgresql/data \
    #   -d postgres
    # container_name=$(eval "${projects["$project"]}")
  
    docker start coldrelay
    container_name="coldrelay"
    kitty docker exec -it "$container_name" psql -U postgres -d coldrelay
  elif [[ "$project" == *"ENV"* ]]; then
    eval "${projects["$project"]}"
  else
    source /home/ka1ser/global/bin/activate
    cd "$path" && nohup neovide . &
    # cd "$path" && kitty nvim .
    disown && exit
  fi
fi
