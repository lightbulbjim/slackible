#!/bin/bash
# Managed by Ansible
# Touchpad management

source $(dirname $0)/functions

case "$1" in
    enable)
        synclient TouchpadOff=0
        ;;
    disable)
        synclient TouchpadOff=1
        ;;
    toggle)
        currentState="$(synclient -l | grep TouchpadOff | awk '{print $NF}')"
        if [[ "$currentState" -eq 0 ]]; then
            synclient TouchpadOff=1
        elif [[ "$currentState" -eq 1 ]]; then
            synclient TouchpadOff=0
        fi
        ;;
esac
