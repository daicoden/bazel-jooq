package(default_visibility = ["//datasource:__subpackages__"])

load("@pip//:requirements.bzl", "requirement")
load("@rules_python//python:defs.bzl", "py_binary", "py_library")

filegroup(
    name = "srcs",
    srcs = glob(["copypastel_rules_datasource/*.py"]),
)

py_library(
    name = "lib",
    srcs = [":srcs"],
    imports = ["."],
    deps = [
        requirement("click"),
        # https://bugs.mysql.com/bug.php?id=98225
        requirement("dnspython"),
        requirement("mysql-connector-python"),
        requirement("pyyaml"),
    ],
)

py_binary(
    name = "create_database",
    srcs = [":lib"],
    imports = ["."],
    legacy_create_init = False,
)

py_binary(
    name = "drop_database",
    srcs = [":lib"],
    imports = ["."],
    legacy_create_init = False,
)

py_binary(
    name = "yaml_to_datasource",
    srcs = [":lib"],
    imports = ["."],
    legacy_create_init = False,
)
