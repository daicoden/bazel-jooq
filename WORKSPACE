local_repository(
    name = "copypastel_rules_datasource",
    path = "./copypastel_rules_datasource",
)

local_repository(
    name = "copypastel_rules_test_helpers",
    path = "./examples/test",
)

local_repository(
    name = "E01_mysql_database",
    path = "./examples/01_mysql_database",
)

local_repository(
    name = "E02_mysql_database_config_json",
    path = "./examples/02_mysql_database_config_json",
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_python",
    sha256 = "aa96a691d3a8177f3215b14b0edc9641787abaaa30363a080165d06ab65e1161",
    url = "https://github.com/bazelbuild/rules_python/releases/download/0.0.1/rules_python-0.0.1.tar.gz",
)

load("@copypastel_rules_datasource//:repositories.bzl", "copypastel_rules_datasource_dependencies")

copypastel_rules_datasource_dependencies()

load("@rules_python//python:repositories.bzl", "py_repositories")

py_repositories()

load("@rules_python//python:pip.bzl", "pip_repositories", "pip_import")

pip_repositories()

pip_import(
    name = "pip",
    requirements = "@copypastel_rules_test_helpers//:requirements.txt",
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
load("@copypastel_rules_datasource//:defs.bzl", "json_datasource_configuration")

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
