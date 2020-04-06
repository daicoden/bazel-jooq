import os
from os import path

import pytest

if __name__ == "__main__":
    args = [os.getenv('PWD')]
    # Coupled to .circleci/config.yml
    if os.getenv('JUNIT_XML_ROOT_DIR'):
        args += ["--junitxml", os.path.join(os.getenv('JUNIT_XML_ROOT_DIR'), "junit.xml")]
    exit(pytest.main(args, plugins=['no:cacheprovider']))
