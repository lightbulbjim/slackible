#!/bin/bash
# Managed by Ansible
# Backlight control helper script

step_fraction=20
backlight="/sys/class/backlight/intel_backlight"

cur=$(cat ${backlight}/brightness)
max=$(cat ${backlight}/max_brightness)
min=0

case $1 in
	down)
		new=$((${cur}-${max}/${step_fraction}))
		if [[ $new -le $min ]]; then
			new=$min
		fi
		;;
	up)
		new=$((${cur}+${max}/${step_fraction}))
		if [[ $new -ge $max ]]; then
			new=$max
		fi
		;;
	*)
		echo "Min: ${min}  Max: ${max}  Current: ${cur}"
		exit 0
		;;
esac

echo $new > ${backlight}/brightness
