load("@gpk_rules_datasource//datasource:defs.bzl", "DataSourceConnectionInfo", "DatabaseInfo", "create_database", "drop_database", "database_configuration")


def _migrate_database_impl(ctx):
    pass

migrate_database = rule(
    implementation = _migrate_database_impl,
    attrs = {
        "database_configuration": attr.label(providers = [DataSourceConnectionInfo, DatabaseInfo]),
        "migrations": attr.label_list(allow_files=True),
    }
)

def _migrated_database(ctx):
    migration_checksum = ctx.actions.declare_file(ctx.label.name + "_migration_checksum")


    return struct(providers = [
        ctx.attr.database_configuration[DataSourceConnectionInfo],
        ctx.attr.database_configuration[DatabaseInfo],
        DefaultInfo(files = [migration_checksum])
    ])

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
