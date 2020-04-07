local_repository(name = "copypastel_rules_datasource", path = "./copypastel_rules_datasource")

local_repository(name="E01_mysql_database", path ='./examples/01_mysql_database')
local_repository(name="copypastel_rules_test_helpers", path ='./examples/test')

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "rules_python",
    url = "https://github.com/bazelbuild/rules_python/releases/download/0.0.1/rules_python-0.0.1.tar.gz",
    sha256 = "aa96a691d3a8177f3215b14b0edc9641787abaaa30363a080165d06ab65e1161",
)

load("@copypastel_rules_datasource//:repositories.bzl", "copypastel_rules_datasource_dependencies")
copypastel_rules_datasource_dependencies()

load("@rules_python//python:repositories.bzl", "py_repositories")
py_repositories()

load("@rules_python//python:pip.bzl", "pip_repositories", "pip_import")
pip_repositories()

pip_import(
    name = "pip",
    requirements = "@copypastel_rules_test_helpers//:requirements.txt"
)
load("@pip//:requirements.bzl", "pip_install")
pip_install()

