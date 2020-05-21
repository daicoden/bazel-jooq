load("@gpk_rules_datasource//datasource:defs.bzl", "DataSourceConnectionInfo", "DatabaseInfo", "create_database", "database_configuration", "drop_database")

def _flyway_tool_impl(ctx):
    datasource_configuration = ctx.attr.database_configuration[DataSourceConnectionInfo]
    database_configuration = ctx.attr.database_configuration[DatabaseInfo]
    default_info = ctx.attr.flyway_commandline_bin[DefaultInfo]

    if datasource_configuration.jdbc_connector_java_lib == None:
        fail("You must specify jdbc_connector to use migrations in the datasource for %s" % ctx.label.name)

    jdbc_java_lib = datasource_configuration.jdbc_connector_java_lib

    outfile = ctx.actions.declare_file("%s_exe" % ctx.label.name)

    # Ugh, the locations HAVE to be directories, so create a depset of all the directories passed in.
    locations = depset(["filesystem:{}".format("/".join(migration.short_path.split("/")[0:-1])) for migration in ctx.files.migrations])

    jars = [jar.class_jar for jar in jdbc_java_lib[JavaInfo].outputs.jars]
    # jars += [jar for jar in jdbc_java_lib[JavaInfo].runtime_output_jars]
    jars = depset(jars)

    ctx.actions.write(
        output = outfile,
        content = """
{FLYWAY} \
-url={JDBC_CONNECTION_STRING} \
-user={USERNAME} \
-password={PASSWORD} \
-schemas={DBNAME} \
-locations={LOCATIONS} \
-jarDirs=`pwd`/{JAR_DIRS} \
-workingDirectory=`pwd`/ \
-table={TABLE} \
{COMMAND}
        """.format(
            FLYWAY = ctx.executable.flyway_commandline_bin.short_path,
            HOST = datasource_configuration.host,
            PORT = datasource_configuration.port,
            USERNAME = datasource_configuration.username,
            PASSWORD  =datasource_configuration.password,
            DBNAME  =database_configuration.dbname,
            JDBC_CONNECTION_STRING = datasource_configuration.jdbc_connection_string,
            LOCATIONS = ",".join(locations.to_list()),
            JAR_DIRS = ",".join(["/".join(jar.short_path.split("/")[0:-1]) for jar in jars.to_list()]),
            TABLE = ctx.attr.table,
            COMMAND = ctx.attr.command,
        ),
        is_executable = True,
    )


    return struct(providers = [
        DefaultInfo(
            executable = outfile,
            runfiles = ctx
                .runfiles(files = ctx.files.migrations, transitive_files = jdbc_java_lib[DefaultInfo].files)
                .merge(default_info.default_runfiles)
                .merge(jdbc_java_lib[DefaultInfo].default_runfiles),
        ),
    ])

flyway_command = rule(
    implementation = _flyway_tool_impl,
    attrs = {
        "database_configuration": attr.label(providers = [DataSourceConnectionInfo, DatabaseInfo]),
        "migrations": attr.label_list(allow_files = True),
        "flyway_commandline_bin": attr.label(executable = True, cfg = "host"),
        "command": attr.string(doc = """
        Flyway command to run, i.e. migrate, info, clean, etc.

        https://flywaydb.org/documentation/commandline/
        """),
        "table": attr.string(default = "flyway_schema_history", doc = """
        Argument for flyway options
        """),
    },
    executable = True,
)

def _migrated_database_impl(ctx):
    checksum = ctx.actions.declare_file("{}_migration_checksum".format(ctx.label.name))

    ctx.actions.run_shell(
        arguments = [],
        inputs = ctx.files.migrations,
        outputs = [],
        mnemonic = "FlywayDB",
        progress_message = "Migrating {}".format(ctx.database_configuration[DatabaseInfo].dbname),
        tools = [ctx.executable.migrate_tool],
        use_default_shell_env = True,
        command = ctx.executable.migrate_tool.path,
    )

    ctx.actions.run_shell(
        arguments = [],
        inputs = ctx.files.migrations,
        outputs = [checksum],
        mnemonic = "FlywayDB",
        progress_message = "Info {}".format(ctx.database_configuration[DatabaseInfo].dbname),
        tools = [ctx.executable.info_tool],
        use_default_shell_env = True,
        command = "{flyway} > {out}".format(
            flyway = ctx.executable.info_tool.path,
            out = checksum,
        ),
    )

    return struct(providers = [
        ctx.attr.database_configuration[DataSourceConnectionInfo],
        ctx.attr.database_configuration[DatabaseInfo],
        DefaultInfo(files = [checksum]),
    ])

_migrated_database = rule(
    implementation = _migrated_database_impl,
    attrs = {
        "database_configuration": attr.label(providers = [DatabaseInfo, DataSourceConnectionInfo], mandatory = True),
        "migrate_tool": attr.label(executable = True, cfg = "host", mandatory = True),
        "info_tool": attr.label(executable = True, cfg = "host", mandatory = True),
    },
)

def migrated_database(name, datasource_configuration, migrations, dbname = None, flyway_commandline_bin = "@gpk_rules_datasource//flyway"):
    """
    Creates an executable target :migrate_<dbname>. Note: dbname is only syntax sugar, the database migrated will
    be the database specified in the database_provider.

    This also creates a rule which is a DatabaseInfo and a DataSourceConnectionInfo, that has a single
    output which is the checksum of the schema_versions table. Relying on this target will ensure that
    any rules that are dependent will get re-build when a migration is added.

    :param flyway_commandline_bin: Specify a java_binary to use for flyway_commandline_bin, can replace with licensed flyway migrator.
    """

    if dbname == None:
        dbname = name

    database_configuration(
        name = "{}_configuration".format(name),
        dbname = dbname,
        datasource_configuration = datasource_configuration,
    )

    create_database(
        name = "create_{}".format(name),
        database_configuration = ":{}_configuration".format(name),
    )

    drop_database(
        name = "drop_{}".format(name),
        database_configuration = ":{}_configuration".format(name),
    )

    flyway_command(
        name = "migrate_{}".format(name),
        database_configuration = ":{}_configuration".format(name),
        migrations = migrations,
        command = "migrate",
        flyway_commandline_bin = flyway_commandline_bin,
    )

    flyway_command(
        name = "info_{}".format(name),
        database_configuration = ":{}_configuration".format(name),
        migrations = migrations,
        command = "info",
        flyway_commandline_bin = flyway_commandline_bin,
    )

    _migrated_database(
        name = name,
        migrate_tool = ":migrate_{}".format(name),
        info_tool = ":info_{}".format(name),
        database_configuration = ":{}_configuration".format(name),
    )


