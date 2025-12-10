#!/bin/bash
# Continuous journal watcher that alerts (via logger) on matching PATTERN
if [ -z "$1" ]; then
  echo "Usage: $0 PATTERN [PRIORITY]"
  echo "Example: $0 'sudo: .*session opened' auth.notice"
  exit 1
fi
PATTERN="$1"
PRIORITY="${2:-auth.notice}"

echo "Starting journal watch for pattern: $PATTERN"
journalctl -f -o short-iso | while IFS= read -r line; do
  echo "$line" | grep -E --quiet "$PATTERN" && logger -p "$PRIORITY" "journal-watch-alert: $line"
done
