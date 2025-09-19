# spotlight
Windows 11 Spotlight Background images for XFCE
Forked from https://github.com/mariusknaust/spotlight

## Installation
### System-wide
* /usr/bin/spotlight.sh
* /usr/lib/systemd/user/spotlight.service
* /usr/lib/systemd/user/spotlight.timer
* /usr/share/applications/spotlight-refresh.desktop
* /usr/share/applications/spotlight-info.desktop
### Local
* ~/.local/bin/spotlight.sh
* ~/.local/share/systemd/user/spotlight.service
* ~/.local/share/systemd/user/spotlight.timer
* ~/.local/share/applications/spotlight-refresh.desktop
* ~/.local/share/applications/spotlight-info.desktop

After copying the files, make spotlight.sh executable, enable the timer and refresh the new image as described below. After that you will have manually set your wallpaper to `~/.local/share/spotlight/background.jpg` the first time. Adjust the other settings as you wish, Style=Zoom is strongly recommended if you only have a fullhd monitor as the pulled images are large.
From now on, if the timer is active, the image will change evry 2-3 days (you can edit the timer and set it to _daily_ instead of _Mon,Wed,Fri_)

### Dependencies
* wget
* grep
* sed
* glib2
* systemd
* libnotify

## Usage
Run `systemctl --user enable spotlight.timer` to get a new picture every second day.

To fetch a new background manually you can either use the desktop entry by looking for _Spotlight_ in your XFCE application menu or trigger the service from command line with `systemctl --user start spotlight.service`. You can also right-click on the desktop and select _Spotlight refresh_ on the top of it.

Use the system log to get the past image descriptions and urls, e.g. `journalctl -t spotlight --no-pager`.
You can also rightclick the desktop or look for _Spotlight info_ in the application menu

## Configuration

Spotlight does not require particular configuration.

The default behavior of spotlight is to discard the previous image when it fetches a new one. This behavior can be alter from the command line:

 * -h shows a help message
 * -k keeps the previous image
 * -d stores the image into the given destination. Defaults to "$HOME/.local/share/backgrounds".

### Service

In order to modify the behavior of the service `systemctl edit --user spotlight.service` can be used to overwrite the program invocation:

```
[Service]
ExecStart=
ExecStart=/usr/bin/env bash spotlight.sh -k -d %h/Pictures/Spotlight
```

### Other thoughts

If you leave the default option to delete the old wallpaper on refresh, but it occurs to you that you actually wanted it saved, you can do the following:
1) check the log with `journalctl -t spotlight --no-pager`
2) ctrl-click the url to open it in browser. Click full screen to hide some of the overlays
3) right-click and choose *inspect image*.
4) from there, select the tab *network* and then *img*
5) refresh the page and you will see a list with the five images of the day, from here you can preview or open in new tab or save


