#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/update-system.sh"
bash "$SCRIPT_DIR/install-packages.sh"
bash "$SCRIPT_DIR/create-user.sh" deploy
bash "$SCRIPT_DIR/configure-firewall.sh"
bash "$SCRIPT_DIR/configure-service.sh"
bash "$SCRIPT_DIR/generate-logs.sh"

echo "All bash automation steps complete."
