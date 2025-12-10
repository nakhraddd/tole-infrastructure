#!/bin/bash
# Simple journal search helper
if [ -z "$1" ]; then
  echo "Usage: $0 PATTERN [SINCE]"
  echo "Example: $0 'Failed password' '1d'"
  exit 1
fi
PATTERN="$1"
SINCE="${2:--1h}"
echo "Searching journal since $SINCE for pattern: $PATTERN"
journalctl -S "$SINCE" -o short-iso | grep -E --color=auto "$PATTERN"
