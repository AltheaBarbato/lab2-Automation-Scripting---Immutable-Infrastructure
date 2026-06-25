#!/bin/bash
set -e

SERVER_IP="163.192.117.50"
SSH_KEY="$HOME/.ssh/lab1-key.pem"
SSH_OPTS="-i $SSH_KEY -o StrictHostKeyChecking=no -o ConnectTimeout=10"

echo "=== Destroying the NGINX config and the node_exporter container on purpose ==="
ssh $SSH_OPTS "sysadmin@$SERVER_IP" "sudo rm -f /etc/nginx/sites-available/default /var/www/html/index.html && sudo docker rm -f node_exporter"

echo "=== Confirming both are actually gone ==="
curl -s -o /dev/null -w "web page now returns: %{http_code}\n" "http://$SERVER_IP"
ssh $SSH_OPTS "sysadmin@$SERVER_IP" "sudo docker ps -a --filter name=node_exporter --format '{{.Names}}'" | grep -q node_exporter && echo "container still listed (stopped)" || echo "container fully removed"

echo ""
echo "=== Rerunning the playbook to rebuild from code ==="
bash deploy.sh

echo ""
echo "=== Re-verifying ==="
bash verify.sh
