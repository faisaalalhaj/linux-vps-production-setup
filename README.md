# Linux VPS Production Setup

Minimal production-ready VPS setup script for Ubuntu servers.

## Features

- System update
- Secure SSH configuration
- Disable root login
- Disable password authentication
- Create deploy user
- Passwordless sudo
- UFW firewall
- Fail2Ban protection
- Swap creation
- Nginx installation
- Production-ready base setup

---

# Supported OS

- Ubuntu 22.04+
- Ubuntu 24.04+

---

# Installation

## 1. Clone Repository

```bash
git clone YOUR_REPO_URL
```

---

## 2. Enter Project

```bash
cd YOUR_REPO
```

---

## 3. Make Script Executable

```bash
chmod +x setup-vps.sh
```

---

## 4. Run Script

```bash
sudo ./setup-vps.sh
```

---

# Default Variables

Inside `setup-vps.sh`

```bash
NEW_USER="deploy"
TIMEZONE="Asia/Riyadh"
SWAP_SIZE="2G"
SSH_PORT="22"
```

---

# SSH Key Setup

Add your SSH public key:

```bash
nano /home/deploy/.ssh/authorized_keys
```

Paste your public key.

---

# Connect To Server

```bash
ssh deploy@SERVER_IP
```

---

# Installed Packages

- curl
- wget
- git
- unzip
- vim
- htop
- ufw
- fail2ban
- nginx
- sudo

---

# Security

The script automatically:

- Disables root login
- Disables password authentication
- Enables firewall
- Enables Fail2Ban

---

# Open Ports

- 22 (SSH)
- 80 (HTTP)
- 443 (HTTPS)

---

# Verify Services

## Firewall

```bash
ufw status
```

## Fail2Ban

```bash
systemctl status fail2ban
```

## Nginx

```bash
systemctl status nginx
```

---

# Check Swap

```bash
free -h
```

---
