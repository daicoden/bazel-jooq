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
def database_config_raw(home_dir):
    with open(home_dir + '/mysql_config.json', 'r') as f:
        yield f.read()

@fixture
def database_config(database_config_raw):
    return json.loads(database_config_raw)


@fixture
def database_creator_executable(home_dir):
    return home_dir + '/create_03_mysql_flyway_migration_exe'


@fixture
def database_dropper_executable(home_dir):
    return home_dir + '/drop_03_mysql_flyway_migration_exe'

@fixture
def database_migrator_executable(home_dir):
    return home_dir + '/migrate_03_mysql_flyway_migration_exe'
