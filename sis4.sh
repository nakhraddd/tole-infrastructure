#!/bin/bash
set -e
set -x

echo "--- SIS 4: CONFIGURING SERVICES AND CRON ---"

echo "Creating systemd unit for Gunicorn..."
sudo tee /etc/systemd/system/tole-gunicorn.service > /dev/null <<EOF
[Unit]
Description=TOLE Gunicorn Daemon
After=network.target

[Service]
User=tole
Group=tole_app
WorkingDirectory=/var/www/tole
ExecStart=/usr/local/bin/gunicorn --workers 3 --bind 0.0.0.0:8000 tole_project.wsgi:application
Restart=on-failure
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s TERM \$MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

echo "Creating systemd unit for Prometheus..."
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=monitoring
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "Creating systemd unit for Grafana..."
sudo tee /etc/systemd/system/grafana-server.service > /dev/null <<EOF
[Unit]
Description=Grafana Server
After=network.target

[Service]
User=grafana
Group=monitoring
Type=simple
ExecStart=/usr/local/bin/grafana-server -homepath /usr/local/share/grafana -config /etc/grafana/grafana.ini
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd, enabling and starting services..."
sudo systemctl daemon-reload
sudo systemctl enable tole-gunicorn
sudo systemctl start tole-gunicorn
sudo systemctl enable prometheus
sudo systemctl start prometheus
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

echo "Creating maintenance scripts directory..."
sudo mkdir -p /opt/scripts

echo "Creating backup script..."
sudo tee /opt/scripts/backup.sh > /dev/null <<EOF
#!/bin/bash
BACKUP_DIR="/var/backups/tole"
DATE=\$(date +%Y-%m-%d-%H%M)
mkdir -p \$BACKUP_DIR

mysqldump -u root tole_db | gzip > \$BACKUP_DIR/tole_db-\$DATE.sql.gz
tar -czf \$BACKUP_DIR/tole_app-\$DATE.tar.gz /var/www/tole
EOF
sudo chmod +x /opt/scripts/backup.sh

echo "Creating cleanup script..."
sudo tee /opt/scripts/cleanup.sh > /dev/null <<EOF
#!/bin/bash
find /var/log/tole/ -name "*.log" -mtime +30 -exec rm -f {} \;
EOF
sudo chmod +x /opt/scripts/cleanup.sh

echo "Adding cron jobs..."
(crontab -l 2>/dev/null; echo "0 2 * * * /opt/scripts/backup.sh") | crontab -
(crontab -l 2>/dev/null; echo "0 4 * * * /opt/scripts/cleanup.sh") | crontab -

echo "--- SIS 4 COMPLETE ---"
