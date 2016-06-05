#!/usr/bin/env bash
# Managed by Ansible
# Main ACPI script that takes an entry for all actions

# Daemons which don't like sleeping.
# List in order they need to be killed (will be reversed on wake).
cranky_daemons=( )


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
	runasXuser "/usr/bin/xlock &" 2>/dev/null
}


# Arg 1 - service name
function stop_service {
	/etc/rc.d/rc.${1} stop
}


# Arg 1 - service name
function start_service {
	/etc/rc.d/rc.${1} start
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
	wake_daemons=()
	for d in ${cranky_daemons[@]}; do
		if ps ax | grep $d | grep -v grep >/dev/null; then
			stop_service $d
			wake_daemons=( $d ${wake_daemons[@]} )
		fi
	done

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

	for d in ${wake_daemons[@]}; do
		start_service $d
	done
}


case "$1" in
	'button/power')
		shutdown -h now
		;;
	'button/lid')
		if [[ "$3" == 'close' ]]; then
			if caffeinated; then
				lock_screen
			else
				do_sleep suspend
			fi
		fi
		;;
esac
