package(default_visibility=["//:__subpackages__"])

load("@pip//:requirements.bzl", "requirement")

filegroup(
    name='srcs',
    srcs = glob(['unittests/*.py'])
)

py_library(
    name='test_lib',
    srcs=[':srcs'],
    deps=[
        '//pysrc:lib'
    ],
    imports = ['.']
)

py_test(
    name='unit',
    srcs=['unit.py'],
    deps=[
        ':test_lib',
        requirement('pytest'),
    ],
    imports = ['.']
)
