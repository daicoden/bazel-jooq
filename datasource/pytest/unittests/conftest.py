import mysql.connector
from pytest import fixture

from copypastel_rules_datasource.db_tool import DbTool


@fixture
def mysql_connection():
    connection = mysql.connector.connect(
            host="localhost",
            port=3306,
            user="root",
            passwd="",
    )
    yield connection
    connection.close()


@fixture
def mysql_db_tool(mysql_connection):
    return DbTool(mysql_connection)

@fixture
def database_config():
    return """
    datasource_name:
        host: localhost
        port: 3306
        username: "root"
        password: ""
        jdbc_connection_string: ""
    """
