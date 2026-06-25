#!/bin/bash
set -e

echo "Enabling and starting NGINX..."
sudo systemctl enable nginx
sudo systemctl restart nginx

echo "Enabling and starting Fail2Ban..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "Service configuration complete."
sudo systemctl status nginx --no-pager | head -5
