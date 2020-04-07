load("@copypastel_rules_datasource//:defs.bzl", "DataSourceConnectionProvider")
load("@rules_python//python:defs.bzl", "py_test")

def pytest_test(name, srcs=[], deps=[], data=[]):
    """
    Same as py_test but uses the unit.py test runner.
    """

    py_test(
        name=name,
        srcs=srcs + ["@copypastel_rules_test_helpers//:unit.py"],
        legacy_create_init = False,
        deps=deps,
        data=data,
        main="@copypastel_rules_test_helpers//:unit.py"
    )
