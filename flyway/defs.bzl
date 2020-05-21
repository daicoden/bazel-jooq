load("@gpk_rules_datasource//datasource:defs.bzl", "DataSourceConnectionInfo", "DatabaseInfo", "create_database", "drop_database", "database_configuration")


def _migrate_database_impl(ctx):
    datasource_configuration = ctx.attr.database_configuration[DataSourceConnectionInfo]
    database_configuration = ctx.attr.database_configuration[DatabaseInfo]
    default_info = ctx.attr._flywaydb[DefaultInfo]

    if datasource_configuration.jdbc_connector_java_lib == None:
        fail("You must specify jdbc_connector to use migrations in the datasource for %s" % ctx.label.name)

    jdbc_java_lib = datasource_configuration.jdbc_connector_java_lib

    template = ctx.actions.declare_file("%s_exe_template" % ctx.label.name)
    outfile = ctx.actions.declare_file("%s_exe" % ctx.label.name)

    locations = ["filesystem:{}".format("/".join(migration.short_path.split("/")[0:-1])) for migration in ctx.files.migrations]

    command_bullshit = "{FLYWAY} -url={JDBC_CONNECTION_STRING} -user={USERNAME} -password={PASSWORD} -schemas={DBNAME} -locations={LOCATIONS} -workingDirectory=`pwd`/ -jarDirs=`pwd`/{JAR_DIRS}"
    ctx.actions.write(
        output = template,
        content = """
        %s migrate
        %s info
        """ % (command_bullshit, command_bullshit),
    )

    jar_dirs = ["/".join(jar.class_jar.short_path.split("/")[0:-1]) for jar in jdbc_java_lib[JavaInfo].outputs.jars]
    # jar_dirs += [jar.short_path for jar in jdbc_java_lib[JavaInfo].runtime_output_jars]

    ctx.actions.expand_template(
        template = template,
        output = outfile,
        substitutions = {
            "{FLYWAY}": ctx.executable._flywaydb.short_path,
            "{HOST}": datasource_configuration.host,
            "{PORT}": datasource_configuration.port,
            "{USERNAME}": datasource_configuration.username,
            "{PASSWORD}": datasource_configuration.password,
            "{DBNAME}": database_configuration.dbname,
            "{JDBC_CONNECTION_STRING}": datasource_configuration.jdbc_connection_string,
            "{LOCATIONS}": ",".join(locations),
            "{JAR_DIRS}": ",".join(jar_dirs)
        },
        is_executable = True,
    )

    print(jdbc_java_lib[DefaultInfo].files)
    return struct(providers = [
        DefaultInfo(executable = outfile,
                    runfiles = ctx
                        .runfiles(files = ctx.files.migrations, transitive_files = jdbc_java_lib[DefaultInfo].files)
                        .merge(default_info.default_runfiles)
                        .merge(jdbc_java_lib[DefaultInfo].default_runfiles)
        )])


migrate_database = rule(
    implementation = _migrate_database_impl,
    attrs = {
        "database_configuration": attr.label(providers = [DataSourceConnectionInfo, DatabaseInfo]),
        "migrations": attr.label_list(allow_files=True),
        "_flywaydb": attr.label(executable=True, cfg="host", default = "@gpk_rules_datasource//flyway"),
    },
    executable = True,
)

def _migrated_database_impl(ctx):
    checksum = ctx.actions.declare_file("{}_migration_checksum".format(ctx.label.name))

    ctx.actions.run_shell(
        arguments = [],
        inputs = ctx.files.migrations,
        outputs = ctx.outputs,
        mnemonic = "FlywayDB",
        progress_message = "Migrating {}".format(ctx.database_configuration[DatabaseInfo].dbname),
        tools = [ctx.executable.migrate_tool],
        use_default_shell_env = True,
        command = "{flyway} > {out}".format(
          flyway = ctx.executable._migrate_tool.path,
          out=checksum,
        )
    )

    return struct(providers = [
        ctx.attr.database_configuration[DataSourceConnectionInfo],
        ctx.attr.database_configuration[DatabaseInfo],
        DefaultInfo(files = [checksum])
    ])

_migrated_database = rule(
    implementation = _migrated_database_impl,
    attrs = {
        "database_configuration": attr.label(providers = [DatabaseInfo, DataSourceConnectionInfo], mandatory=True),
        "migrate_tool": attr.label(executable = True, cfg="host", mandatory=True)
    }
)

def migrated_database(name, datasource_configuration, migrations, dbname = None):
    """
    Creates an executable target :migrate_<dbname>. Note: dbname is only syntax sugar, the database migrated will
    be the database specified in the database_provider.

    This also creates a rule which is a DatabaseInfo and a DataSourceConnectionInfo, that has a single
    output which is the checksum of the schema_versions table. Relying on this target will ensure that
    any rules that are dependent will get re-build when a migration is added.
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

    migrate_database(
        name = "migrate_{}".format(name),
        database_configuration = ":{}_configuration".format(name),
        migrations = migrations,
    )

    _migrated_database(
        name = name,
        migrate_tool = ":migrate_{}".format(name),
        database_configuration = ":{}_configuration".format(name),
    )


"""

// to redo this...

https://stackoverflow.com/questions/46853097/optional-file-dependencies-in-bazel
// reference javac and jar tools.
https://github.com/buchgr/bazel/commit/200819dd6c95e0574e894718b471c4dc1ca91194
//
https://docs.bazel.build/versions/master/skylark/lib/JavaInfo.html#transitive_source_jars

# Ok new new plan
https://docs.bazel.build/versions/master/be/java.html#java_library

jooq results in a .srcjar, which is then referenced by a native java_library rule.
"""
