load("@flyway//:repositories.bzl", "flyway_repositories")
load("@sqldatabase//:defs.bzl", "datasource_connection_provider")

def _get_create_exec(datasource_connection): # requires datasource_connection
    print(datasource_connection)
    return datasource_connection


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

  creator = datasource_connection.database_creator
  # This ensures that whatever the creator needs to run is available and built

  print(creator.java)
  print(dir(creator.java))
  return [DefaultInfo(files = depset(outs))]

create_database = rule(
    implementation = _create_database,
    attrs = {
        "datasource_connection": attr.label(mandatory=True, providers=[datasource_connection_provider]),
        "dbname": attr.string(mandatory=True),
    },
    executable=True,
)


def _driver_from_connection(ctx):
    print(dir(ctx.attr.datasource_connection[JavaInfo]))
    return [ctx.attr.datasource_connection[JavaInfo]]

driver_from_connection = rule(
    implementation = _driver_from_connection,
    attrs = {
        "datasource_connection": attr.label(providers = [JavaInfo])
    }
)

# Allows you to:
# bazel run //..:create_<name>
# depend on a created database via //..:create_<name>
def database(name, datasource_connection, dbname = None):
    if dbname == None:
        dbname = name

    create_name = "create_%s" % name
    create_rule = ":%s" % create_name
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
