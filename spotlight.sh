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
fi

landscapeUrl=$(jq -r ".ad.landscapeImage.asset" <<< $response)
title=$(jq -r ".ad.title" <<< $response)
description=$(jq -r ".ad.description" <<< $response)
url=$(jq -r ".ad.ctaUri" <<< $response | sed "s/.*\(http.*\)/\1/")

mkdir -p "$backgroundsPath"
imagePath="$backgroundsPath/$(date +%y-%m-%d-%H-%M-%S)-$title.jpg"

wget -qO "$imagePath" "$landscapeUrl"

gsettings set org.gnome.desktop.background picture-options "zoom"
gsettings set org.gnome.desktop.background picture-uri "file://$imagePath"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$imagePath"

mkdir -p "$spotlightPath"

previousImagePath="$(readlink "$spotlightPath/background.jpg")"
ln -sf "$imagePath" "$spotlightPath/background.jpg"

if [ "$keepImage" = false ] && [ -n "$previousImagePath" ] && [ -f "$previousImagePath" ] && [ "$imagePath" != "$previousImagePath" ]
then
	rm "$previousImagePath"
fi

notify-send "Background changed to \"$title\"" "$description" --icon=preferences-desktop-wallpaper --urgency=low --hint=string:desktop-entry:spotlight
systemd-cat -t spotlight -p info <<< "Background changed to \"$title\" ($url)"
