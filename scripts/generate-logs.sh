#!/bin/bash
set -e

sudo tee /etc/logrotate.d/lab2-nginx > /dev/null <<'EOF'
/var/log/nginx/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    sharedscripts
    postrotate
        /bin/kill -USR1 $(cat /run/nginx.pid 2>/dev/null) 2>/dev/null || true
    endscript
}
EOF

logger -t lab2-deploy "Lab 2 automation ran on $(hostname) at $(date)"

echo "Logging configured. Sample entry written to syslog via logger."
sudo tail -3 /var/log/syslog
