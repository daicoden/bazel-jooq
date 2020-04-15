load("@bazel_json//:json_parser.bzl", "json_parse")

DataSourceConnectionProvider = provider(
    fields = {
        "host": "Host to connect to",
        "port": "Port to connect to",
        "username": "Database Username",
        "password": "Password for the User",
        "jdbc_connection_string": "Can be used for tools which connect to a JDBC supported database. Recomended if targets are using JDBC.",
    },
)

DatabaseProvider = provider(
    fields = {"dbname": "name of the database"},
)

def _datasource_template_provider_impl(ctx):
    connection_provider = ctx.attr.datasource_configuration[DataSourceConnectionProvider]
    vars = {}
    vars.update(ctx.attr.substitutions)
    vars.update({
        "HOST": connection_provider.host,
        "PORT": connection_provider.port,
        "USERNAME": connection_provider.username,
        "PASSWORD": connection_provider.password,
        "JDBC_CONNECTION_STRING": connection_provider.jdbc_connection_string,
    })
    return struct(providers=[platform_common.TemplateVariableInfo(vars)])

datasource_template_provider = rule(
    attrs = {
        "datasource_configuration": attr.label(
            mandatory = True,
            providers = [DataSourceConnectionProvider],
        ),
        "substitutions": attr.string_dict(
            allow_empty = True,
            default = {},
            doc = "Additional substitutions.",
        ),
    },
    doc = """
    Defines template variables for genrule, can reference the following:

    $(HOST)
    $(PORT)
    $(USERNAME)
    $(PORT)

    and any additional substitutions provided.
    """,
    implementation = _datasource_template_provider_impl,
)

def _dbtool_impl(ctx):
    datasource_configuration = ctx.attr.database_configuration[DataSourceConnectionProvider]
    database_configuration = ctx.attr.database_configuration[DatabaseProvider]
    default_info = ctx.attr.dbtool_bin[DefaultInfo]

    template = ctx.actions.declare_file("%s-exe-template" % ctx.label.name)
    outfile = ctx.actions.declare_file("%s-exe" % ctx.label.name)

    ctx.actions.write(
        output=template,
        content=ctx.expand_location(
            "%s --host {HOST} --port {PORT} --username {USERNAME} --port {PORT} --dbname {DBNAME}" %
             ctx.executable.dbtool_bin.short_path
        ),
    )

    ctx.actions.expand_template(
        template=template,
        output=outfile,
        substitutions={
            "{HOST}": datasource_configuration.host,
            "{PORT}": datasource_configuration.port,
            "{USERNAME}": datasource_configuration.username,
            "{PASSWORD}": datasource_configuration.password,
            "{DBNAME}": database_configuration.dbname,
        },
        is_executable=True
    )

    return struct(providers=[DefaultInfo(executable=outfile, runfiles=default_info.default_runfiles)] )

_dbtool = rule(
    attrs = {
        "database_configuration": attr.label(
            mandatory = True,
            providers = [DataSourceConnectionProvider, DatabaseProvider],
        ),
        # TODO: does this work as top level reference because we're in a rule and not macro
        "dbtool_bin": attr.label(
            executable = True,
            cfg = "host",
        ),
    },
    doc = """
    Generates an executable create-<dbname>-exe which will create the database named dbname in the provided datasource.

    This can be run via bazel run //path:create-<dbname>
    """,
    executable = True,
    implementation = _dbtool_impl,
)

def create_database(name, database_configuration):
    _dbtool(
        name=name,
        database_configuration=database_configuration,
        dbtool_bin="@gpk_rules_datasource//datasource:create_database_bin",
    )

def drop_database(name ,database_configuration):
    _dbtool(
        name=name,
        database_configuration=database_configuration,
        dbtool_bin="@gpk_rules_datasource//datasource:drop_database_bin",
    )

def _database_configuration(ctx):
    return struct(providers=[
        ctx.attr.datasource_configuration[DataSourceConnectionProvider],
        DatabaseProvider(dbname=ctx.attr.dbname)
    ])

database_configuration = rule(
    attrs = {
        "datasource_configuration": attr.label(mandatory=True, providers=[DataSourceConnectionProvider]),
        "dbname": attr.string(),
    },
    implementation = _database_configuration,
)

def database(name, datasource_configuration, dbname = None):
    """
    Defines two executable targets, :create-<name> and  :drop-<name>

    Name will be the name of the database.
    """

    if dbname == None:
        dbname = name

    database_configuration(
        name = name,
        dbname = dbname,
        datasource_configuration=datasource_configuration,
    )
    create_database(
        name="create-%s" % name,
        database_configuration=":%s" % name
    )

    drop_database(
        name="drop-%s" % name,
        database_configuration=":%s" % name
    )

def _datasource_configuration(ctx):
    return struct(providers=[DataSourceConnectionProvider(
        host=ctx.attr.host,
        port=ctx.attr.port,
        username=ctx.attr.username,
        password=ctx.attr.password,
        jdbc_connection_string=ctx.attr.jdbc_connection_string,
    )])

datasource_configuration = rule(
    attrs = {
        "host": attr.string(mandatory = True),
        "port": attr.string(mandatory = True),
        "username": attr.string(mandatory = True),
        "password": attr.string(mandatory = True),
        "jdbc_connection_string": attr.string(),
    },
    implementation = _datasource_configuration,
)

def _expand_datasource_configuration(ctx):
    connection_provider = ctx.attr.datasource_configuration[DataSourceConnectionProvider]

    ctx.expand_template(
        template=ctx.files.template,
        output=ctx.outputs.out,
        substitutions=ctx.substitutions.update({
            "$(HOST)": connection_provider["host"],
            "$(PORT)": connection_provider["port"],
            "$(USERNAME)": connection_provider["username"],
            "$(PASSWORD)": connection_provider["password"],
        }),
    )

expand_datasource_configuration = rule(
    attrs = {
        "template": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "datasource_configuration": attr.label(
            mandatory = True,
            providers = [DataSourceConnectionProvider],
        ),
        "substitutions": attr.string_dict(
            allow_empty = True,
            default = {},
            doc = "Additional substitutions.",
        ),
        "out": attr.output(mandatory = True),
    },
    doc = """
    Writes a file to the specified output with the following substitutions from the datasource_configuration:

    $(HOST) -> host
    $(PORT) -> port
    $(USERNAME) -> username
    $(PASSWORD) -> password
    $(JDBC_CONNECTION_STRING) -> jdbc_connection_string
    """,
    implementation = _expand_datasource_configuration,
)

def datasource_configuration_json(name, datasource_configuration, out=None):
    """
    Creates a config file for code to load
    """

    datasource_template_provider(
        name="%s_template_provider" % name,
        datasource_configuration=datasource_configuration
    )

    if out == None:
        out = name + '.json'

    native.genrule(
        name=name,
        cmd='echo \'{ "host": "$(HOST)", "port": $(PORT), "username": "$(USERNAME)", "password": "$(PASSWORD)", "jdbc_connection_string": "$(JDBC_CONNECTION_STRING)"}\' > $@',
        toolchains=[':%s_template_provider' % name],
        outs=[out],
    )

# Something like this for allowing developers to have different configs locally.
def _json_config_impl(ctx):
    """
    Allows you to specify a file on disk to use for data connection.

    If you pass a default
    """
    config_path = ctx.path(ctx.attr.config_file_location).dirname.get_child(ctx.attr.config_file)

    config = ""
    if config_path.exists:
        config = ctx.read(config_path)
    elif ctx.attr.default_config == "None":
        fail("Could not find config at %s, you must supply a default_config if this is intentional" % ctx.attr.config_file)
    else:
        config = ctx.attr.default_config

    result = json_parse(config)

    # currently only supports one
    name = result.keys()[0]
    ctx.file("BUILD.template",
             """
load("@gpk_rules_datasource//datasource:defs.bzl", "datasource_configuration")

datasource_configuration(
    name="$(NAME)",
    host="$(HOST)",
    port="$(PORT)",
    username="$(USERNAME)",
    password="$(PASSWORD)",
    visibility=["//visibility:public"],
)
             """)

    ctx.template( "BUILD","BUILD.template",
            substitutions = {
                "$(NAME)": name,
                "$(HOST)": result[name]["host"],
                "$(PORT)": "%s" % result[name]["port"],
                "$(USERNAME)": result[name]["username"],
                "$(PASSWORD)": result[name]["password"],

            },
            executable=False,
        )

json_datasource_configuration = repository_rule(
    attrs = {
        "config_file_location": attr.label(
            doc = """
            Path relative to the repository root for a datasource config file.

            """,
        ),
        "config_file": attr.string(
            doc = """
            Config file, maybe absent
            """,
        ),
        "default_config": attr.string(
            # better way to do this?
            default = "None",
            doc = """
            If no config is at the path, then this will be the default config.
            Should look something like:

            {
                "datasource_name": {
                    "host": "<host>"
                    "port": <port>
                    "password": "<password>"
                    "username": "<username>"
                    "jdbc_connection_string": "<optional>"
                }
            }

            There can be more than datasource configured... maybe, eventually.
            """,
        ),
    },
    local = True,
    implementation = _json_config_impl,
)