load("@gpk_rules_datasource/datasource:defs.bzl", "DataSourceConnectionProvider", "DatabaseProvider")

def _migrate_database_executable_impl(ctx):
    pass

_migrate_database_executable = rule(
    attrs = {
        "database_configuration": attr.label(mandatory = True, providers = [DatabaseProvider, DataSourceConnectionProvider]),
        "migration_files": attr.label_list(mandatory = True, allow_files = True),
    },
    doc = """
    Generates an executable named migrate_<dbname>.

    Running the executable will apply the migrations from the specified directory.
    """,
    implementation = _migrate_database_executable,
)

def _migrated_database_impl():
    pass

_migrated_database_impl = rule(
)

def migrated_database(name, database_configuration, dbname, migration_files):
    """
    Creates an executable target :migrate_<dbname>. Note: dbname is only syntax sugar, the database migrated will
    be the database specified in the database_provider.

    This also creates a rule which is a DatabaseProvider and a DataSourceConnectionProvider, that has a single
    output which is the checksum of the schema_versions table. Relying on this target will ensure that
    any rules that are dependent will get re-build when a migration is added.
    """
    _migrate_database_executable(
        name = "migrate_%s" % dbname,
        database_configuration = database_configuration,
        migration_files = migration_files,
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
