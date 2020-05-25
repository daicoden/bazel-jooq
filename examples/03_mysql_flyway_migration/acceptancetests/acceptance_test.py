import os

import pytest
from mysql.connector import MySQLConnection


def test_database_can_be_migrated(datasource_connection: MySQLConnection, database_creator_executable,
                                  database_dropper_executable, database_migrator_executable):
    if os.system(database_dropper_executable) != 0:
        pytest.fail('Drop database executable did not pass')

    if os.system(database_creator_executable) != 0:
        pytest.fail('Create database executable did not pass')

    if os.system(database_migrator_executable) != 0:
        pytest.fail('Migrate database did not pass')
    cursor = datasource_connection.cursor()
    cursor.execute('show tables from 03_mysql_flyway_migration')
    tables = cursor.fetchall()
    assert ('foos',) in tables
