#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

start() { docker-compose --project-directory "$1" up -d; }

start redis-cluster
start solr
