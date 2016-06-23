#!/bin/bash
# Managed by Ansible
# Volume control helper script

step=5
sink='@DEFAULT_SINK@'
src='@DEFAULT_SOURCE@'

case $1 in
	mute)
		#amixer -q -D pulse sset Master toggle
		pactl set-sink-mute $sink toggle
		;;
	down)
		#amixer -q -D pulse sset Master unmute ${step}%-
		pactl set-sink-mute $sink 0
		pactl set-sink-volume $sink -${step}%
		;;
	up)
		#amixer -q -D pulse sset Master unmute ${step}%+
		pactl set-sink-mute $sink 0
		pactl set-sink-volume $sink +${step}%
		;;
	micmute)
		amixer -q -c0 sset Capture toggle
		#pactl set-source-mute $src toggle
		;;
esac
