## When you start vagrant then a script is run which simulates the output of the "ps ax" program:
```
processes.vm.provision "shell", path: "ps_ax.sh"

    ...

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
```

## At the end of the debug log you can see the result of the script:
```
PID         STAT                COMMAND
1            S                   /usr/lib/systemd/systemd--switched-root--system--deserialize17
2            S                   kthreadd
3            I                   rcu_gp
4            I                   rcu_par_gp
5            I                   kworker/0:0-xfs-cil/sda1
6            I                   kworker/0:0H-kblockd
7            I                   kworker/u2:0-events_unbound
8            I                   mm_percpu_wq
9            S                   ksoftirqd/0
10           I                   rcu_sched
11           S                   migration/0
12           S                   watchdog/0
13           S                   cpuhp/0
15           S                   kdevtmpfs
16           I                   netns
17           S                   kauditd
18           S                   khungtaskd
19           S                   oom_reaper
20           I                   writeback
21           S                   kcompactd0
22           S                   ksmd
23           S                   khugepaged
24           I                   crypto
25           I                   kintegrityd
26           I                   kblockd
27           I                   md
28           I                   edac-poller
29           S                   watchdogd
38           S                   kswapd0
57           I                   kworker/u2:1-events_unbound
89           I                   kthrotld
90           I                   acpi_thermal_pm
91           I                   kmpath_rdacd
92           I                   kaluad
```
