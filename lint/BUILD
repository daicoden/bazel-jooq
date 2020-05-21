load("@com_github_bazelbuild_buildtools//buildifier:def.bzl", "buildifier")

exports_files(["buildifier_linter.template.sh"])

buildifier(
    name = "buildifier",
    mode = "check",
)
