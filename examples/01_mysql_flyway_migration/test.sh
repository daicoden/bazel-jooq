#!/usr/bin/env bash

set -e
set -x

# Todo read database configuration from file?
which mysql
#mysql --protocol tcp -u root -e "select * from mysql_flyway_migration.foos"
#mysql --protocol tcp -u root -e "insert into mysql_flyway_migration.foos set value = 'bar'"
