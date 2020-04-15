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



