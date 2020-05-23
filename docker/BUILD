load("@io_bazel_rules_docker//container:container.bzl", "container_image", "container_import", "container_push")
load("@io_bazel_rules_docker//docker/package_managers:download_pkgs.bzl", "download_pkgs")
load("@io_bazel_rules_docker//docker/package_managers:install_pkgs.bzl", "install_pkgs")

download_pkgs(
    name = "pkgs",
    image_tar = "@ubuntu1604//image",
    packages = [
        "openjdk-8-jdk",
        "python",
        "python-dev",
        "python-pip",
        "python3",
        "python3-pip",
    ],
    tags = ["manual"],
)

install_pkgs(
    name = "pkg_image",
    image_tar = "@circleci_base//image",
    installables_tar = ":pkgs.tar",
    installation_cleanup_commands = "rm -rf /var/lib/apt/lists/*",
    output_image_name = "pkg_image",
    tags = ["manual"],
)

# Intermediate to get rid of performance warnings.
#container_image(
#    name = "deployable",
#    base = ":pkg_image.tar"
#)

container_push(
    name = "push_bazel_jooq_build",
    format = "Docker",
    image = ":pkg_image.tar",
    registry = "index.docker.io",
    repository = "daicoden/bazel-jooq/build",
    tag = "latest",
    tags = ["manual"],
)
