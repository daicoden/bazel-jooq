exports_files(["database.json"])

load("@copypastel_rules_datasource//:defs.bzl", "datasource_configuration", "database", "datasource_configuration_json")

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
load("@copypastel_rules_test_helpers//:defs.bzl", "pytest_test")

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
        ":create-02_mysql_database_config_json",
        ":drop-02_mysql_database_config_json",
        ":create-02_mysql_database_no_config_json",
        ":drop-02_mysql_database_no_config_json",
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
)
