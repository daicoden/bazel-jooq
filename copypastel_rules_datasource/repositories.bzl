# Placeholder for adding dependencies
def copypastel_rules_datasource_dependencies(omitPip=False):
    native.http_archive(
        name = "bazel_json",
        sha256 = "4860e929115395403f7b33fc32c2a034d4b7990364b65c22244cb58cadd3a4a5",
        strip_prefix = "bazel_json-e954ef2c28cd92d97304810e8999e1141e2b5cc8/lib",
        url = "https://github.com/erickj/bazel_json/archive/e954ef2c28cd92d97304810e8999e1141e2b5cc8.zip",
    )
