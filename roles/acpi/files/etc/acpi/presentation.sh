#!/bin/bash
# Managed by Ansible
# Presentation key helper script

# Options are above, below, left-of, right-of, same-as (mirror)
placement=above

# Builtin display name
builtin_display="eDP1"

source $(dirname $0)/functions

[[ "$1" == "-v" ]] && verbose=1

# Send video to any connected ports
runasXuser xrandr | grep '^\S' | tail -n+2 | awk '{print $1, $2}' | while read output; do
	name="${output% *}"
	state="${output#* }"

	[[ "$name" == "$builtin_display" ]] && continue

	verbose "OUTPUT ${name}: $state"

	case $state in
		connected)
			runasXuser xrandr --output $name --auto --${placement} $builtin_display
			;;
		disconnected)
			runasXuser xrandr --output $name --off
			;;
	esac
done

# Send audio to HDMI if it's connected
if runasXuser xrandr --listmonitors | grep HDMI >/dev/null 2>&1; then
	sound_output="hdmi-stereo"
else
	sound_output="analog_stereo"
fi

runasXuser pactl set-card-profile 0 output:${sound_output}
