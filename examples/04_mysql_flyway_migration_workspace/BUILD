load("@gpk_rules_datasource//datasource:defs.bzl", "database", "datasource_configuration", "datasource_configuration_json")


load(
    "@pip//:requirements.bzl",
    pip_require = "requirement",
)
load("@gpk_rules_pytest//:defs.bzl", "pytest_test")

datasource_configuration_json(
    name = "mysql_config",
    out = "mysql_config.json",
    datasource_configuration = "@E04_mysql",
)

pytest_test(
    name = "acceptance",
    srcs = glob(["acceptancetests/*.py"]),
    data = [
        "mysql_config.json",
        #"@E04db//:create",
        #"@E04db//:drop",
        #"@E04db//:migrate",
        #"@E04db//:checksum",
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
