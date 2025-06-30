#!/bin/bash

# Auto Install Script for Python Bot Service
# Version 1.0
# Author: Your Name
# GitHub: your-repo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
  echo -e "${RED}Error: Script must be run as root${NC}" >&2
  exit 1
fi

# Variables
SERVICE_NAME="bot"
SCRIPT_PATH="/usr/local/sbin/bot.py"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
PYTHON_PATH=$(which python3 || which python)

# Check if Python is installed
if [ -z "$PYTHON_PATH" ]; then
  echo -e "${RED}Error: Python is not installed. Please install Python 3 first.${NC}"
  exit 1
fi

echo -e "${YELLOW}=== Python Bot Service Installer ===${NC}"

# Step 1: Create service file
echo -e "${GREEN}[1/4] Creating service file...${NC}"
cat > "$SERVICE_FILE" <<EOL
[Unit]
Description=Python Bot Service
After=network.target

[Service]
User=root
WorkingDirectory=$(dirname "$SCRIPT_PATH")
ExecStart=$PYTHON_PATH $SCRIPT_PATH
Restart=always
RestartSec=10
StandardOutput=syslog
StandardError=syslog
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOL

echo -e "Service file created at ${YELLOW}${SERVICE_FILE}${NC}"

# Step 2: Make script executable
echo -e "${GREEN}[2/4] Setting permissions...${NC}"
if [ -f "$SCRIPT_PATH" ]; then
  chmod +x "$SCRIPT_PATH"
  echo -e "Script permissions set for ${YELLOW}${SCRIPT_PATH}${NC}"
else
  echo -e "${YELLOW}Warning: Script file not found at ${SCRIPT_PATH}${NC}"
  echo -e "Please create your bot script manually after installation"
fi

# Step 3: Reload systemd
echo -e "${GREEN}[3/4] Reloading systemd daemon...${NC}"
systemctl daemon-reload
echo -e "Systemd daemon reloaded"

# Step 4: Enable and start service
echo -e "${GREEN}[4/4] Starting service...${NC}"
systemctl enable "$SERVICE_NAME.service"
systemctl start "$SERVICE_NAME.service"

# Verification
echo -e "\n${YELLOW}=== Installation Complete ===${NC}"
echo -e "Service ${GREEN}${SERVICE_NAME}${NC} has been installed and started"
echo -e "\nTo check status: ${YELLOW}systemctl status ${SERVICE_NAME}${NC}"
echo -e "To view logs: ${YELLOW}journalctl -u ${SERVICE_NAME} -f${NC}"
echo -e "To restart: ${YELLOW}systemctl restart ${SERVICE_NAME}${NC}"
echo -e "To stop: ${YELLOW}systemctl stop ${SERVICE_NAME}${NC}"

exit 0
