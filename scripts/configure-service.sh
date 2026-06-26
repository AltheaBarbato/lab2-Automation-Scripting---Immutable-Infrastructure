#!/bin/bash
set -e

echo "turning on nginx..."
sudo systemctl enable nginx
sudo systemctl restart nginx

echo "turning on fail2ban..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "done."
sudo systemctl status nginx --no-pager | head -5
