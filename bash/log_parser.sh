#!/bin/bash

i=$(cat var.txt)
ip_addresses=$(cat access.log | grep "14/Aug/2019:0$i" | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+" | sort | uniq -c | sort -n)
requested_paths=$(cat access.log | grep "14/Aug/2019:0$i" | grep -Eo "(GET|POST) \S+" | sort | uniq -c | sort -n)
error_status_codes=$(cat access.log | grep "14/Aug/2019:0$i" | grep -Eo "\" (4[0-9][0-9]|5[0-9][0-9]) " | sort | uniq -c | sort -n | tr -d '"')
all_status_codes=$(cat access.log | grep "14/Aug/2019:0$i" | grep -o "\" [2-5][0-9][0-9] " | sort | uniq -c | sort -n | tr -d '"')
echo $((i+1)) > var.txt


mail -s 'Nginx log parsing result' example@gmail.com << EOF
################## Parsing log time interval ##########################
        14/Aug/2019:0$i:00:00 - 14/Aug/2019:0$((i+1)):00:00

################ IP addresses requests and their number ###############
Summ    |     Ip Addresses
$ip_addresses

################ Requested paths and their number #####################
Summ    |     Requested paths
$requested_paths

######################## Error status codes ###########################
Summ    |     Error Status codes
$error_status_codes

################ Response status codes of all requests ################
Summ    |     Status codes
$all_status_codes
EOF
