#!/usr/bin/env bash
echo "FQDN: $(hostname)"		# This command line interprets the domain name .
echo "Host Information:"		# All the info is printed by this command line.
hostnamectl				# It is used to  give info about OS.
echo "IP Address= $(hostname -I)"	# This command print the ip address of this machine.
df -h / 				# It prints out the storage used in a file system.
