import json
import os

import mysql.connector
from pytest import fixture


@fixture
def datasource_connection(database_config):
    return mysql.connector.connect(
            host=database_config["host"],
            port=database_config["port"],
            user=database_config["username"],
            passwd=database_config["password"],
    )


@fixture
def home_dir():
    if 'PWD' in os.environ:
        return os.environ['PWD']
    else:
        return os.getcwd()


@fixture
def database_config(home_dir):
    with open(home_dir + '/mysql_config.json', 'r') as f:
        yield json.loads(f.read())


@fixture
def database_creator_executable(home_dir):
    return home_dir + '/create-01_mysql_database-exe'
