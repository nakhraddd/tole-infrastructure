#!/bin/bash
set -e
set -x

echo "--- SIS 2: CREATING USERS AND PERMISSIONS ---"

echo "Creating groups..."
sudo groupadd --system tole_app || echo "Group tole_app already exists"
sudo groupadd --system monitoring || echo "Group monitoring already exists"

echo "Creating service users..."
sudo useradd --system --no-create-home --gid tole_app tole || echo "User tole already exists"
sudo useradd --system --no-create-home --gid monitoring prometheus || echo "User prometheus already exists"
sudo useradd --system --no-create-home --gid monitoring grafana || echo "User grafana already exists"

echo "Creating admin and automation users..."
sudo useradd -m -s /bin/bash -G sudo tole_admin || echo "User tole_admin already exists"
sudo useradd -m -s /bin/bash automation_bot || echo "User automation_bot already exists"

echo "Creating application directories..."
sudo mkdir -p /var/www/tole
sudo mkdir -p /var/log/tole
sudo mkdir -p /etc/tole

echo "Setting application directory permissions..."
sudo chown -R tole:tole_app /var/www/tole
sudo chown -R tole:tole_app /var/log/tole
sudo chown -R tole:tole_app /etc/tole
sudo chmod -R 775 /var/www/tole
sudo chmod -R 775 /var/log/tole
sudo chmod -R 775 /etc/tole

echo "Creating monitoring directories..."
sudo mkdir -p /var/lib/prometheus
sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/grafana
sudo mkdir -p /etc/grafana

echo "Setting monitoring directory permissions..."
sudo chown -R prometheus:monitoring /var/lib/prometheus
sudo chown -R prometheus:monitoring /etc/prometheus
sudo chown -R grafana:monitoring /var/lib/grafana
sudo chown -R grafana:monitoring /etc/grafana

echo "Setting up SSH for automation_bot..."
sudo mkdir -p /home/automation_bot/.ssh
sudo touch /home/automation_bot/.ssh/authorized_keys
sudo chown -R automation_bot:automation_bot /home/automation_bot/.ssh
sudo chmod 700 /home/automation_bot/.ssh
sudo chmod 600 /home/automation_bot/.ssh/authorized_keys
echo "# Add your SSH public key here for the automation_bot" | sudo tee /home/automation_bot/.ssh/authorized_keys > /dev/null

echo "Granting passwordless sudo to automation_bot..."
sudo echo "automation_bot ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/automation_bot
sudo chmod 0440 /etc/sudoers.d/automation_bot

echo "--- SIS 2 COMPLETE ---"
