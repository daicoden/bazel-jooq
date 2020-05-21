package(default_visibility = [":__subpackages__"])

java_binary(
    name = "flyway",
    main_class = "org.flywaydb.commandline.Main",
    visibility = ["//visibility:public"],
)

load("@rules_intellij_generate//:def.bzl", "intellij_module")

intellij_module(
    name = "iml",
    iml_type = "java",
    visibility = ["//visibility:public"],
)
