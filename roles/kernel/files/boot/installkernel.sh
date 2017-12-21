#!/usr/bin/env bash
# Managed by Ansible
# installkernel.sh - copy compiled kernel artifacts to /boot

if [[ -z "$1" ]]; then
	echo "Installs compiled kernel to /boot"
	echo "Usage:    $0 <version>"
	echo "Example:  $0 wow-4.10.14"
	exit 1
fi

version="$1"
realversion="${version#*-}"

src="/usr/src/linux-${realversion}"
if [[ ! -d "$src" ]]; then
	echo "$src doesn't exist or is not a directory. Bailing out!"
	exit 1
fi

echo
echo "About to copy kernel files to /boot:"
echo "$src/arch/x86_64/boot/bzImage will be copied to /boot/vmlinuz-${version}"
echo "$src/System.map will be copied to /boot/System.map-${version}"
echo "$src/.config will be copied to /boot/config-${version}"

echo -n "Proceed? [y/N] "
read input
if [[ "$input" == "y" ]]; then
	cp -v "$src/arch/x86_64/boot/bzImage" "/boot/vmlinuz-${version}"
	cp -v "$src/System.map" "/boot/System.map-${version}"
	cp -v "$src/.config" "/boot/config-${version}"
else
	echo "Skipping..."
fi

echo
echo "About to update kernel symlinks in /boot:"

oldkernel="$(readlink -f /boot/vmlinuz)"

echo "/boot/vmlinuz-old will be linked to $oldkernel"
echo "/boot/vmlinuz will be linked to /boot/vmlinuz-${version}"
echo "/boot/System.map will be linked to /boot/System.map-${version}"
echo "/boot/config will be linked to /boot/config-${version}"

echo -n "Proceed? [y/N] "
read input
if [[ "$input" == "y" ]]; then
	ln -nfsv $oldkernel /boot/vmlinuz-old
	ln -nfsv /boot/vmlinuz-${version} /boot/vmlinuz
	ln -nfsv /boot/System.map-${version} /boot/System.map
	ln -nfsv /boot/config-${version} /boot/config
else
	echo "Skipping..."
fi

echo
echo "Don't forget to run lilo!"
