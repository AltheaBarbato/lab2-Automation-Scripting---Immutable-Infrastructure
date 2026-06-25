#!/bin/bash
set -e

PACKAGES="curl wget vim htop git net-tools ufw fail2ban nginx unattended-upgrades rsyslog"

echo "Installing: $PACKAGES"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq $PACKAGES

echo "Package install complete."
