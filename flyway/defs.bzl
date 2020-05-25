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
    locations = depset(["/".join(migration.short_path.split("/")[0:-1]) for migration in ctx.files.migrations])

    jars = [jar.class_jar for jar in jdbc_java_lib[JavaInfo].outputs.jars]

    # jars += [jar for jar in jdbc_java_lib[JavaInfo].runtime_output_jars]
    jars = depset(jars)

    # https://docs.bazel.build/versions/master/skylark/rules.html
    # https://github.com/bazelbuild/examples/blob/7357eb42c2b87a283effbfff6024b442feb5704b/rules/runfiles/complex_tool.bzl

    command = """#!/bin/bash

set -e

if [[ -z "${{RUNFILES_DIR}}" ]]; then
  RUNFILES_DIR=${{0}}.runfiles/{WORKSPACE}
else
  RUNFILES_DIR=${{RUNFILES_DIR}}/{WORKSPACE}
fi

declare -a StringArray=({LOCATIONS})
runfile_locs=""
for i in ${{StringArray[@]}}
do
    echo "Looking at ${{i}}"
    if [[ -z "${{runfile_locs}}" ]]; then
        runfile_locs="filesystem:${{RUNFILES_DIR}}/$i"
    else
        runfile_locs="filesystem:${{runfile_locs}},${{RUNFILES_DIR}}/$i"
    fi
done

${{RUNFILES_DIR}}/{FLYWAY} \
-url={JDBC_CONNECTION_STRING} \
-user={USERNAME} \
-password={PASSWORD} \
-schemas={DBNAME} \
-locations=${{runfile_locs}} \
-jarDirs=${{RUNFILES_DIR}}/{JAR_DIRS} \
-workingDirectory=${{RUNFILES_DIR}}/ \
-table={TABLE} \
{COMMAND}""".format(
        FLYWAY = ctx.executable.flyway_commandline_bin.short_path,
        HOST = datasource_configuration.host,
        PORT = datasource_configuration.port,
        USERNAME = datasource_configuration.username,
        PASSWORD = datasource_configuration.password,
        DBNAME = database_configuration.dbname,
        JDBC_CONNECTION_STRING = datasource_configuration.jdbc_connection_string,
        LOCATIONS = " ".join(['"{}"'.format(location) for location in locations.to_list()]),
        JAR_DIRS = ",".join(["/".join(jar.short_path.split("/")[0:-1]) for jar in jars.to_list()]),
        TABLE = ctx.attr.table,
        COMMAND = ctx.attr.command,
        WORKSPACE = ctx.workspace_name,
    )

    ctx.actions.write(
        output = outfile,
        content = command,
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
        database_configuration,
        datasource_configuration,
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

def _checksum_database(ctx):
    ctx.actions.write(
        ctx.outputs.out,
        content = "hello",
    )
    #ctx.actions.run_shell(
    #    arguments = [],
    #    inputs = [],
    #    outputs = [ctx.outputs.out],
    #    mnemonic = "FlywayDB",
    #    progress_message = "Info {}".format(ctx.attr.info_tool[DatabaseInfo].dbname),
    #    tools = [ctx.executable.info_tool],
    #    use_default_shell_env = True,
    #    command = "{flyway} > {out}".format(
    #        flyway = ctx.executable.info_tool.short_path,
    #        out = ctx.outputs.out.path,
    #    ),
    #)

    return struct(providers = [DefaultInfo(files = depset([ctx.outputs.out]))])

checksum_database = rule(
    implementation = _checksum_database,
    attrs = {
        "info_tool": attr.label(executable = True, cfg = "host", mandatory = True),
        "out": attr.output(mandatory = True),
    },
)

def _migrated_database_impl(ctx):
    out_checksum = ctx.actions.declare_file("{}_migration_checksum".format(ctx.label.name))
    inputs = []
    if ctx.attr.checksum != None:
        inputs = [ctx.file.checksum]

    my_runfiles = ctx.runfiles(files = [out_checksum])
    my_runfiles = my_runfiles.merge(ctx.attr.migrate_tool[DefaultInfo].default_runfiles)
    my_runfiles = my_runfiles.merge(ctx.attr.info_tool[DefaultInfo].default_runfiles)

    migrate_relative_tool_path = ctx.executable.migrate_tool.short_path
    info_relative_tool_path = ctx.executable.info_tool.short_path

    ctx.actions.run_shell(
        arguments = [],
        inputs = inputs,
        outputs = [out_checksum],
        mnemonic = "FlywayDB",
        progress_message = "Info {}".format(ctx.attr.info_tool[DatabaseInfo].dbname),
        tools = [ctx.executable.info_tool, ctx.executable.migrate_tool],
        use_default_shell_env = True,
        command = """#!/bin/bash

set -e
export RUNFILES_DIR=`pwd`/{migrate_path}.runfiles
${{RUNFILES_DIR}}/{workspace}/{migrate}
echo "hello" > {out}""".format(
            migrate_path = ctx.executable.migrate_tool.path,
            migrate = migrate_relative_tool_path,
            info = info_relative_tool_path,
            out = out_checksum.path,
            workspace = ctx.workspace_name,
        ),
    )

    return struct(providers = [
        ctx.attr.migrate_tool[DataSourceConnectionInfo],
        ctx.attr.migrate_tool[DatabaseInfo],
        DefaultInfo(files = depset([out_checksum]), runfiles = my_runfiles),
    ])

_migrated_database = rule(
    implementation = _migrated_database_impl,
    attrs = {
        "migrate_tool": attr.label(executable = True, cfg = "host", mandatory = True, providers = [DatabaseInfo, DataSourceConnectionInfo]),
        "info_tool": attr.label(executable = True, cfg = "host", mandatory = True, providers = [DatabaseInfo, DataSourceConnectionInfo]),
        "checksum": attr.label(allow_single_file = True, default = None, doc = """
        Checksum value of database to trigger a rebuild. Helpful if someone might manually run migrations
        outside of bazel.
        """),
    },
)

def migrated_database(name, datasource_configuration, migrations, dbname = None, flyway_commandline_bin = "@gpk_rules_datasource//flyway", **kwargs):
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

    checksum_database(
        name = "checksum_{}".format(name),
        info_tool = ":info_{}".format(name),
        out = "checksum_{}.sha".format(name),
    )

    _migrated_database(
        name = name,
        migrate_tool = ":migrate_{}".format(name),
        info_tool = ":info_{}".format(name),
        **kwargs
    )

# Users can rely on @<name>//:checksum for migrated status
#
# Users can run @<name>//:create
# Users can run @<name>//:drop
# Users can run @<name>//:migrate
# Users can build @<name>//:checksum
def _local_database(ctx):
    dbname = ctx.attr.dbname
    if dbname == None:
        dbname = ctx.name

    # If you don't do something with the file, then the rule does not recalculate.
    args = [ctx.path(file) for file in ctx.attr.recalculate_when]

    # Total mysql hack for now... not sure what to do... need java tool which dumps content of a table
    result = ctx.execute(
        ["mysql", "-u", "root", "--protocol", "tcp", "-e", "show databases"],
    )

    ctx.file(
        "local_database_checksum",
        """
{RETURN_CODE}
{STDERR}
{STDOUT}
 """.format(
            RETURN_CODE = result.return_code,
            STDERR = result.stderr,
            STDOUT = result.stdout,
        ),
    )

    migrations = ",\n".join(["'@{}//{}:{}'".format(label.workspace_name, label.package, label.name) for label in ctx.attr.migrations])

    ctx.file(
        "BUILD",
        """
load("@gpk_rules_datasource//flyway:defs.bzl", "migrated_database")
exports_files(["local_database_checksum"])

migrated_database(
    name="{NAME}",
    dbname="{DBNAME}",
    datasource_configuration="{DATASOURCE_CONFIGURATION}",
    migrations=[{MIGRATIONS}],
    checksum = "local_database_checksum",
    visibility=["//visibility:public"],
)

alias(name = "create", actual=":create_{NAME}", visibility=["//visibility:public"])
alias(name = "drop", actual=":drop_{NAME}", visibility=["//visibility:public"])
alias(name = "migrate", actual=":migrate_{NAME}", visibility=["//visibility:public"])
alias(name = "checksum", actual=":checksum_{NAME}", visibility=["//visibility:public"])

        """.format(
            NAME = ctx.name,
            DBNAME = dbname,
            USERNAME = ctx.attr.datasource_configuration,
            MIGRATIONS = migrations,
            DATASOURCE_CONFIGURATION = ctx.attr.datasource_configuration,
        ),
        executable = False,
    )

local_database = repository_rule(
    implementation = _local_database,
    local = True,
    configure = True,
    attrs = {
        "datasource_configuration": attr.label(providers = [DataSourceConnectionInfo]),
        "dbname": attr.string(doc = """
        If omitted, will be the name of the repository.
        """),
        "migrations": attr.label_list(allow_files = True),
        # TODO: add optional executable for generating the checksum file
        # https://community.denodo.com/kb/view/document/Testing%20JDBC%20connections?tag=Connectivity
        # This can dump all the tables or whatever to trigger downstreams to re-build
        "recalculate_when": attr.label_list(allow_files = True, doc = """
        Files to watch which will trigger the repository to run when they change.

        You can add a tools/bazel script to your local repository, and write a file with a date
        every time bazel is executed in order to get the migrator to check each bazel run if
        someone changed the database.
        """),
    },
)
