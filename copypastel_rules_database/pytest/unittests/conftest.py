import mysql.connector
from pytest import fixture

from copypastel_rules_database.db_tool import DbTool


@fixture
def mysql_connection():
    return mysql.connector.connect(
            host="localhost",
            port="3306",
            user="root",
            passwd="",
    )


@fixture
def mysql_db_tool(mysql_connection):
    return DbTool(mysql_connection)
