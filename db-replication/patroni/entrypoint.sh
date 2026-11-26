#!/bin/sh
# Patroni reads most of its settings from PATRONI_* variables (set in docker-compose.yaml); this
# only fills in the addresses other nodes use to reach this one, from its compose service name.
set -eu
: "${PATRONI_NAME:?set PATRONI_NAME (the node name, e.g. player-db-1)}"
export PATRONI_RESTAPI_CONNECT_ADDRESS="${PATRONI_NAME}:8008"
export PATRONI_POSTGRESQL_CONNECT_ADDRESS="${PATRONI_NAME}:5432"
exec patroni /etc/patroni/patroni.yml
