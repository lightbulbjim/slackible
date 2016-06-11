#!/bin/bash
# Managed by Ansible
# Presentation key helper script

# Options are above, below, left-of, right-of, same-as (mirror)
placement=above

# Builtin display name
builtin_display="eDP1"

source $(dirname $0)/functions

[[ "$1" == "-v" ]] && verbose=1

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
