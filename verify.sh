#!/bin/bash
SERVER_IP="163.192.117.50"
SSH_KEY="$HOME/.ssh/lab1-key.pem"
SSH_OPTS="-i $SSH_KEY -o StrictHostKeyChecking=no -o ConnectTimeout=10"
PASS=0
FAIL=0

check() {
    local label="$1"
    local result="$2"
    if [ "$result" = "pass" ]; then
        echo "  [PASS] $label"
        PASS=$((PASS + 1))
    else
        echo "  [FAIL] $label"
        FAIL=$((FAIL + 1))
    fi
}

echo "--- Connectivity ---"
ssh $SSH_OPTS "sysadmin@$SERVER_IP" "echo ok" &>/dev/null && \
    check "SSH access as sysadmin" pass || check "SSH access as sysadmin" fail

echo "--- Deployment user ---"
ssh $SSH_OPTS "sysadmin@$SERVER_IP" "id deployer" &>/dev/null && \
    check "deployer user exists" pass || check "deployer user exists" fail

echo "--- Services ---"
for svc in nginx ssh fail2ban rsyslog docker cron; do
    status=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "sudo systemctl is-active $svc" 2>/dev/null)
    [ "$status" = "active" ] && check "$svc running" pass || check "$svc running" fail
done

echo "--- Firewall ---"
ufw_status=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "sudo ufw status | head -1" 2>/dev/null)
[[ "$ufw_status" == *"active"* ]] && check "UFW enabled" pass || check "UFW enabled" fail

echo "--- Web Service ---"
http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "http://$SERVER_IP" 2>/dev/null)
[ "$http_code" = "200" ] && check "HTTP 200 from $SERVER_IP" pass || check "HTTP 200 from $SERVER_IP (got $http_code)" fail

echo "--- Container monitoring ---"
metrics_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "http://$SERVER_IP:9100/metrics" 2>/dev/null)
[ "$metrics_code" = "200" ] && check "containerized node_exporter reachable" pass || check "containerized node_exporter reachable (got $metrics_code)" fail
ssh $SSH_OPTS "sysadmin@$SERVER_IP" "sudo docker ps --filter name=node_exporter --format '{{.Status}}'" 2>/dev/null | grep -q "Up" && \
    check "node_exporter container running" pass || check "node_exporter container running" fail

echo "--- Backup directory ---"
ssh $SSH_OPTS "sysadmin@$SERVER_IP" "test -d /var/backups/webserver01" &>/dev/null && \
    check "backup directory exists" pass || check "backup directory exists" fail

echo "--- Scheduled jobs ---"
ssh $SSH_OPTS "sysadmin@$SERVER_IP" "sudo crontab -l 2>/dev/null | grep -q apt-get" && \
    check "scheduled apt update cron job exists" pass || check "scheduled apt update cron job exists" fail

echo "--- Security ---"
root_ssh=$(ssh $SSH_OPTS "root@$SERVER_IP" "echo ok" 2>&1)
[[ "$root_ssh" != "ok" ]] && check "root SSH login blocked" pass || check "root SSH login blocked" fail

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
