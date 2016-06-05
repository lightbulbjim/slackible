#!/usr/bin/env bash
# Managed by Ansible
# Handler for display events

brightness_change_percent=5

case "$1" in
	'video/brightnessdown') xbacklight -time 100 -dec ${brightness_change_percent};;
	'video/brightnessup') xbacklight -time 100 -inc ${brightness_change_percent};;
esac
