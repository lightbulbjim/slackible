#!/usr/bin/env bash
# Managed by Ansible
# Hibernate when battery runs low

logfile="/tmp/hibernate.log"
battinfo="/proc/acpi/battery/C23D/info"
battstate="/proc/acpi/battery/C23D/state"
minimum_minutes=8
minimum_percent=6

# minutes or percent
mode="percent"

function hibernate {
	/etc/acpi/hibernate.sh
}

if [[ -f $battstate ]]; then
	action=$(cat $battstate | grep ^charging | cut -c 26-)
	rate=$(cat $battstate | grep ^"present rate:" | awk '{print $3}')
	if [[ $action == "discharging" && $rate != 0 ]]; then
		remaining=$(cat $battstate | grep ^remaining | awk '{print $3}')
		if [[ $mode == "minutes" ]]; then
			if (( $remaining * 60 / $rate < $minimum_minutes )); then
				hibernate
			fi
		elif [[ $mode == "percent" && -f $battinfo ]]; then
			capacity=$(cat $battinfo | grep ^last | awk '{print $4}')
			if (( $remaining * 100 / $capacity < $minimum_percent )); then
				echo "Going to hibernate now..." >> $logfile
				hibernate
			else
				echo "Power level ok." >> $logfile
			fi
		fi
	fi
fi
