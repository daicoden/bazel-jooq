load("@flyway//:repositories.bzl", "flyway_repositories")
load("@sqldatabase//:defs.bzl", "datasource_connection_provider")

def _create_database(ctx):
  datasource_connection = ctx.attr.datasource_connection[datasource_connection_provider]

  host = datasource_connection.host
  port = datasource_connection.port
  username = datasource_connection.username
  password = datasource_connection.password
  dbname = ctx.attr.dbname

  outs = [ctx.outputs.executable]
  ctx.actions.run(
      inputs = [],
      outputs = outs,
      arguments = [host, port, username, password, dbname, ctx.outputs.executable.path],
      executable = datasource_connection.database_creator_bin,
      mnemonic = "CreateDatabase"
  )

  return [DefaultInfo(files = depset(outs))]

create_database = rule(
    implementation = _create_database,
    attrs = {
        "datasource_connection": attr.label(mandatory=True, providers=[datasource_connection_provider]),
        "dbname": attr.string(mandatory=True),
        "_test": attr.label(executable=True, cfg="host", default=Label("@sqldatabase//create:create_mysql_database_bin"))
    },
    executable=True,
)

# Allows you to:
# bazel run //..:create_<name>
# depend on a created database via //..:create_<name>
def database(name, datasource_connection, dbname = None):
    if dbname == None:
        dbname = name

    create_name = "create_%s" % name
    create_rule = ":create_%s" % name
    create_database(
        name = create_name,
        datasource_connection = datasource_connection,
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
