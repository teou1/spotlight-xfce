# spotlight
Windows 11 Spotlight Background images for XFCE
Forked from https://github.com/mariusknaust/spotlight

## Installation
### System-wide
* /usr/bin/spotlight.sh
* /usr/lib/systemd/user/spotlight.service
* /usr/lib/systemd/user/spotlight.timer
* /usr/share/applications/spotlight.desktop
### Local
* ~/.local/bin/spotlight.sh
* ~/.local/share/systemd/user/spotlight.service
* ~/.local/share/systemd/user/spotlight.timer
* ~/.local/share/applications/spotlight.desktop
### Dependencies
* wget
* jq
* sed
* glib2
* systemd
* libnotify

## Usage
Run `systemctl --user enable spotlight.timer` to get a new picture every second day.

To fetch a new background manually you can either use the desktop entry by looking for _Spotlight_ in your XFCE application menu or trigger the service from command line with `systemctl --user start spotlight.service`. You can also right-click on the desktop and select _Spotlight refresh_ on the top of it.

Use the system log to get the past image descriptions, e.g. for the the current background `journalctl -t spotlight -n 1 --no-pager`.
You can also rightclick the desktop or look for _Spotlight info_ in the application menu

## Configuration

Spotlight does not require particular configuration.

The default behavior of spotlight is to discard the previous image when it fetches a new one. This behavior can be alter from the command line:

 * -h shows a help message
 * -k keeps the previous image
 * -d stores the image into the given destination. Defaults to "$HOME/.local/share/spotlight".

### Service

In order to modify the behavior of the service `systemctl edit --user spotlight.service` can be used to overwrite the program invocation:

```
[Service]
ExecStart=
ExecStart=/usr/bin/env bash spotlight.sh -k -d %h/Pictures/Spotlight
```


