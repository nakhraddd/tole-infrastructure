#!/bin/bash
# Script to filter logs specifically for TOLE related services

echo "Showing last 50 log lines for TOLE application services..."
# Filters logs for the three main services defined in the SIS 4 unit files.
journalctl -u tole-gunicorn.service -u prometheus.service -u grafana-server.service -n 50 --no-pager
