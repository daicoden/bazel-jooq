from mysql.connector import MySQLConnection

from copypastel_rules_database.db_tool import DbTool


def test_database_can_be_created(mysql_connection: MySQLConnection, mysql_db_tool: DbTool):
    cursor = mysql_connection.cursor()
    cursor.execute('DROP DATABASE IF EXISTS copypastel_rules_database')

    cursor = mysql_connection.cursor()
    cursor.execute('SHOW DATABASES')
    databases = cursor.fetchall()
    assert ('copypastel_rules_database',) not in databases

    mysql_db_tool.create_database('copypastel_rules_database')

    cursor = mysql_connection.cursor()
    cursor.execute('SHOW DATABASES')
    databases = cursor.fetchall()
    assert ('copypastel_rules_database',) in databases


def test_database_creation_is_idempotent(mysql_connection: MySQLConnection, mysql_db_tool: DbTool):
    cursor = mysql_connection.cursor()
    cursor.execute('DROP DATABASE IF EXISTS copypastel_rules_database')

    cursor = mysql_connection.cursor()
    cursor.execute('SHOW DATABASES')
    databases = cursor.fetchall()
    assert ('copypastel_rules_database',) not in databases

    mysql_db_tool.create_database('copypastel_rules_database')
    mysql_db_tool.create_database('copypastel_rules_database')

    cursor = mysql_connection.cursor()
    cursor.execute('SHOW DATABASES')
    databases = cursor.fetchall()
    assert ('copypastel_rules_database',) in databases


def test_database_can_be_dropped(mysql_connection: MySQLConnection, mysql_db_tool: DbTool):
    cursor = mysql_connection.cursor()
    cursor.execute('CREATE DATABASE IF NOT EXISTS copypastel_rules_database')

    cursor = mysql_connection.cursor()
    cursor.execute('SHOW DATABASES')
    databases = cursor.fetchall()
    assert ('copypastel_rules_database',) in databases

    mysql_db_tool.drop_database('copypastel_rules_database')

    cursor = mysql_connection.cursor()
    cursor.execute('SHOW DATABASES')
    databases = cursor.fetchall()
    assert ('copypastel_rules_database',) not in databases

def test_database_destruction_is_idempotent(mysql_connection: MySQLConnection, mysql_db_tool: DbTool):
    cursor = mysql_connection.cursor()
    cursor.execute('CREATE DATABASE IF NOT EXISTS copypastel_rules_database')

    cursor = mysql_connection.cursor()
    cursor.execute('SHOW DATABASES')
    databases = cursor.fetchall()
    assert ('copypastel_rules_database',) in databases

    mysql_db_tool.drop_database('copypastel_rules_database')
    mysql_db_tool.drop_database('copypastel_rules_database')

    cursor = mysql_connection.cursor()
    cursor.execute('SHOW DATABASES')
    databases = cursor.fetchall()
    assert ('copypastel_rules_database',) not in databases
