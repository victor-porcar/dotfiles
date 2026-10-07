#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

reset() { docker-compose --project-directory "$1" down -v; }

read -rp "This stops every local-env service and DELETES all its data. Continue? [y/N] " answer
[[ "$answer" =~ ^[yY]$ ]] || { echo "Cancelled"; exit 0; }

reset redis-cluster
reset solr
