#!/bin/bash
set -e
set -x

echo "--- SIS 3: INSTALLING PACKAGES AND FIREWALL ---"

echo "Updating apt cache..."
sudo apt-get update

echo "Installing system packages..."
# Added 'pkg-config' (required for mysqlclient)
sudo apt-get install -y build-essential python3-pip python3-dev \
    mysql-server libmysqlclient-dev ufw wget pkg-config

echo "Installing Python packages..."
# Using --break-system-packages to bypass PEP 668 on Ubuntu 24.04
sudo pip3 install django gunicorn mysqlclient prometheus-client --break-system-packages

echo "Downloading and installing Prometheus..."
cd /tmp
rm -rf prometheus* # Cleanup previous runs
wget -q https://github.com/prometheus/prometheus/releases/download/v2.53.1/prometheus-2.53.1.linux-amd64.tar.gz
tar -xvf prometheus-2.53.1.linux-amd64.tar.gz
sudo mv prometheus-2.53.1.linux-amd64/prometheus /usr/local/bin/
sudo mv prometheus-2.53.1.linux-amd64/promtool /usr/local/bin/
sudo mkdir -p /etc/prometheus
sudo mv prometheus-2.53.1.linux-amd64/prometheus.yml /etc/prometheus/
sudo chown prometheus:monitoring /usr/local/bin/prometheus
sudo chown prometheus:monitoring /usr/local/bin/promtool

echo "Downloading and installing Grafana..."
cd /tmp
rm -rf grafana* # Cleanup previous runs
wget -q https://dl.grafana.com/oss/release/grafana-11.1.0.linux-amd64.tar.gz
tar -xvf grafana-11.1.0.linux-amd64.tar.gz

# UPDATED: Moving the main 'grafana' binary is now required for v11+
sudo mv grafana-*/bin/grafana /usr/local/bin/
sudo mv grafana-*/bin/grafana-server /usr/local/bin/
sudo mv grafana-*/bin/grafana-cli /usr/local/bin/

# Ensure ownership for all three
sudo chown -R grafana:monitoring /usr/local/bin/grafana
sudo chown -R grafana:monitoring /usr/local/bin/grafana-server
sudo chown -R grafana:monitoring /usr/local/bin/grafana-cli

echo "Configuring firewall (UFW)..."
# Adding '|| true' to prevent script failure if UFW throws warnings in WSL
sudo ufw default deny incoming || true
sudo ufw default allow outgoing || true
sudo ufw allow ssh || true
sudo ufw allow http || true
sudo ufw allow https || true
sudo ufw allow 3000/tcp || true
sudo ufw allow 9090/tcp || true
sudo ufw allow 8000/tcp || true

# Detect if running in WSL to avoid 'ufw enable' issues
if grep -q Microsoft /proc/version; then
    echo "Running in WSL: Skipping 'ufw enable' to prevent hanging."
else
    sudo ufw --force enable
fi

echo "Running smoke tests..."
python3 -m django --version
gunicorn --version
mysql --version
prometheus --version
grafana-server -v

echo "Checking MySQL service..."
sudo systemctl status mysql --no-pager

echo "--- SIS 3 COMPLETE ---"
