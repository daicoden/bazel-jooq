workspace(name = "gpk_rules_datasource")

local_repository(
    name = "gpk_rules_pytest",
    path = "./gpk_rules_pytest",
)

local_repository(
    name = "E01_mysql_database",
    path = "./examples/01_mysql_database",
)

local_repository(
    name = "E02_mysql_database_config_json",
    path = "./examples/02_mysql_database_config_json",
)

local_repository(
    name = "E03_mysql_flyway_migration",
    path = "./examples/03_mysql_flyway_migration",
)

local_repository(
    name = "E04_mysql_flyway_migration_workspace",
    path = "./examples/04_mysql_flyway_migration_workspace",
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@gpk_rules_datasource//:repositories.bzl", "gpk_rules_datasource_dependencies")

gpk_rules_datasource_dependencies()

http_archive(
    name = "rules_python",
    sha256 = "aa96a691d3a8177f3215b14b0edc9641787abaaa30363a080165d06ab65e1161",
    url = "https://github.com/bazelbuild/rules_python/releases/download/0.0.1/rules_python-0.0.1.tar.gz",
)

load("@rules_python//python:repositories.bzl", "py_repositories")
load("@rules_python//python:pip.bzl", "pip_import", "pip_repositories")

py_repositories()

pip_repositories()

pip_import(
    name = "pip",
    requirements = "@gpk_rules_datasource//:test_requirements.txt",
)

load("@pip//:requirements.bzl", "pip_install")

pip_install()

http_archive(
    name = "bazel_json",
    sha256 = "4860e929115395403f7b33fc32c2a034d4b7990364b65c22244cb58cadd3a4a5",
    strip_prefix = "bazel_json-e954ef2c28cd92d97304810e8999e1141e2b5cc8/lib",
    url = "https://github.com/erickj/bazel_json/archive/e954ef2c28cd92d97304810e8999e1141e2b5cc8.zip",
)

### 02 example tests workspace rules, mirrors behavior in 02
load("@gpk_rules_datasource//datasource:defs.bzl", "json_datasource_configuration")

json_datasource_configuration(
    name = "E02_datasources",
    config_file = "database.json",
    config_file_location = "@E02_mysql_database_config_json//:BUILD",
)

json_datasource_configuration(
    name = "E02_datasources_default",
    config_file = "database-non-existant.yml",
    config_file_location = "@E02_mysql_database_config_json//:BUILD",
    default_config = """
    {
        "mysql": {
            "host": "localhost",
            "port": 3306,
            "username": "root",
            "password": ""
        }
    }
    """,
)

### 04 example tests workspace rules
load("@gpk_rules_datasource//datasource:defs.bzl", "local_datasource_configuration")
local_datasource_configuration(
    name = "E04_mysql",
    host = "localhost",
    jdbc_connection_string = "jdbc:mysql://localhost:3306?serverTimezone=UTC",
    jdbc_connector = "@maven//:mysql_mysql_connector_java",
    password = "",
    port = "3306",
    username = "root",
)

### Flyway
RULES_JVM_EXTERNAL_TAG = "3.2"

RULES_JVM_EXTERNAL_SHA = "82262ff4223c5fda6fb7ff8bd63db8131b51b413d26eb49e3131037e79e324af"

http_archive(
    name = "rules_jvm_external",
    sha256 = RULES_JVM_EXTERNAL_SHA,
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
)

load("@rules_jvm_external//:defs.bzl", "maven_install")
load("@rules_jvm_external//:specs.bzl", "maven")

# to update the json file, see https://github.com/bazelbuild/rules_jvm_external#updating-maven_installjson
maven_install(
    name = "maven",
    artifacts = [
        "org.flywaydb:flyway-commandline:6.4.2",
        "mysql:mysql-connector-java:8.0.20",
    ],
    maven_install_json = "//:maven_install.json",
    repositories = [
        "https://repo1.maven.org/maven2",
    ],
    version_conflict_policy = "pinned",
)

load("@maven//:defs.bzl", "pinned_maven_install")

pinned_maven_install()

### Rules Intellij Generate

rules_intellij_generate_sha = "f738a6306637b72a04ff80a0dfd9e70980bb08c1"

http_archive(
    name = "rules_intellij_generate",
    sha256 = "5fceea2c23cb9303e3eaeec5b3428a81ab4c243d8cb8e44ad971a6980f3bdaf9",
    strip_prefix = "rules_intellij_generate-%s/rules" % rules_intellij_generate_sha,
    url = "https://github.com/sconover/rules_intellij_generate/archive/%s.tar.gz" % rules_intellij_generate_sha,
)

### Buildifier

# Buildifier
# buildifier is written in Go and hence needs rules_go to be built.
# See https://github.com/bazelbuild/rules_go for the up to date setup instructions.

http_archive(
    name = "io_bazel_rules_go",
    sha256 = "9fb16af4d4836c8222142e54c9efa0bb5fc562ffc893ce2abeac3e25daead144",
    urls = [
        "https://storage.googleapis.com/bazel-mirror/github.com/bazelbuild/rules_go/releases/download/0.19.0/rules_go-0.19.0.tar.gz",
        "https://github.com/bazelbuild/rules_go/releases/download/0.19.0/rules_go-0.19.0.tar.gz",
    ],
)

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains()

http_archive(
    name = "bazel_gazelle",
    sha256 = "be9296bfd64882e3c08e3283c58fcb461fa6dd3c171764fcc4cf322f60615a9b",
    urls = [
        "https://storage.googleapis.com/bazel-mirror/github.com/bazelbuild/bazel-gazelle/releases/download/0.18.1/bazel-gazelle-0.18.1.tar.gz",
        "https://github.com/bazelbuild/bazel-gazelle/releases/download/0.18.1/bazel-gazelle-0.18.1.tar.gz",
    ],
)

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

gazelle_dependencies()

http_archive(
    name = "com_google_protobuf",
    sha256 = "9748c0d90e54ea09e5e75fb7fac16edce15d2028d4356f32211cfa3c0e956564",
    strip_prefix = "protobuf-3.11.4",
    urls = ["https://github.com/protocolbuffers/protobuf/archive/v3.11.4.zip"],
)

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

http_archive(
    name = "com_github_bazelbuild_buildtools",
    sha256 = "34a201eb68a750ff1aac7070f5cd6c65c80b411415396db285099471fec03112",
    strip_prefix = "buildtools-master",
    url = "https://github.com/bazelbuild/buildtools/archive/master.zip",
)
