package(default_visibility = ["//:__subpackages__"])

exports_files([
    "iml_types.xml",
    ".bazelexec.stamp",
    "maven_install.json"
])

load("@com_github_bazelbuild_buildtools//buildifier:def.bzl", "buildifier")

buildifier(
    name = "buildifier",
)

load("@rules_intellij_generate//:def.bzl", "intellij_module", "intellij_project")

intellij_project(
    name = "bazel-jooq",
    bazelexec = "./tools/bazel",
    iml_types_file = "//:iml_types.xml",
    modules = [
        "//.circleci:iml",
        "//:iml",
        "//datasource:iml",
        "//flyway:iml",
    ],
    project_root_filegroup = "//:automatically_placed_intellij_project_files",
    project_root_filegroup_ignore_prefix = "intellij_project_files",
    test_lib_label_matchlist = ['{"label_name":"java_test_lib"}'],
    deps = [
        "//datasource:py_lib",
        "//datasource:py_test_lib",
        # "//flyway:java_lib",
    ],
)

intellij_module(
    name = "iml",
    iml_type = "root",
    module_name_override = "bazel-jooq",
)

alias(
    name = "intellij",
    actual = ":install_intellij_files_script",
)

filegroup(
    name = "automatically_placed_intellij_project_files",
    srcs = glob(["intellij_project_files/**/*.xml"]),
)

test_suite(
    name = "tests",
    tests = [
        "//.circleci:tests",
        "//datasource:tests",
        "//examples:tests",
    ],
    visibility = ["//visibility:public"],
)
