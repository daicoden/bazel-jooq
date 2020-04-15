package(default_visibility = ["//visibility:public"])

alias(
    name = "create_database_bin",
    actual = "@gpk_rules_datasource//datasource/pysrc:create_database",
)

alias(
    name = "drop_database_bin",
    actual = "@gpk_rules_datasource//datasource/pysrc:drop_database",
)

alias(
    name="py_lib",
    actual = "@gpk_rules_datasource//datasource/pysrc:lib",
)

alias(
    name="py_test_lib",
    actual = "@gpk_rules_datasource//datasource/pytest:lib"
)

test_suite(
    name = "tests",
    tests = [
        "//datasource/pytest:unit",
    ],
)

load("@rules_intellij_generate//:def.bzl", "intellij_module")
intellij_module(name="iml", iml_type="python-3.7", visibility = ["//visibility:public"])
