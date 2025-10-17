#!/usr/bin/env bash

# Starts a scan of available broadcasting SSIDs
# nmcli dev wifi rescan

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

FIELDS=SSID,SECURITY
POSITION=0
YOFF=0
XOFF=0

if [ -r "$DIR/config" ]; then
	source "$DIR/config"
elif [ -r "$HOME/.config/wofi/wifi" ]; then
	source "$HOME/.config/wofi/wifi"
else
	echo "WARNING: config file not found! Using default values."
fi

LIST=$(nmcli --fields "$FIELDS" device wifi list | sed '/^--/d')
RWIDTH=$(( $(echo "$LIST" | head -n 1 | awk '{print length($0); }') * 17 )) # Further increased width factor
LINENUM=$(echo "$LIST" | wc -l)

KNOWNCON=$(nmcli connection show)
CONSTATE=$(nmcli -fields WIFI g)
CURRSSID=$(LANGUAGE=C nmcli -t -f active,ssid dev wifi | awk -F: '$1 ~ /^yes/ {print $2}')

# Use bc only if available and CURRSSID is set
if [[ ! -z $CURRSSID ]] && command -v bc > /dev/null; then
	HIGHLINE=$(echo  "$(echo "$LIST" | awk -F "[  ]{2,}" '{print $1}' | grep -Fxn -m 1 "$CURRSSID" | awk -F ":" '{print $1}') + 1" | bc )
fi

# Limit number of lines for wofi menu
if [ "$LINENUM" -gt 8 ] && [[ "$CONSTATE" =~ "enabled" ]]; then
	LINENUM=8
elif [[ "$CONSTATE" =~ "disabled" ]]; then
	LINENUM=1
fi

# 🔧 Ensure LINENUM is at least 1 to avoid GTK crash
if [ "$LINENUM" -lt 1 ]; then
	LINENUM=1
fi

# Toggle Wi-Fi switch
if [[ "$CONSTATE" =~ "enabled" ]]; then
	TOGGLE="toggle off"
elif [[ "$CONSTATE" =~ "disabled" ]]; then
	TOGGLE="toggle on"
fi

# Get screen dimensions
SCREEN_WIDTH=$(xdpyinfo | awk '/dimensions/{print $2}' | cut -d 'x' -f1)
SCREEN_HEIGHT=$(xdpyinfo | awk '/dimensions/{print $2}' | cut -d 'x' -f2)

# Menu sizing
MENU_WIDTH=$RWIDTH
MENU_HEIGHT=$((LINENUM * 40))

XOFF=$(( (SCREEN_WIDTH - MENU_WIDTH) / 2 ))
YOFF=$(( (SCREEN_HEIGHT - MENU_HEIGHT) / 2 - 120 ))

XOFF=$((XOFF < 0 ? 0 : XOFF))
YOFF=$((YOFF < 0 ? 0 : YOFF))

# Display menu
CHENTRY=$(echo -e "$TOGGLE\nmanual\n$LIST" | uniq -u | wofi -i -d --prompt "Wi-Fi SSID: " \
    --lines "$LINENUM" --location 0 --yoffset "$YOFF" --xoffset "$XOFF" --width "$RWIDTH")

echo "DEBUG: CHENTRY=$CHENTRY"
CHSSID=$(echo "$CHENTRY" | awk '{print $1}')

# Prevent running on empty selection
if [ -z "$CHSSID" ] && [[ "$CHENTRY" != "manual" ]] && [[ "$CHENTRY" != "toggle on" ]] && [[ "$CHENTRY" != "toggle off" ]]; then
    echo "Error: No SSID selected or invalid selection."
    exit 1
fi

if [ "$CHENTRY" = "manual" ] ; then
	MSSID=$(echo "enter the SSID of the network (SSID,password)" | wofi -d "Manual Entry: " --lines 1)
	MPASS=$(echo "$MSSID" | awk -F "," '{print $2}')

	if [ "$MPASS" = "" ]; then
		nmcli dev wifi con "$MSSID"
	else
		nmcli dev wifi con "$MSSID" password "$MPASS"
	fi

elif [ "$CHENTRY" = "toggle on" ]; then
	nmcli radio wifi on

elif [ "$CHENTRY" = "toggle off" ]; then
	nmcli radio wifi off

else
	if [ "$CHSSID" = "*" ]; then
		CHSSID=$(echo "$CHENTRY" | awk '{print $3}')
	fi

	if [[ $(echo "$KNOWNCON" | grep "$CHSSID") = "$CHSSID" ]]; then
		nmcli con up "$CHSSID"
	else
		if [[ "$CHENTRY" =~ "WPA2" ]] || [[ "$CHENTRY" =~ "WEP" ]]; then
			WIFIPASS=$(echo "if connection is stored, hit enter" | wofi -P -d --prompt "password" --lines 1 --location 0 --yoffset "$YOFF" --xoffset "$XOFF" --width $RWIDTH)
		fi
		nmcli dev wifi con "$CHSSID" password "$WIFIPASS"
	fi

fi
