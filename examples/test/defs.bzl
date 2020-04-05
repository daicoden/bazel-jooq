load("@copypastel_rules_database//:defs.bzl", "DatabaseConnectionProvider")


def py_db_test(name, database, srcs, deps):
    """
    Same as py_test but expands the passed in sources to include database connection properties defined in the build.

    $(DB_HOST)
    $(DB_PORT)
    $(DB_PASSWORD)
    $(DB_USERNAME)

    Note: Deps are not transformed

    pytest must be provided in the deps
    """

    _py_db_interpolate(
        name = "%s_interpolated" % name,
        srcs = srcs,
        database_connection=database,
    )

    py_test(
        name=name,
        srcs=":%s_interpolated" % name,
        deps=deps,
        main=
    )


def _db_interpolate_impl(ctx):
    files = []
    for src in ctx.attr.srcs:
        files += ctx.actions.declare_file(src.name)

    return struct(providers=[DefaultInfo(files=depset(files))])


db_interpolate = rule(
    implementation = _py_db_tranform_impl,
    attrs = {
        "srcs": attr.label_list(),
        "database_connection": attr.label(manditory=true, providers=[DatabaseConnectionProvider])
    }
)
