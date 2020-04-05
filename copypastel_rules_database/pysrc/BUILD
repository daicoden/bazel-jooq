package(default_visibility=['//:__subpackages__'])

load("@pip//:requirements.bzl", "requirement")

filegroup(
    name='srcs',
    srcs = glob(['copypastel_rules_database/*.py'])
)

py_library(
    name='lib',
    srcs=[':srcs'],
    deps=[
        requirement('mysql-connector-python'),
        # https://bugs.mysql.com/bug.php?id=98225
        requirement('dnspython'),
    ],
    imports=['.']
)
