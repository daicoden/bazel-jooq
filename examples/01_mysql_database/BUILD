load("@sqldatabase//:defs.bzl", "mysql_datasource_configuration")
load("@flyway//:defs.bzl", "database")

datasource_configuration = mysql_datasource_configuration(
    name = "mysql",
    host="localhost",
    port="3306",
    username="root",
    password="",
)

database(
    name = "mysql_flyway_migration",
    datasource_configuration = datasource_configuration
)

load("@pip//:requirements.bzl", pip_dep="requirement")
load("//test:defs.bzl", "py_db_test")

py_db_test(
    name="unit_test",
    srcs=[glob(['unittests/*.py'])],
    deps=[
        pip_require(':pytest'),
        pip_require(':mysql-connector')
    ],
)

test_suite(name = "suite")
