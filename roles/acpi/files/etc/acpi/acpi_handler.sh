#!/usr/bin/env bash
# Managed by Ansible
# Main ACPI script that takes an entry for all actions

lid="/proc/acpi/button/lid/C155"


# Run things as the current X user. Necessary for screen locker.
function runasXuser {
	Xtty=$(</sys/class/tty/tty0/active)
	Xpid=$(pgrep -t $Xtty -f /usr/bin/X)
		
	Xenv+=("$(egrep -aoz 'USER=.+' /proc/$Xpid/environ)")
	Xenv+=("$(egrep -aoz 'XAUTHORITY=.+' /proc/$Xpid/environ)")
	Xenv+=("$(egrep -aoz ':[0-9](.[0-9])?' /proc/$Xpid/cmdline)")
		
	Xenv=(${Xenv[@]#*=})    
		
	(( ${#Xenv[@]} )) && {      
		export XUSER=${Xenv[0]} XAUTHORITY=${Xenv[1]} DISPLAY=${Xenv[2]}
		su -c "$*" "$XUSER"                     
	}                                               
}   


function lock_screen {
	pkill xlock
	runasXuser "/usr/bin/xlock -nice 19 -mode flame -dpmsoff 60 -background black -foreground white &" 2>/dev/null
}


# Check for caffeinated state.
# RC0 = caffeinated
function caffeinated {
	caffeinate=$(which caffeinate 2>&1) || return 1
	$caffeinate -c >/dev/null 2>&1 && return 0
	return 1
}


# Run this before suspend/hibernate
function freeze {
	pkill mbsync
	/sbin/umount -l /mnt/sd
	/usr/sbin/alsactl store
	/sbin/hwclock --systohc
	lock_screen
}


# Trigger sleep
# Arg 1 - mode ('suspend' or 'hibernate')
function do_sleep {
	local mode="$1"

	freeze
	ps auxf > /root/${mode}.ps.log
	/usr/sbin/pm-${mode}
	thaw
}


# Run this after resuming from suspend/hibernate
function thaw {
	caffeinate 0 >/dev/null 2>&1
	/sbin/hwclock --hctosys
	/usr/sbin/alsactl restore

	# Spin down fans
	for i in {1..9}; do
		echo 0 >/sys/class/thermal/cooling_device${i}/cur_state
	done
}


case "$1" in
	'button/power')
		shutdown -h now
		;;
	'button/lid')
		if grep '^state:\s\+closed$' ${lid}/state >/dev/null; then
			if caffeinated; then
				lock_screen
			else
				do_sleep suspend
			fi
		fi
		;;
esac