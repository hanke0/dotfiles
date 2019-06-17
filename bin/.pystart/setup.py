# -*- coding: utf-8 -*-
import os
import re
from setuptools import setup, find_packages

package_name = "example"
PACKAGE = package_name.replace("_", "-")
PACKAGE_NAME = package_name.replace("-", "_")

VERSION_REGEX = r"""__version__ ?= ?["'](?P<version>.+?)["']\s*$"""

with open(os.path.join(PACKAGE_NAME, "__init__.py"), "rt") as f:
    value = f.read()
    match = re.search(VERSION_REGEX, value, re.MULTILINE)
    version = match.groupdict()["version"]

setup(
    name=PACKAGE, version=version, packages=find_packages(exclude=["tests", "test.*"])
)
