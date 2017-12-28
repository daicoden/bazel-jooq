load("@sqldatabase//:repositories.bzl", "sqldatabase_repositories")

datasource_connection_provider = provider(
    fields=["host", "port", "username", "password", "driver", "database_creator", "database_creator_bin"])

def _datasource_configuration(ctx):
    return [datasource_connection_provider(
        host=ctx.attr.host,
        port=ctx.attr.port,
        username=ctx.attr.username,
        password=ctx.attr.password,
        driver=ctx.attr.driver,
        database_creator = ctx.attr.database_creator,
        database_creator_bin = ctx.executable.database_creator,
    )]

datasource_configuration = rule(
    implementation = _datasource_configuration,
    attrs = {
        "host": attr.string(mandatory = True),
        "port": attr.string(mandatory = True),
        "username": attr.string(mandatory = True),
        "password": attr.string(mandatory = True),
        "driver": attr.label(mandatory = True, providers=["java"]),
        "database_creator": attr.label(mandatory = True, cfg="host", executable=True),
    }
)

def mysql_datasource_configuration(name, host, port, username, password):
    datasource_configuration(
        name=name,
        host=host,
        port=port,
        username=username,
        password=password,
        driver="@sqldatabase//:mysql_driver",
        database_creator = "@sqldatabase//create:create_mysql_database_bin",
    )
