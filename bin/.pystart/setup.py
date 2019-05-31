# -*- coding: utf-8 -*-
import os
import re
from setuptools import setup, find_packages

package_name = "example"

with open(os.path.join(package_name.replace('-', '_'), "__init__.py"), "rt") as f:
    value = f.read()
    match = re.search(r"""__version__ ?= ?["'](?P<version>.+?)["']\s*$""", value, re.MULTILINE)
    version = match.groupdict()["version"]

setup(
    name=package_name,
    version=version,
    packages=find_packages(exclude=["tests", "test.*"]),
)
