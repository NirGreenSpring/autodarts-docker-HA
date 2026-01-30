#!/bin/sh
set -e

# Home Assistant persistent storage is mounted at /data
mkdir -p /data/autodarts
mkdir -p /root/.config

# Mirror docker-compose volume: ./config:/root/.config/autodarts
# Ensure Autodarts writes config into persistent storage
rm -rf /root/.config/autodarts 2>/dev/null || true
ln -s /data/autodarts /root/.config/autodarts

exec "$@"