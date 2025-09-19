#!/usr/bin/env bash

dataPath="${XDG_DATA_HOME:-$HOME/.local/share}"

spotlightPath="$dataPath/spotlight"
backgroundsPath="$dataPath/backgrounds"

keepImage=false

function showHelp()
{
	echo "Usage: $0 [-k] [-d <destination>]"
	echo ""
	echo "Options:"
	echo "	-h shows this help message"
	echo "	-k keeps the previous image"
	echo "	-d stores the image into the given destination. Defaults to \"$HOME/.local/share/backgrounds\"."
}

while getopts "hkd:" opt
do
	case $opt
	in
		'k')
			keepImage=true
		;;
		'd')
			backgroundsPath=$OPTARG
		;;
		'h'|'?')
			showHelp
			exit 0
		;;
	esac
done

response=$(wget -qO- -U "WindowsShellClient/0" "https://fd.api.iris.microsoft.com/v4/api/selection?placement=88000820&fmt=json&locale=en-US&country=US")
status=$?

if [ $status -ne 0 ]
then
	systemd-cat -t spotlight -p emerg <<< "Query failed"
	exit $status
else
	rm /tmp/spotlight.json
 	cat "$response" > /tmp/spotlight.json
fi

landscapeUrl=$(grep -oP '"landscapeImage":\{"asset":"\K[^"]*(?="\}|,"portraitImage")' /tmp/spotlight.json)
title=$(grep -oP '"iconHoverText":\s*"\K[^"\\]*(?=\\r\\n)' /tmp/spotlight.json)
url=$(grep -oP '"ctaUri":"microsoft-edge:\K[^"]*' /tmp/spotlight.json)

mkdir -p "$backgroundsPath"
imagePath="$backgroundsPath/$(date +%y-%m-%d-%H-%M-%S).jpg"

wget -qO "$imagePath" "$landscapeUrl"

# gsettings set org.gnome.desktop.background picture-options "zoom"
# gsettings set org.gnome.desktop.background picture-uri "file://$imagePath"
# gsettings set org.gnome.desktop.background picture-uri-dark "file://$imagePath"

mkdir -p "$spotlightPath"

previousImagePath="$(readlink "$spotlightPath/background.jpg")"
ln -sf "$imagePath" "$spotlightPath/background.jpg"

if [ "$keepImage" = false ] && [ -n "$previousImagePath" ] && [ -f "$previousImagePath" ] && [ "$imagePath" != "$previousImagePath" ]
then
	rm "$previousImagePath"
fi

notify-send "Background changed to" "$title"  --icon=preferences-desktop-wallpaper
systemd-cat -t spotlight -p info <<< "Background changed to \"$title\" $url"
