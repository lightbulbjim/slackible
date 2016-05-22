#!/usr/bin/env bash
# Managed by Ansible
# Clean shutdown when battery runs low

battery="/proc/acpi/battery/C23D"
minimum_minutes=8
minimum_percent=6

# minutes or percent
mode="percent"

debug=1
logfile="/tmp/acpi.log"


function debug {
	if [[ $debug -eq 1 ]]; then
		echo "$*" >> $logfile
	fi
}

for f in state info; do
	if [[ ! -f ${battery}/${f} ]]; then
		debug "File ${battery}/${f} not found - bailing out!"
		exit 1
	fi
done

state=$(grep '^charging state:' ${battery}/state | awk '{print $3}')
rate=$(grep '^present rate:' ${battery}/state | awk '{print $3}')

if [[ $state == "discharging" && $rate != 0 ]]; then
	remaining=$(grep '^remaining capacity:' ${battery}/state | awk '{print $3}')
	if [[ $mode == "minutes" ]]; then
		remaining_minutes=$(( $remaining * 60 / $rate ))
		if (( $remaining_minutes < $minimum_minutes )); then
			debug "$remaining_minutes minutes remaining (< $minimum_minutes) - going to shutdown now..."
		else
			debug "$remaining_minutes minutes remaining (>= $minimum_minutes) - power level ok."
		fi
	elif [[ $mode == "percent" ]]; then
		capacity=$(grep '^last full capacity' ${battery}/info | awk '{print $4}')
		remaining_percent=$(( $remaining * 100 / $capacity ))
		if (( $remaining_percent < $minimum_percent )); then
			debug "${remaining_percent}% remaining (< ${minimum_percent}%) - going to shutdown now..."
		else
			debug "${remaining_percent}% remaining (>= ${minimum_percent}%) - power level ok."
		fi
	fi
else
	debug "AC adapter connected so nothing to do."
fi
