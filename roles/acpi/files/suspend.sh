#!/bin/sh
# Managed by Ansible
#Suspend to RAM script

pkill mbsync
/sbin/umount -l /mnt/sd
/usr/sbin/alsactl store
/sbin/hwclock --systohc
pkill xlock
su chris -c "xlock -nice 19 -mode flame -dpmsoff 60 -background black -foreground white -display :0.0 &" 2>/dev/null
ps auxf > /root/suspend.ps.log
/usr/sbin/pm-suspend

#Now we are suspended

/sbin/hwclock --hctosys
/usr/sbin/alsactl restore

# Spin down fans
for i in {1..9}; do
	echo 0 >/sys/class/thermal/cooling_device${i}/cur_state
done
