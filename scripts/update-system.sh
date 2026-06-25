#!/bin/bash
set -e

echo "Updating package lists..."
sudo apt-get update -qq

echo "Upgrading installed packages..."
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq

echo "Removing unused packages..."
sudo apt-get autoremove -y -qq

echo "System update complete."
