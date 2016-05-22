#!/usr/bin/env bash
# Managed by Ansible
# Main ACPI script that takes an entry for all actions

lid="/proc/acpi/button/lid/C155"


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


# Run this before suspend/hibernate
function freeze {
	pkill mbsync
	/sbin/umount -l /mnt/sd
	/usr/sbin/alsactl store
	/sbin/hwclock --systohc
	pkill xlock
	runasXuser "/usr/bin/xlock -nice 19 -mode flame -dpmsoff 60 -background black -foreground white &" 2>/dev/null
}


function do_suspend {
	ps auxf > /root/suspend.ps.log
	/usr/sbin/pm-suspend
}


function do_hibernate {
	ps auxf > /root/hibernate.ps.log
	/usr/sbin/pm-hibernate
}


# Run this after resuming from suspend/hibernate
function thaw {
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
			freeze
			do_suspend
			thaw
		fi
		;;
esac
