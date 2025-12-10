#!/bin/bash
# Script to filter logs by TOLE services

echo "Showing last 50 log lines for all TOLE services:"
journalctl -u tole-gunicorn.service -u prometheus.service -u grafana-server.service -n 50 --no-pager
