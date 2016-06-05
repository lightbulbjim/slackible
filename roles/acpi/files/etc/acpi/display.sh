#!/usr/bin/env bash
# Managed by Ansible
# Handler for display events

brightness_change_percent=5

case "$1" in
	'video/brightnessdown') xbacklight -time 0 -dec ${brightneww_change_percent};;
	'video/brightnessup') xbacklight -time 0 -inc ${brightneww_change_percent};;
esac
