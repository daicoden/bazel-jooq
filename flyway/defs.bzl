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
  out = ctx.actions.declare_file("success")

  ctx.actions.run(
      inputs = [],
      outputs = [out],
      arguments = [host, port, username, password, out.path],
      executable = datasource_connection.database_creator_bin
  )

  creator = datasource_connection.database_creator
  return [DefaultInfo(
      files = creator.files,
      default_runfiles = creator.default_runfiles,
      data_runfiles = creator.data_runfiles)]

create_database = rule(
    implementation = _create_database,
    attrs = {
        "datasource_connection": attr.label(mandatory=True, providers=[datasource_connection_provider]),
        "dbname": attr.string(mandatory=True),
    },
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

def database(name, datasource_connection, dbname = None):
    if dbname == None:
        dbname = name

    create_database(
        name = "created_" + name,
        datasource_connection = datasource_connection,
        dbname = dbname,
    )


def migrated_database(name, datasource_conneciton):
    pass
