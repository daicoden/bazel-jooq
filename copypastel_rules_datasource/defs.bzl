
DataSourceConnectionProvider = provider(
    fields = {
        "host": "Host to connect to",
        "port": "Port to connect to",
        "username": "Database Username",
        "password": "Password for the User",
        "jdbc_connection_string": "Can be used for tools which connect to a JDBC supported database. Recomended if targets are using JDBC.",
    },
)

def _datasource_template_provider_impl(ctx):
    return platform_common.TemplateVariableInfo(ctx.substitutions.update({
                    "$(HOST)": connection_provider["host"],
                    "$(PORT)": connection_provider["port"],
                    "$(USERNAME)": connection_provider["username"],
                    "$(PASSWORD)": connection_provider["password"],
    }))

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

    and any additional substitutions provided
    """,
    implementation = _datasource_template_provider_impl,
)

def create_database(name, datasource_configuration):
    datasource_template_provider(
        name="datasource_%s_template_provider" % name,

          datasource_configuration=datasource_configuration
                                 )


    genrule(
        name="create_database_%s" % name,
        srcs = ["@copypastel_rules_database//:create_database_bin"],
        cmd ="echo './$< --host $(HOST) --port $(PORT) --username $(USERNAME) --port $(PORT) --dbname $(DBNAME)' > $@",
        toolchains = [":datasource_%s_template_provider" % name],
        executable =True
    )

def drop_database():
    pass

def database(name, datasource_configuration):
    """
    Defines two executable targets, :create_<name> and  :drop_<name>

    Name will be the name of the database.
    """
    create_database(name, datasource_configuration)
    drop_database(name, datasource_configuration)

def _datasource_configuration(ctx):
    return struct(provider=[DataSourceConnectionProvider(
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
    connection_provider = ctx.attrs.datasource_configuration[DataSourceConnectionProvider]

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
    native.genrule(
        name=name + '_template',
        cmd='echo \'{ "host": "$(HOST)", "port": $(PORT), "username": "$(USERNAME)", "password": "$(PASSWORD)", "jdbc_connection_string": "$(JDBC_CONNECTION_STRING)"}\' > $@',
        outs=name + '_template',
    )

    if out == None:
        out = name + '.json'

    expand_datasource_configuration(
        name = name,
        template=name + '_template',
        datasource_configuration=datasource_configuration,
        out=(out)
    )

# Something like this for allowing developers to have different configs locally.
def _yaml_config_impl(repository_ctx):
    """
    Allows you to specify a file on disk to use for data connection.

    If you pass a default
    """
    # repository_ctx.template("BUILD",
    #                     template = """
    #                     datasource_configuration(
    #                         name=$(NAME)
    #                         host=$(HOST)
    #                         port=$(PORT)
    #                         username=$(USERNAME)
    #                         _OPTIONALS_
    #                     """,
    #                     substitutions = {
    #                         "$(NAME)",
    #                     }
    #                     )

    pass

yaml_config = repository_rule(
    attrs = {
        "config_path": attr.label(manditory = True),
        "default_config": attr.string(
            doc = """
            If no config is at the path, then this will be the default config.
            Should look something like:

            reference_name:
                host: <host>
                port: <port>
                password: <password>
                username: <username>
                jdbc_connection_string: <optional>

            There can be more than datasource configured.
            """,
        ),
    },
    local = True,
    implementation = _yaml_config_impl,
)
