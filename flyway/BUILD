package(default_visibility = [":__subpackages__"])

load("@rules_intellij_generate//:def.bzl", "intellij_module")

# Exports

java_library(
    name="java_lib",
    srcs = glob(["javasrc/**/*.java"]),
    deps=[
    ],
    visibility = ["//visibility:public"]
)


intellij_module(name="iml", iml_type="java", visibility = ["//visibility:public"])
