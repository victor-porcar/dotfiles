#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

stop() { docker-compose --project-directory "$1" down; }

stop redis-cluster
stop solr
