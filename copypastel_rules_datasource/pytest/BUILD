package(default_visibility = ["//:__subpackages__"])

load("@pip//:requirements.bzl", "requirement")
load("@rules_python//python:defs.bzl", "py_library", "py_test")

filegroup(
    name = "srcs",
    srcs = glob(["unittests/*.py"]),
)

py_library(
    name = "test_lib",
    srcs = [":srcs"],
    imports = ["."],
    deps = [
        "//pysrc:lib",
    ],
)

py_test(
    name = "unit",
    srcs = ["unit.py"],
    imports = ["."],
    legacy_create_init = False,
    deps = [
        ":test_lib",
        requirement("pytest"),
    ],
)
