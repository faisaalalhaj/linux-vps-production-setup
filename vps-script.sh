#!/bin/bash

###########################################################
# Linux VPS Production Setup
# Ubuntu 22.04+
#
# Author: Faisal Alhaj
# Version: 1.0.0
###########################################################

set -e

############################
# VARIABLES
############################

NEW_USER="deploy"
TIMEZONE="Asia/Riyadh"
SWAP_SIZE="2G"
SSH_PORT="22"

############################
# COLORS
############################

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

############################
# CHECK ROOT
############################

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root${NC}"
  exit 1
fi

############################
# UPDATE SYSTEM
############################

echo -e "${GREEN}Updating system...${NC}"

apt update && apt upgrade -y

############################
# INSTALL PACKAGES
############################

echo -e "${GREEN}Installing packages...${NC}"

apt install -y \
curl \
wget \
git \
unzip \
vim \
htop \
ufw \
fail2ban \
nginx \
sudo

############################
# CREATE USER
############################

echo -e "${GREEN}Creating deploy user...${NC}"

if id "$NEW_USER" &>/dev/null; then
    echo "User already exists"
else
    adduser --disabled-password --gecos "" $NEW_USER

    usermod -aG sudo $NEW_USER

    echo "$NEW_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$NEW_USER

    chmod 440 /etc/sudoers.d/$NEW_USER

    mkdir -p /home/$NEW_USER/.ssh

    chmod 700 /home/$NEW_USER/.ssh

    touch /home/$NEW_USER/.ssh/authorized_keys

    chmod 600 /home/$NEW_USER/.ssh/authorized_keys

    chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh

    echo "User created successfully"
fi

############################
# SSH CONFIG
############################

echo -e "${GREEN}Configuring SSH...${NC}"

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

sed -i "s/#PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config

sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config

sed -i "s/#PubkeyAuthentication yes/PubkeyAuthentication yes/g" /etc/ssh/sshd_config

sed -i "s/#Port 22/Port $SSH_PORT/g" /etc/ssh/sshd_config

systemctl restart ssh || systemctl restart sshd

############################
# FIREWALL
############################

echo -e "${GREEN}Configuring firewall...${NC}"

ufw allow $SSH_PORT/tcp
ufw allow 80/tcp
ufw allow 443/tcp

ufw --force enable

############################
# FAIL2BAN
############################

echo -e "${GREEN}Starting Fail2Ban...${NC}"

systemctl enable fail2ban
systemctl start fail2ban

############################
# TIMEZONE
############################

echo -e "${GREEN}Setting timezone...${NC}"

timedatectl set-timezone $TIMEZONE

############################
# SWAP
############################

echo -e "${GREEN}Creating swap...${NC}"

if swapon --show | grep -q "/swapfile"; then
    echo "Swap already exists"
else
    fallocate -l $SWAP_SIZE /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile

    echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

############################
# ENABLE SERVICES
############################

echo -e "${GREEN}Enabling services...${NC}"

systemctl enable nginx
systemctl enable fail2ban

############################
# FINAL INFO
############################

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}VPS Production Setup Completed${NC}"
echo -e "${GREEN}=========================================${NC}"

echo ""
echo "User: $NEW_USER"
echo "Timezone: $TIMEZONE"
echo "Swap: $SWAP_SIZE"

echo ""
echo "Memory Usage:"
free -h

echo ""
echo "Disk Usage:"
df -h

echo ""
echo "Firewall Status:"
ufw status

echo ""
echo "Fail2Ban Status:"
systemctl status fail2ban --no-pager

echo ""
echo -e "${GREEN}IMPORTANT:${NC}"
echo "1. Add your SSH public key to:"
echo "/home/$NEW_USER/.ssh/authorized_keys"

echo ""
echo "2. Then connect using:"
echo "ssh $NEW_USER@SERVER_IP"

echo ""
echo "3. Root login & password auth are disabled"

echo ""
echo -e "${GREEN}Done.${NC}"