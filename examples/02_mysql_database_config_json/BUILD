exports_files(["database.json"])

load("@gpk_rules_datasource//datasource:defs.bzl", "database", "datasource_configuration", "datasource_configuration_json")

database(
    name = "02_mysql_database_config_json",
    datasource_configuration = "@E02_datasources//:mysql",
)

database(
    name = "02_mysql_database_no_config_json",
    datasource_configuration = "@E02_datasources_default//:mysql",
)

load(
    "@pip//:requirements.bzl",
    pip_require = "requirement",
)
load("@gpk_rules_pytest//:defs.bzl", "pytest_test")

datasource_configuration_json(
    name = "mysql_config",
    out = "mysql_config.json",
    datasource_configuration = "@E02_datasources//:mysql",
)

pytest_test(
    name = "acceptance",
    srcs = glob(["acceptancetests/*.py"]),
    data = [
        "mysql_config.json",
        ":create_02_mysql_database_config_json",
        ":create_02_mysql_database_no_config_json",
        ":drop_02_mysql_database_config_json",
        ":drop_02_mysql_database_no_config_json",
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
