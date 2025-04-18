#!/usr/bin/bash

declare -A URLS
URLS=(
  ["chatgpt"]="http://chatgpt.com/"
  ["duckduckgo"]="https://www.duckduckgo.com/?q="
  ["github"]="https://github.com/search?q="
  ["goodreads"]="https://www.goodreads.com/search?q="
  ["stackoverflow"]="http://stackoverflow.com/search?q="
  ["searchcode"]="https://searchcode.com/?q="
  ["superuser"]="http://superuser.com/search?q="
)


gen_list() {
    for i in "${!URLS[@]}"
    do
      printf "$i\n"
    done
}

main() {
  # Pass the list to wofi
  platform=$( (gen_list) | wofi -n -d -p "Search > " )
  [[ $platform ]] || exit

    if [[ " ${!URLS[@]} " =~ " ${platform} " ]]; then
          query=$(printf "" | wofi -H 10% -n -d -p "Query > " )
          [[ $query ]] || exit
            url=${URLS[$platform]}${query}
            xdg-open "$url"
            exit
    fi
    case "$platform" in
      lichess|chess) xdg-open "https://www.lichess.org" ;;
      pr|proton) xdg-open "https://account.protonmail.com/login" ;;
      ali|alibaba) xdg-open "https://www.aliexpress.com/" ;;
      wb|wb) xdg-open "https://cschad.tech" ;;
      *) xdg-open "https://searx.be/search?q=$platform" ;;
    esac
}

main

exit 0
