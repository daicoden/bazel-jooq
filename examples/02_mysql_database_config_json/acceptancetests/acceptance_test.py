import os

import pytest
from mysql.connector import MySQLConnection


def test_database_can_be_created(datasource_connection: MySQLConnection, database_creator_config_file_executable):
    cursor = datasource_connection.cursor()
    cursor.execute('DROP DATABASE IF EXISTS 02_mysql_database_config_json')

    cursor = datasource_connection.cursor()
    cursor.execute('SHOW DATABASES')
    databases = cursor.fetchall()
    assert ('02_mysql_database_config_json',) not in databases

    if os.system(database_creator_config_file_executable) != 0:
        pytest.fail('Create database executable did not pass')

    cursor = datasource_connection.cursor()
    cursor.execute('SHOW DATABASES')
    databases = cursor.fetchall()
    assert ('02_mysql_database_config_json',) in databases


def test_database_can_be_deleted(datasource_connection: MySQLConnection, database_dropper_config_file_executable):
    cursor = datasource_connection.cursor()
    cursor.execute('CREATE DATABASE IF NOT EXISTS 02_mysql_database_config_json')

    cursor = datasource_connection.cursor()
    cursor.execute('SHOW DATABASES')
    databases = cursor.fetchall()
    assert ('02_mysql_database_config_json',) in databases

    if os.system(database_dropper_config_file_executable) != 0:
        pytest.fail('Drop database executable did not pass')

    cursor = datasource_connection.cursor()
    cursor.execute('SHOW DATABASES')
    databases = cursor.fetchall()
    assert ('02_mysql_database_config_json',) not in databases


def test_database_can_be_created_with_default(datasource_connection: MySQLConnection,
                                              database_creator_no_config_file_executable):
    cursor = datasource_connection.cursor()
    cursor.execute('DROP DATABASE IF EXISTS 02_mysql_database_no_config_json')

    cursor = datasource_connection.cursor()
    cursor.execute('SHOW DATABASES')
    databases = cursor.fetchall()
    assert ('02_mysql_database_no_config_json',) not in databases

    if os.system(database_creator_no_config_file_executable) != 0:
        pytest.fail('Create database executable did not pass')

    cursor = datasource_connection.cursor()
    cursor.execute('SHOW DATABASES')
    databases = cursor.fetchall()
    assert ('02_mysql_database_no_config_json',) in databases


def test_database_can_be_deleted_with_default(datasource_connection: MySQLConnection,
                                              database_dropper_no_config_file_executable):
    cursor = datasource_connection.cursor()
    cursor.execute('CREATE DATABASE IF NOT EXISTS 02_mysql_database_no_config_json')

    cursor = datasource_connection.cursor()
    cursor.execute('SHOW DATABASES')
    databases = cursor.fetchall()
    assert ('02_mysql_database_no_config_json',) in databases

    if os.system(database_dropper_no_config_file_executable) != 0:
        pytest.fail('Drop database executable did not pass')

    cursor = datasource_connection.cursor()
    cursor.execute('SHOW DATABASES')
    databases = cursor.fetchall()
    assert ('02_mysql_database_no_config_json',) not in databases
