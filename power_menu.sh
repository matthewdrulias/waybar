#! /bin/sh

chosen=$(printf "Power Off\nSuspend\nReboot\nLock" | rofi -dmenu -i -p "System"  -theme-str '@import "artix-ice.rasi"')

case "$chosen" in
    "Power off") poweroff ;;
    "Suspend") loginctl suspend && hyprlock;;
    "Reboot") reboot ;;
    "Lock") hyprlock;;
    *) exit 1;;
esac
