#!/bin/sh
# Managed by Ansible
# Default acpi script that takes an entry for all actions

IFS=${IFS}/
set $@

case "$1" in
	button)
		case "$2" in
			power) shutdown -h now;;
			lid)
				#xset dpms force off
				#su chris -c "xlock -nice 19 -mode flame -dpmsoff 60 -background black -foreground white -display :0.0 &" 2>/dev/null
				if cat /proc/acpi/button/lid/C155/state | grep '^state:\s\+closed$' >/dev/null; then
					/etc/acpi/suspend.sh
				fi
				;;
			*) logger "ACPI action $2 is not defined";;
		esac
		;;
	#*) logger "ACPI group $1 / action $2 is not defined";;
esac
