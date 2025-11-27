#!/bin/bash
set -x

echo "--- FIXING DEPLOYMENT ---"

# 1. FIX GUNICORN (Move Django project to the service directory)
echo "Deploying Django code to /var/www/tole..."
# Copy the project folder created by setup_project.sh
if [ -d "tole_project" ]; then
    sudo cp -r tole_project /var/www/tole/
    sudo cp manage.py /var/www/tole/
    # Fix permissions so the 'tole' user can read it
    sudo chown -R tole:tole_app /var/www/tole
else
    echo "ERROR: Could not find 'tole_project' in current directory. Did you run setup_project.sh?"
    exit 1
fi

# 2. FIX GRAFANA (Install missing assets: public folder and conf)
echo "Installing Grafana assets..."
# We need to re-download specifically to get the 'public' and 'conf' folders
cd /tmp
rm -rf grafana*
wget -q https://dl.grafana.com/oss/release/grafana-11.1.0.linux-amd64.tar.gz
tar -xf grafana-11.1.0.linux-amd64.tar.gz

# Create the homepath directory defined in your service file
sudo mkdir -p /usr/local/share/grafana
# Move the required asset folders
sudo cp -r grafana-*/public /usr/local/share/grafana/
sudo cp -r grafana-*/conf /usr/local/share/grafana/

# Fix the config file path
sudo mkdir -p /etc/grafana
# Copy the default config as the base
sudo cp /usr/local/share/grafana/conf/defaults.ini /etc/grafana/grafana.ini
# Ensure ownership
sudo chown -R grafana:monitoring /usr/local/share/grafana
sudo chown -R grafana:monitoring /etc/grafana

# 3. RESTART SERVICES
echo "Restarting services..."
sudo systemctl daemon-reload
sudo systemctl restart tole-gunicorn
sudo systemctl restart grafana-server

echo "--- REPAIR COMPLETE ---"
# Check status immediately
sudo systemctl status tole-gunicorn grafana-server --no-pager
