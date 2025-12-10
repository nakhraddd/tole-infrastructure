#!/bin/bash
# Filter journal by one or more systemd services.
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 service_name [service_name2 ...] [SINCE]"
  echo "Example: $0 sshd nginx '2h'"
  exit 1
fi

# Last argument may be a SINCE spec if it looks like time (contains digits or h/d)
SINCE="-1h"
if [[ "$@" =~ [0-9]+[smhd]?$ ]]; then
  SINCE="${!#}"
  set -- "${@:1:$(($#-1))}"
fi

for svc in "$@"; do
  echo "--- Logs for service: $svc (since $SINCE) ---"
  journalctl -u "$svc" -S "$SINCE" -o short-iso | tail -n +1
done
