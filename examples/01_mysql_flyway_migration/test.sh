#!/usr/bin/env bash

set -e
set -x

# If this fails, maybe restart bazel, it could have started without full path (before .bash_rc is loaded)
which mysql


mysql --protocol tcp -u root -e "show tables from mysql_flyway_migration"
#mysql --protocol tcp -u root -e "select * from mysql_flyway_migration.foos"
#mysql --protocol tcp -u root -e "insert into mysql_flyway_migration.foos set value = 'bar'"
mysql --protocol tcp -u root -e "drop database if exists mysql_flyway_migration"
