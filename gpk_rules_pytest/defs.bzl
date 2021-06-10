load("@rules_python//python:defs.bzl", "py_test")

def pytest_test(name, srcs = [], deps = [], data = []):
    """
    Same as py_test but uses the unit.py test runner.
    """

    file_name = "%s_%s_%s" % (native.repository_name(), native.package_name(), name)

    # If running tests from an external repository, i.e. has a repository_name, it gets placed
    # in external, but the PWD is set to the root above external. This was causing tests to
    # run in other python packages.  For external repository tests, we need to change PWD
    # to be scoped to the repository bazel is running the test for.
    if native.repository_name == "":
        namespace_dir = ""
    else:
        # Remove the @ form the repository_name
        namespace_dir = "\\/external\\/%s" % native.repository_name()[1:]

    native.genrule(
        name = "%s_unit_runner" % name,
        srcs = ["@gpk_rules_pytest//:unit.py.template"],
        outs = ["%s_unit.py" % name],
        cmd = "sed 's/__JUNIT_OUT__/{}.xml/g; s/__NAMESPACE_DIR__/{}/g' $< > $@".format(file_name, namespace_dir),
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
