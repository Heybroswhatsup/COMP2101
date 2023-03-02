#!/usr/bin/env bash
#
# this script displays some host identification information for a Linux machine
#
# Sample output:
#   Hostname      : zubu
#   LAN Address   : 192.168.2.2
#   LAN Name      : net2-linux
#   External IP   : 1.2.3.4
#   External Name : some.name.from.our.isp

# TASK 1: Accept options on the command line for verbose mode and an interface name - must use the while loop and case command as shown in the lesson - getopts not acceptable for this task
# Initialize variables with default values
verbose="no"
interface=""

# Process command line options using while loop and case command
while [ $# -gt 0 ]; do
  case "$1" in
    -v)
      verbose="yes"
      shift
      ;;
    *)
      if [ -z "$interface" ]; then
        interface="$1"
      else
        echo "Error: too many arguments" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

# TASK 2: Dynamically identify the list of interface names for the computer running the script, and use a for loop to generate the report for every interface except loopback - do not include loopback network information in your output

################
# Data Gathering
################
# the first part is run once to get information about the host
# grep is used to filter ip command output so we don't have extra junk in our output
# stream editing with sed and awk are used to extract only the data we want displayed

#####
# Once per host report
#####
[ "$verbose" = "yes" ] && echo "Gathering host information"
my_hostname="$(hostname) / $(hostname -I)"

#Identify default mode
[ "$verbose" = "yes" ] && echo "Identifying default route"
default_router_address=$(ip r s default| awk '{print $3}')
default_router_name=$(getent hosts $default_router_address|awk '{print $2}')

#Checking for external IP address and hostname
[ "$verbose" = "yes" ] && echo "Checking for external IP address and hostname"
external_address=$(curl -s icanhazip.com)
external_name=$(getent hosts $external_address | awk '{print $2}')

cat <<EOF

System Identification Summary
=============================
Hostname      : $my_hostname
Default Router: $default_router_address
Router Name   : $default_router_name
External IP   : $external_address
External Name : $external_name

EOF

#####
# End of Once per host report
#####

# the second part of the output generates a per-interface report
# the task is to change this from something that runs once using a fixed value for the interface name to
#   a dynamic list obtained by parsing the interface names out of a network info command like "ip"
#   and using a loop to run this info gathering section for every interface found

# the default version uses a fixed name and puts it in a variable
#####
# Per-interface report
#####

# define the interface being summarized
ifaces=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^(lxdbr0|ens33)$')

# Loop through each interface and gather information for it
for interface in $ifaces; do
if [ "$verbose" = "yes" ]; then
    echo "Reporting on interface: $interface"
  fi

#Get IPV4 address and name for interfaces

ipv4_address=$(ip a s $interface | awk -F '[/ ]+' '/inet /{print $3}')
ipv4_hostname=$(getent hosts $ipv4_address | awk '{print $2}')

if [ "$verbose" = "yes" ]; then 
echo "Getting IPV4 network block info and name for interface $interface"
fi
# Identify the network number for this interface and its name if it has one
# Some organizations have enough networks that it makes sense to name them just like how we name hosts
# To ensure your network numbers have names, add them to your /etc/networks file, one network to a line, as   networkname networknumber
#   e.g. grep -q mynetworknumber /etc/networks || (echo 'mynetworkname mynetworknumber' |sudo tee -a /etc/networks)
network_address=$(ip route list dev $interface scope link| awk '{print $1}' | tr '\n' ' ')
network_number=$(cut -d / -f 1 <<<"$network_address")
network_name=$(getent networks $network_number|awk '{print $1}')

cat <<EOF

Interface $interface:
===============
Address         : $ipv4_address
Name            : $ipv4_hostname
Network Address : $network_address
Network Name    : $network_name

EOF
done

#####
# End of per-interface report
#####
