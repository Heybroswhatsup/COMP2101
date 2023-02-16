#!/usr/bin/env bash
# This  script  demonstrate  how to get  OS name and version, ip address , free space in root file system and also domain name.
FQDN=$(hostname -f)

#Get  information about operating system- you could also use lsb_relase
OS=$(lsb_release -ds)

#This command gets you the IP Address of the device
IP=$(hostname -I)

#It prints the free disk space on the root filesystem
Free_Space=$(df -h / | awk 'NR==2 {print $4}')

cat << EOF

Report for $(hostname)
===============
FQDN: $FQDN
Operating System: $OS
IP Address: $IP
Root File System Free Space: $Free_Space
===============

EOF


