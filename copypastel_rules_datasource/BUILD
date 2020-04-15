package(default_visibility = ["//visibility:public"])
load("@rules_intellij_generate//:def.bzl", "intellij_module")

alias(
    name = "create_database_bin",
    actual = "@copypastel_rules_datasource//pysrc:create_database",
)

alias(
    name = "drop_database_bin",
    actual = "@copypastel_rules_datasource//pysrc:drop_database",
)

alias(
    name="py_lib",
    actual = "@copypastel_rules_datasource//pysrc:lib",
)

alias(
    name="py_test_lib",
    actual = "@copypastel_rules_datasource//pytest:lib"
)

test_suite(
    name = "tests",
    tests = [
        "//pytest:unit",
    ],
)

intellij_module(name="iml", iml_type="python-3.7", visibility = ["//visibility:public"])
