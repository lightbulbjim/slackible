#!/usr/bin/env bash
# Managed by Ansible
# Handler for media/volume keys

vol_change_percent=5

case "$1" in
	'button/mute') amixer -q set Master toggle;;
	'button/volumedown') amixer set Master ${vol_change_percent}%-;;
	'button/volumeup') amixer set Master ${vol_change_percent}%+;;
	'button/f20') amixer -q set Capture toggle;;
esac
