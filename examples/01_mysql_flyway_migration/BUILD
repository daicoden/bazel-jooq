package(default_visibility = ["//:__subpackages__"])

load("@sqldatabase//:defs.bzl", "mysql_datasource_configuration")
load("@flyway//:defs.bzl", "database")

sh_test(
    name = "test",
    srcs = ["test.sh"],
    data = [":created_mysql_flyway_migration"],
    size = "small",
)

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

test_suite(name = "suite")