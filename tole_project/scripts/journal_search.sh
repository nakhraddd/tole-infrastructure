#!/bin/bash
# Script to search journalctl logs easily

echo "Searching journal for service status messages..."
if [ -z "$1" ]; then
    echo "Usage: $0 <search_term>"
    journalctl -n 20 --output=short-iso
else
    journalctl -u tole-gunicorn.service -u prometheus.service -u grafana-server.service --since "1 hour ago" | grep -i "$1"
fi
