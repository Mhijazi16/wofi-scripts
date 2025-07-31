#!/bin/bash

docker start coldrelay
query="SELECT admin_domain, admin_password FROM core.servers;"
data=$(docker exec -it coldrelay psql -U postgres -d coldrelay -P pager=off -c "$query" --csv)

declare -A servers

while IFS= read -r line; do
  host=$(echo "$line" | cut -d ',' -f1)
  password=$(echo "$line" | cut -d ',' -f2-)
  servers["$host"]="$password"
done << "$data"

echo hello




# declare -A servers 

# while IFS= read -r line; do
#   key=$(echo "$line" | cut -d ',' -f1)
#   value=$(echo "$line" | cut -d ',' -f2-)
#   servers["$key"]="$value"
# done <<< "$data"
#
# # Show domain list in wofi
# selected=$(printf "%s\n" "${!servers[@]}" | wofi --dmenu --prompt "Search > ")
# echo ${servers["$selected"]} | wl-copy
# notify-send "copied password for $selected"
