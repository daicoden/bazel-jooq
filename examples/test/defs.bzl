load("@copypastel_rules_datasource//:defs.bzl", "DataSourceConnectionProvider")

def pytest_test(name,  srcs, deps):
    """
    Same as py_test but uses the unit.py test runner.
    """

    py_test(
        name=name,
        srcs=srces,
        deps=deps,
        main="@copypastel_rules_test_helpers//:unit"
    )

def _db_interpolate_impl(ctx):
    files = []
    for src in ctx.attr.srcs:
        files += ctx.actions.declare_file(src.name)

    return struct(providers=[DefaultInfo(files=depset(files))])

db_interpolate = rule(
    attrs = {
        "srcs": attr.label_list(),
        "datasource_connection": attr.label(
            manditory = true,
            providers = [DataSourceConnectionProvider],
        ),
    },
    implementation = _py_db_tranform_impl,
)
