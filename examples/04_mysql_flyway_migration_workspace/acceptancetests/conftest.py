import json
import mysql.connector
import os
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
    return home_dir + '/E04db/create'


@fixture
def database_dropper_executable(home_dir):
    return home_dir + '/E04db/drop'


@fixture
def database_migrator_executable(home_dir):
    return home_dir + '/E04db/migrate'


@fixture
def database_checksum_executable(home_dir):
    return home_dir + '/E04db/checksum'


@fixture
def database_checksum_from_build(home_dir):
    return home_dir + '/E04db_migration_checksum'

