import sys
import yaml


def directory_from_label(label: str):
    """
    Takes out the @E... does rely on naming convention of the examples,
    :param label:
    :return:
    """
    return "./examples/" + label[2:-1].split("//")[0]


def assert_deps_in_circle(dependency_file, circle_config_file):
    with open(dependency_file, "r") as f:
        deps = f.read().strip()

    with open(circle_config_file, "r") as f:
        circle_config = yaml.load(f.read().strip(), Loader=yaml.SafeLoader)

    directories = list(map(directory_from_label, deps.split("\n")))

    executed_examples = circle_config["workflows"]["workflow"]["jobs"][0]["build_test"]["matrix"]["parameters"]["working_dir"]

    not_in_config = []
    for directory in directories:
        if directory not in executed_examples:
            not_in_config.append(directory)

    if len(not_in_config) > 0:
        print("Some examples not run in CI. %s" % ", ".join(not_in_config))
        exit(1)

    exit(0)


if __name__ == "__main__":
    assert_deps_in_circle(sys.argv[1], sys.argv[2])
