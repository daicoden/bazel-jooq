load("@rules_intellij_generate//:def.bzl", "intellij_module")

java_library(
    name="java_lib",
    srcs = glob(["javasrc/**/*.java"]),
    deps=[
    ],
    visibility = ["//visibility:public"]
)

java_library(
    name="java_test_lib",
    srcs = glob(["javatest/**/*.java"]),
    deps=[
    ],
    visibility = ["//visibility:public"]
)

intellij_module(name="iml", iml_type="java", visibility = ["//visibility:public"])
