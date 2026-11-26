#!/bin/sh
# Run once by Patroni on the node that initialises the cluster (never on replicas, which clone it).
# Creates the service's own role and database; the service runs its migrations on start.
# $1 is a connection string for the superuser.
set -eu
: "${APP_DB_USER:?}" "${APP_DB_PASSWORD:?}" "${APP_DB_NAME:?}"
psql "$1" -v ON_ERROR_STOP=1 -v user="$APP_DB_USER" -v password="$APP_DB_PASSWORD" -v db="$APP_DB_NAME" <<'SQL'
CREATE ROLE :"user" LOGIN PASSWORD :'password';
CREATE DATABASE :"db" OWNER :"user";
SQL
echo "post_bootstrap: role $APP_DB_USER and database $APP_DB_NAME created"
