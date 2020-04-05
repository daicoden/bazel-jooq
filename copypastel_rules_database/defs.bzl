load("@sqldatabase//:repositories.bzl", "sqldatabase_repositories")

DatabaseConnectionProvider = provider(
    fields=["username", "password", "host", "port", "java_driver_class", "jdbc_connection_string"])

TYPE_TO_CREATOR = {
    "mysql": Label("@sqldatabase//create:create_mysql_database_bin")
}

# Requires a datasource_type be defiened by the rule
# Should be executable=True
def database_creator(datasource_type):
  return TYPE_TO_CREATOR[datasource_type]

# Creats the out file specified with the contents "SUCCESS" or errors
def create_database(actions, executable, datasource_connection, dbname, out):
    conn_string = datasource_connection.jdbc_connection_string
    username = datasource_connection.username
    password = datasource_connection.password
    driver_class = datasource_connection.driver_class

    actions.run(
      inputs = [],
      outputs = [out],
      arguments = [conn_string, username, password, driver_class, dbname, out.path],
      executable = executable,
      mnemonic = "CreateDatabase"
    )

def _datasource_configuration(ctx):
    return struct(provider=[DatabaseConnectionProvider(
        jdbc_connection_string=ctx.attr.jdbc_connection_string,
        username=ctx.attr.username,
        password=ctx.attr.password,
        driver_class=ctx.attr.driver_class,
    )])

datasource_configuration = rule(
    implementation = _datasource_configuration,
    attrs = {
        "jdbc_connection_string": attr.string(mandatory = True),
        "username": attr.string(mandatory = True),
        "password": attr.string(mandatory = True),
        "driver_class": attr.string(mandatory = True),
    }
)

#
def mysql_datasource_configuration(name, host, port, username, password):
    datasource_configuration(
        name=name,
        jdbc_connection_string="jdbc:mysql://%s:%s" % (host, port),
        username=username,
        password=password,
        driver_class="com.mysql.cj.jdbc.Driver",
    )
    return {"datasource_type": "mysql", "datasource_connection": "//" + native.package_name() + ":" + name}


def
