import os

import pytest
from mysql.connector import MySQLConnection


def test_database_can_be_created(datasource_connection: MySQLConnection, database_creator_executable):
    cursor = datasource_connection.cursor()
    cursor.execute('DROP DATABASE IF EXISTS 01_mysql_database')

    cursor = datasource_connection.cursor()
    cursor.execute('SHOW DATABASES')
    databases = cursor.fetchall()
    assert ('01_mysql_database',) not in databases

    if os.system(database_creator_executable) != 0:
        pytest.fail('Create database executable did not pass')

    cursor = datasource_connection.cursor()
    cursor.execute('SHOW DATABASES')
    databases = cursor.fetchall()
    assert ('01_mysql_database',) in databases


def test_database_can_be_deleted():
    pass
