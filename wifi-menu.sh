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

if [[ ! -z $CURRSSID ]]; then
	HIGHLINE=$(echo  "$(echo "$LIST" | awk -F "[  ]{2,}" '{print $1}' | grep -Fxn -m 1 "$CURRSSID" | awk -F ":" '{print $1}') + 1" | bc )
fi

if [ "$LINENUM" -gt 8 ] && [[ "$CONSTATE" =~ "enabled" ]]; then
	LINENUM=8
elif [[ "$CONSTATE" =~ "disabled" ]]; then
	LINENUM=1
fi

if [[ "$CONSTATE" =~ "enabled" ]]; then
	TOGGLE="toggle off"
elif [[ "$CONSTATE" =~ "disabled" ]]; then
	TOGGLE="toggle on"
fi

# Get screen width and height
SCREEN_WIDTH=$(xdpyinfo | awk '/dimensions/{print $2}' | cut -d 'x' -f1)
SCREEN_HEIGHT=$(xdpyinfo | awk '/dimensions/{print $2}' | cut -d 'x' -f2)

# Menu width (adjusted to be even larger)
MENU_WIDTH=$RWIDTH
MENU_HEIGHT=$((LINENUM * 40))

# Calculate offsets to position the window slightly above center
XOFF=$(( (SCREEN_WIDTH - MENU_WIDTH) / 2 ))
YOFF=$(( (SCREEN_HEIGHT - MENU_HEIGHT) / 2 - 120 )) # Moves the menu slightly upwards

# Make sure offsets are non-negative
XOFF=$((XOFF < 0 ? 0 : XOFF))
YOFF=$((YOFF < 0 ? 0 : YOFF))

CHENTRY=$(echo -e "$TOGGLE\nmanual\n$LIST" | uniq -u | wofi -i -d --prompt "Wi-Fi SSID: " \
    --lines "$LINENUM" --location 0 --yoffset "$YOFF" --xoffset "$XOFF" --width "$RWIDTH")

CHSSID=$(echo "$CHENTRY" | sed  's/\s\{2,\}/\|/g' | awk -F "|" '{print $1}')

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
		CHSSID=$(echo "$CHENTRY" | sed  's/\s\{2,\}/\|/g' | awk -F "|" '{print $3}')
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
