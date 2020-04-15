import os
from os import path

import pytest

if __name__ == "__main__":
    args = [path.normpath(path.join(os.path.dirname(path.realpath(__file__)))), '-vv']
    # Coupled to .circleci/config.yml
    if os.getenv('JUNIT_XML_ROOT_DIR'):
        args += ["--junitxml", os.path.join(os.getenv('JUNIT_XML_ROOT_DIR'), "copypastel_rules_datasource.xml")]
    exit(pytest.main(args, plugins=['no:cacheprovider']))
