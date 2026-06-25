#!/bin/bash
set -e

USERNAME="${1:-deploy}"

if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists, skipping."
    exit 0
fi

echo "Creating user $USERNAME..."
sudo adduser "$USERNAME" --gecos "" --disabled-password
sudo usermod -aG sudo "$USERNAME"

echo "Setting up SSH key for $USERNAME..."
sudo mkdir -p "/home/$USERNAME/.ssh"
if [ -f "/home/sysadmin/.ssh/authorized_keys" ]; then
    sudo cp "/home/sysadmin/.ssh/authorized_keys" "/home/$USERNAME/.ssh/authorized_keys"
fi
sudo chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.ssh"
sudo chmod 700 "/home/$USERNAME/.ssh"
sudo chmod 600 "/home/$USERNAME/.ssh/authorized_keys" 2>/dev/null || true

echo "User $USERNAME created."
