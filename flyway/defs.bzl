load("@flyway//:repositories.bzl", "flyway_repositories")
load("@sqldatabase//:defs.bzl", "datasource_connection_provider", "database_creator", "create_database")

def _create_database_impl(ctx):
  datasource_connection = ctx.attr.datasource_connection[datasource_connection_provider]
  create_database(ctx.actions, ctx.executable._creator,
                  datasource_connection, ctx.attr.dbname, ctx.outputs.executable)
  return [DefaultInfo(files = depset([ctx.outputs.executable]))]

_create_database = rule(
    implementation = _create_database_impl,
    attrs = {
        "datasource_connection": attr.label(mandatory=True, providers=[datasource_connection_provider]),
        "datasource_type": attr.string(mandatory=True),
        "dbname": attr.string(mandatory=True),
        "_creator": attr.label(executable=True, cfg="host", default=database_creator)
    },
    executable=True,
)

# Allows you to:
# bazel run //..:create_<name>
# depend on a created database via //..:create_<name>
def database(name, datasource_configuration, dbname = None):
    if dbname == None:
        dbname = name

    create_name = "create_%s" % name
    create_rule = ":create_%s" % name
    _create_database(
        name = create_name,
        datasource_connection = datasource_configuration["datasource_connection"],
        datasource_type = datasource_configuration["datasource_type"],
        dbname = dbname,
    )

    created_name = "created_%s" % name
    native.genrule(
        name = created_name,
        srcs = [create_rule],
        outs = ["success"],
        cmd = "cat $(location %s) > $@" % create_rule
    )


def migrated_database(name, datasource_conneciton):
    pass
