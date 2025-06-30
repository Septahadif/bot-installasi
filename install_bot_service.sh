#!/bin/bash

# Auto Install Script for Python Bot Service
# Version 1.1
# Author: Your Name

# Output colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Must run as root
if [ "$(id -u)" -ne 0 ]; then
  echo -e "${RED}Error: This script must be run as root${NC}"
  exit 1
fi

# Config
SERVICE_NAME="bot"
SCRIPT_PATH="/usr/local/sbin/bot.py"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
PYTHON_PATH=$(which python3 || which python)

# Check Python
if [ -z "$PYTHON_PATH" ]; then
  echo -e "${RED}Error: Python 3 is not installed.${NC}"
  exit 1
fi

echo -e "${YELLOW}=== Installing Python Bot as systemd service ===${NC}"

# Step 1: Verify bot.py exists
if [ ! -f "$SCRIPT_PATH" ]; then
  echo -e "${RED}Error: ${SCRIPT_PATH} not found. Please copy your bot script there first.${NC}"
  exit 1
fi

# Step 2: Create systemd service file
echo -e "${GREEN}[1/4] Creating systemd service...${NC}"
cat > "$SERVICE_FILE" <<EOL
[Unit]
Description=Python Bot Service
After=network.target

[Service]
User=root
WorkingDirectory=/usr/local/sbin
ExecStart=$PYTHON_PATH $SCRIPT_PATH
ExecStartPre=/bin/test -f $SCRIPT_PATH
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOL

echo -e "Created: ${YELLOW}${SERVICE_FILE}${NC}"

# Step 3: Set permissions
echo -e "${GREEN}[2/4] Setting permissions...${NC}"
chmod +x "$SCRIPT_PATH"
echo -e "Executable: ${YELLOW}${SCRIPT_PATH}${NC}"

# Step 4: Reload and start service
echo -e "${GREEN}[3/4] Reloading systemd daemon...${NC}"
systemctl daemon-reexec
systemctl daemon-reload

echo -e "${GREEN}[4/4] Enabling and restarting service...${NC}"
systemctl enable "${SERVICE_NAME}.service"
systemctl restart "${SERVICE_NAME}.service"

# Final output
echo -e "\n${YELLOW}=== Installation Complete ===${NC}"
echo -e "Service ${GREEN}${SERVICE_NAME}${NC} is running."
echo -e "Check status : ${YELLOW}systemctl status ${SERVICE_NAME}${NC}"
echo -e "View logs    : ${YELLOW}journalctl -u ${SERVICE_NAME} -f${NC}"
echo -e "Restart      : ${YELLOW}systemctl restart ${SERVICE_NAME}${NC}"
echo -e "Stop         : ${YELLOW}systemctl stop ${SERVICE_NAME}${NC}"

exit 0
