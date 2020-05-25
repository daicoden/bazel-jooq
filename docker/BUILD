load("@io_bazel_rules_docker//container:container.bzl", "container_image", "container_import", "container_push")
load("@io_bazel_rules_docker//docker/package_managers:download_pkgs.bzl", "download_pkgs")
load("@io_bazel_rules_docker//docker/package_managers:install_pkgs.bzl", "install_pkgs")

container_image(
    name = "build_docker_image",
    base = "@build_docker_file//image:dockerfile_image.tar",
    tags = ["manual"],
)

container_push(
    name = "push_bazel_jooq_build",
    format = "Docker",
    image = ":build_docker_image",
    registry = "index.docker.io",
    repository = "daicoden/bazel-jooq-build",
    tag = "latest",
    tags = ["manual"],
)
