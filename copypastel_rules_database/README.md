# copypastel_rules_database

Contains rules for connecting to a local database.

## Installing

```build
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "rules_python",
    url = "https://github.com/bazelbuild/rules_python/releases/download/0.0.1/rules_python-0.0.1.tar.gz",
    sha256 = "aa96a691d3a8177f3215b14b0edc9641787abaaa30363a080165d06ab65e1161",
)
load("@rules_python//python:repositories.bzl", "py_repositories")
py_repositories()

load("//:repositories.bzl", "copypastel_rules_database_dependencies")
copypastel_rules_database_dependencies()

load("@rules_python//python:pip.bzl", "pip_repositories", "pip_import")
pip_repositories()

pip_import(
    name = "pip",
    requirements = "@copypastel_rules_database//:requirements.txt"
)
load("@pip//:requirments.bzl", "pip_install")
pip_install()
```

## pip dependencies

copypastel_rules_database relies on a @pip dependency being present.

You can either get this by calling the copypastel_rules_database, or by adding the
necissary requirements to your own top level pip_import named pip.
