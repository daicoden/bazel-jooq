import click
import mysql.connector
from mysql.connector import MySQLConnection


class DbTool:
    def __init__(self, connection: MySQLConnection):
        self.connection = connection

    def create_database(self, database_name):
        cursor = self.connection.cursor()
        cursor.execute('CREATE DATABASE IF NOT EXISTS %s' % database_name)

    def drop_database(self, database_name):
        cursor = self.connection.cursor()
        cursor.execute('DROP DATABASE IF EXISTS %s' % database_name)


def connect_mysql(host, port, username, password):
    return DbTool(mysql.connector.connect(host=host, port=port, user=username, passwd=password))


@click.command()
@click.option('--host')
@click.option('--port')
@click.option('--username')
@click.option('--password')
@click.option('--dbname')
def create_database(host, port, username, password, dbname):
    tools = connect_mysql(host, port, username, password)
    tools.create_database(dbname)


if __name__ == "__main__":
    create_database()
