#!/usr//bin/env bash

#Introducing Variables
CONTAINER_NAME="COMP2101-S22"
HOSTNAME="$CONTAINER_NAME"

# Check if lxd is installed or not
if ! command -v lxd &> /dev/null; then
# Install lxd if it is not installed
    sudo snap install lxd
else
    echo "lxd is already installed"
fi

# Check if lxdbr0 interface exists, and start lxd if necessary
if ! ip a show lxdbr0 &> /dev/null; then
    sudo lxd init --auto
fi

# Check if container exists and launch it if necessary
if ! lxc info $CONTAINER_NAME &> /dev/null; then
# Launch Ubuntu 20.04 container with specified name
sudo lxc launch ubuntu:20.04 $CONTAINER_NAME
fi

# Get the container's IP address
ip=$(lxc list $CONTAINER_NAME | grep eth0 | awk '{print $6}')

# Check if the entry for the container's hostname exists inside /etc/hosts
if ! grep -q "$HOSTNAME" /etc/hosts; then
  # Add the container's IP and hostname to /etc/hosts
  echo "$ip $HOSTNAME" | sudo tee -a /etc/hosts > /dev/null
else
  # Update the container's IP in /etc/hosts
  sudo sed -i "s/.*$HOSTNAME/$ip $HOSTNAME/g" /etc/hosts
fi

# Install Apache2 in the container if it is  necessary
if ! lxc exec $CONTAINER_NAME -- command -v apache2 &> /dev/null; then
  # Update package list and install Apache2
  lxc exec $CONTAINER_NAME -- apt-get update
  lxc exec $CONTAINER_NAME -- apt-get install -y apache2
else
  echo "Apache2 is already installed in the container."
fi

# Retrieve the default web page from the container's web service and give the reuslts of success or failure
if 
	sudo snap install curl
	curl -sSf http://$HOSTNAME &> /dev/null; then
  echo "The default web page was successfully obtained from the container's web service."
else
  echo "The container's web service failed to obtain the default web page."
fi
