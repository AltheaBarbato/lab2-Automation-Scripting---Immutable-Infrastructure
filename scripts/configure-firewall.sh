#!/bin/bash
set -e

echo "Resetting UFW to defaults..."
sudo ufw --force reset > /dev/null

sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow 22/tcp comment 'SSH'
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'
sudo ufw allow 9100/tcp comment 'node_exporter metrics'

sudo ufw --force enable
sudo ufw status verbose

echo "Firewall configured."
