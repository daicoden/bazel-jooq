load("@rules_python//python:defs.bzl", "py_test")

def pytest_test(name, srcs = [], deps = [], data = []):
    """
    Same as py_test but uses the unit.py test runner.
    """

    file_name = "%s_%s_%s" % (native.repository_name(), native.package_name(), name)
    native.genrule(
        name = "%s_unit_runner" % name,
        srcs = ["@gpk_rules_pytest//:unit.py.template"],
        outs = ["%s_unit.py" % name],
        cmd = "sed 's/__JUNIT_OUT__/%s.xml/g' $< > $@" % file_name,
        executable = True,
    )

    py_test(
        name = name,
        srcs = srcs + [":%s_unit_runner" % name],
        legacy_create_init = False,
        deps = deps,
        data = data,
        main = ":%s_unit.py" % name,
    )
