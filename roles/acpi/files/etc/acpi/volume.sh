#/bin/sh
# Managed by Ansible
# Volume control helper script

sink='@DEFAULT_SINK@'
source='@DEFAULT_SOURCE@'
step=5

case $1 in
	mute)
		pactl set-sink-mute $sink toggle
		;;
	down)
		pactl set-sink-mute $sink 0
		pactl set-sink-volume $sink -${step}%
		;;
	up)
		pactl set-sink-mute $sink 0
		pactl set-sink-volume $sink +${step}%
		;;
	micmute)
		pactl set-source-mute $source toggle
		;;
esac
