#!/usr/bin/env bash

CURRENT_NODE_HEIGHT=$(raven-cli -datadir=/root/.ravencore/data getblockchaininfo | jq -r .blocks)
if ! egrep -o "^[0-9]+$" <<< "$CURRENT_NODE_HEIGHT" &>/dev/null; then
  echo "Daemon not working correct..."
  exit 1
else
  curl -f  http://localhost:3001/api/sync
  exit
fi
