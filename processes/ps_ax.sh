#!/bin/bash

echo "---------------------------------------------------------------------------------------------------------------------------"
echo "PID         STAT                COMMAND"
for PID in $(ls /proc/ | grep "[0-9]" | sort -n);
    do
        STAT=$(cat /proc/$PID/status | grep State | awk '{print $2}')

        COMM=$(cat /proc/$PID/cmdline | tr -d '\0')
        if  [[ -z "$COMM" ]]
            then
                COMM=$(awk '/Name/{print $2}' /proc/$PID/status)
            else
                COMM=$(cat /proc/$PID/cmdline | tr -d '\0')
        fi

        printf "%-13s%-20s%-40s\n" $PID $STAT $COMM
    done
echo "---------------------------------------------------------------------------------------------------------------------------"
