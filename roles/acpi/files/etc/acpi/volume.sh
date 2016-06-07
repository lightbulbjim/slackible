#/bin/bash
# Managed by Ansible
# Volume control helper script

step=5
use_amixer=0
sink='@DEFAULT_SINK@'
src='@DEFAULT_SOURCE@'

case $1 in
	mute)
		if [[ "$use_amixer" -eq 1 ]]; then
			amixer -D pulse sset Master toggle
		else
			pactl set-sink-mute $sink toggle
		fi
		;;
	down)
		if [[ "$use_amixer" -eq 1 ]]; then
			amixer -D pulse sset Master unmute ${step}%-
		else
			pactl set-sink-mute $sink 0
			pactl set-sink-volume $sink -${step}%
		fi
		;;
	up)
		if [[ "$use_amixer" -eq 1 ]]; then
			amixer -D pulse sset Master unmute ${step}%+
		else
			pactl set-sink-mute $sink 0
			pactl set-sink-volume $sink +${step}%
		fi
		;;
	micmute)
		if [[ "$use_amixer" -eq 1 ]]; then
			amixer -D pulse sset Capture toggle
		else
			pactl set-source-mute $src toggle
		fi
		;;
esac
