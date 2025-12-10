#!/bin/bash
# Script to continuously monitor journal for errors

echo "Watching journal for errors or failures..."
# Filter for critical errors (E.G., 'ERR', 'FAIL', 'CRIT')
journalctl -f -p err..crit
