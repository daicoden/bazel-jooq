import json


def test_database_config(database_config):
    assert database_config == json.loads("""
        {
            "host": "localhost", 
            "port": 3306, 
            "username": "root", 
            "password": "", 
            "jdbc_connection_string": "jdbc:mysql://localhost:3306?serverTimezone=UTC"
        }
        """)


def test_database_is_migrated(datasource_connection, database_checksum_from_build):
    assert database_checksum_from_build
    cursor = datasource_connection.cursor()
    cursor.execute('show tables from 04_mysql_flyway_migration_workspace')
    tables = cursor.fetchall()
    assert ('foos',) in tables
