load("@gpk_rules_datasource//datasource:defs.bzl", "database", "datasource_configuration", "datasource_configuration_json")
load("@gpk_rules_datasource//flyway:defs.bzl", "migrated_database")

datasource_configuration(
    name = "mysql",
    host = "localhost",
    jdbc_connection_string = "jdbc:mysql://localhost:3306?serverTimezone=UTC",
    jdbc_connector = "@maven//:mysql_mysql_connector_java",
    password = "",
    port = "3306",
    username = "root",
)

migrated_database(
    name = "03_mysql_flyway_migration",
    datasource_configuration = ":mysql",
    migrations = glob(["migrations/*.sql"]),
)

load(
    "@pip//:requirements.bzl",
    pip_require = "requirement",
)
load("@gpk_rules_pytest//:defs.bzl", "pytest_test")

datasource_configuration_json(
    name = "mysql_config",
    out = "mysql_config.json",
    datasource_configuration = ":mysql",
)

pytest_test(
    name = "acceptance",
    srcs = glob(["acceptancetests/*.py"]),
    data = [
        "mysql_config.json",
        ":create_03_mysql_flyway_migration",
        ":drop_03_mysql_flyway_migration",
        ":migrate_03_mysql_flyway_migration",
    ],
    deps = [
        pip_require("pytest"),
        pip_require("mysql-connector-python"),
        # https://bugs.mysql.com/bug.php?id=98225
        pip_require("dnspython"),
    ],
)

test_suite(
    name = "suite",
    tests = [":acceptance"],
    visibility = ["//visibility:public"],
)
