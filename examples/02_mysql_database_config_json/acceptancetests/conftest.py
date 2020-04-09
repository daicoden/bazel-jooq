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
        # Figured this out through randomly looking for a variable which described where in the
        # build tree the test was... this makes it the same as if it was run from the example
        # space, or from the parent directory
        build_path = "/".join(os.environ['TEST_BINARY'].split("/")[0:-1])
        return os.environ['PWD'] + '/' + build_path
    else:
        return os.getcwd()


@fixture
def database_config(home_dir):
    with open(home_dir + '/mysql_config.json', 'r') as f:
        yield json.loads(f.read())


@fixture
def database_creator_config_file_executable(home_dir):
    return home_dir + '/create-02_mysql_database_config_json-exe'


@fixture
def database_dropper_config_file_executable(home_dir):
    return home_dir + '/drop-02_mysql_database_config_json-exe'


@fixture
def database_creator_no_config_file_executable(home_dir):
    return home_dir + '/create-02_mysql_database_no_config_json-exe'


@fixture
def database_dropper_no_config_file_executable(home_dir):
    return home_dir + '/drop-02_mysql_database_no_config_json-exe'
