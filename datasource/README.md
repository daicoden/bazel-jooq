# copypastel_rules_datasource

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

load("//:repositories.bzl", "copypastel_rules_datasource_dependencies")
copypastel_rules_datasource_dependencies()

load("@rules_python//python:pip.bzl", "pip_repositories", "pip_import")
pip_repositories()

pip_import(
    name = "pip",
    requirements = "@copypastel_rules_datasource//:requirements.txt"
)
load("@pip//:requirments.bzl", "pip_install")
pip_install()

http_archive(
    name="bazel_json",
    url = "https://github.com/erickj/bazel_json/archive/e954ef2c28cd92d97304810e8999e1141e2b5cc8.zip",
    strip_prefix="bazel_json-e954ef2c28cd92d97304810e8999e1141e2b5cc8/lib",
    sha256="4860e929115395403f7b33fc32c2a034d4b7990364b65c22244cb58cadd3a4a5",
)
```

## pip dependencies

copypastel_rules_datasource relies on a @pip dependency being present.

You can either get this by calling the copypastel_rules_datasource, or by adding the
necissary requirements to your own top level pip_import named pip.
