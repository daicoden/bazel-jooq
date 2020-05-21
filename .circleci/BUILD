test_suite(
    name = "tests",
    tests = [
        ":circle_runs_examples_test",
    ],
    visibility = ["//visibility:public"],
)

genquery(
    name = "example_tests",
    testonly = True,
    expression = "tests(//examples:tests)",
    scope = ["//examples:tests"],
)

load(
    "@pip//:requirements.bzl",
    pip_require = "requirement",
)

py_test(
    name = "circle_runs_examples_test",
    srcs = ["pytest/circle_runs_examples_test.py"],
    args = [
        "$(location :example_tests)",
        "$(location :config.yml)",
    ],
    data = [
        ":config.yml",
        ":example_tests",
    ],
    deps = [pip_require("pyyaml")],
)

load("@rules_intellij_generate//:def.bzl", "intellij_module")

intellij_module(
    name = "iml",
    iml_type = "python-3.7",
    visibility = ["//visibility:public"],
)
