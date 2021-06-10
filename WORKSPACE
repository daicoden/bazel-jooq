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

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_python",
    sha256 = "778197e26c5fbeb07ac2a2c5ae405b30f6cb7ad1f5510ea6fdac03bded96cc6f",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_python/releases/download/0.2.0/rules_python-0.2.0.tar.gz",
        "https://github.com/bazelbuild/rules_python/releases/download/0.2.0/rules_python-0.2.0.tar.gz",
    ],
)

load("@rules_python//python:pip.bzl", "pip_parse")

pip_parse(
    name = "pip",
    requirements_lock = "@gpk_rules_datasource//:requirements-lock.txt",
)

load("@pip//:requirements.bzl", "install_deps")

install_deps()

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

load("@gpk_rules_datasource//flyway:defs.bzl", "local_database")

local_database(
    name = "E04db",
    datasource_configuration = "@E04_mysql",
    dbname = "04_mysql_flyway_migration_workspace",
    migrations = ["@E04_mysql_flyway_migration_workspace//:migrations"],
    recalculate_when = ["//:.bazelexec.stamp"],
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

http_archive(
    name = "io_bazel_rules_go",
    sha256 = "7904dbecbaffd068651916dce77ff3437679f9d20e1a7956bff43826e7645fcc",
    urls = [
        "https://storage.googleapis.com/bazel-mirror/github.com/bazelbuild/rules_go/releases/download/v0.25.1/rules_go-v0.25.1.tar.gz",
        "https://github.com/bazelbuild/rules_go/releases/download/v0.25.1/rules_go-v0.25.1.tar.gz",
    ],
)

http_archive(
    name = "bazel_gazelle",
    sha256 = "222e49f034ca7a1d1231422cdb67066b885819885c356673cb1f72f748a3c9d4",
    urls = [
        "https://storage.googleapis.com/bazel-mirror/github.com/bazelbuild/bazel-gazelle/releases/download/v0.22.3/bazel-gazelle-v0.22.3.tar.gz",
        "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.22.3/bazel-gazelle-v0.22.3.tar.gz",
    ],
)

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains(version = "1.15.5")

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

gazelle_dependencies()

http_archive(
    name = "com_github_bazelbuild_buildtools",
    sha256 = "c28eef4d30ba1a195c6837acf6c75a4034981f5b4002dda3c5aa6e48ce023cf1",
    strip_prefix = "buildtools-4.0.1",
    urls = ["https://github.com/bazelbuild/buildtools/archive/4.0.1.tar.gz"],
)

load("@com_github_bazelbuild_buildtools//buildifier:deps.bzl", "buildifier_dependencies")

buildifier_dependencies()

http_archive(
    name = "com_google_protobuf",
    sha256 = "9748c0d90e54ea09e5e75fb7fac16edce15d2028d4356f32211cfa3c0e956564",
    strip_prefix = "protobuf-3.11.4",
    urls = ["https://github.com/protocolbuffers/protobuf/archive/v3.11.4.zip"],
)

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

# Docker for Build

# Download the rules_docker repository at release v0.17.0
http_archive(
    name = "io_bazel_rules_docker",
    sha256 = "59d5b42ac315e7eadffa944e86e90c2990110a1c8075f1cd145f487e999d22b3",
    strip_prefix = "rules_docker-0.17.0",
    urls = ["https://github.com/bazelbuild/rules_docker/releases/download/v0.17.0/rules_docker-v0.17.0.tar.gz"],
)

load(
    "@io_bazel_rules_docker//repositories:repositories.bzl",
    container_repositories = "repositories",
)

container_repositories()

load("@io_bazel_rules_docker//repositories:deps.bzl", container_deps = "deps")

container_deps()

load(
    "@io_bazel_rules_docker//container:container.bzl",
    "container_pull",
)
load("@io_bazel_rules_docker//contrib:dockerfile_build.bzl", "dockerfile_image")

container_pull(
    name = "circle_python",
    digest = "sha256:795f9f76eaa1ebb1e4def7229ebadb6ed448c13b967eea4cd6c274c557606eec",
    registry = "index.docker.io",
    repository = "cimg/python",
    tag = "3.7.7",
)

dockerfile_image(
    name = "build_docker_file",
    dockerfile = "//docker:Dockerfile",
)
