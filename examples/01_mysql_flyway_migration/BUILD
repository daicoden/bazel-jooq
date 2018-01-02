package(default_visibility = ["//:__subpackages__"])

load("@sqldatabase//:defs.bzl", "mysql_datasource_configuration", "sqlite_datasource_configuration")
load("@flyway//:defs.bzl", "database")

sh_test(
    name = "test_mysql",
    srcs = ["test.sh"],
    data = [":created_mysql_flyway_migration"],
    size = "small",
)

#sh_test(
#    name = "test_sqlite",
#    srcs = ["test.sh"],
#    data = [":created_sqlite_flyway_migration"],
#    size = "small",
#)

datasource_configuration_mysql = mysql_datasource_configuration(
    name = "mysql",
    host="localhost",
    port="3306",
    username="root",
    password="",
)

database(
    name = "mysql_flyway_migration",
    datasource_configuration = datasource_configuration_mysql
)

datasource_configuration_sqlite = sqlite_datasource_configuration(
    name = "sqlite",
    file = "/tmp/sqlite_flyway_migration.db",
)

#database(
#    name = "sqlite_flyway_migration",
#    datasource_configuration = datasource_configuration_sqlite
#)

test_suite(name = "suite")