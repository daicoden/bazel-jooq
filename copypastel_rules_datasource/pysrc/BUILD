package(default_visibility = ["//:__subpackages__"])

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
        requirement("mysql-connector-python"),
        # https://bugs.mysql.com/bug.php?id=98225
        requirement("dnspython"),
        requirement("click"),
    ],
)


py_binary(
    name = "create_database",
    srcs = [":lib"],
    imports = ["."],
    legacy_create_init=False,
)

py_binary(
    name = "drop_database",
    srcs = [":lib"],
    imports = ["."],
    legacy_create_init=False,
)
