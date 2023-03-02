${{VAR_COPYRIGHT_HEADER}}
"""${{VAR_PROJECT_DESCRIPTION}}"""

import os
import glob

from setuptools import setup, find_namespace_packages


def find_odoo_modules(root):
    search_path = os.path.join(root, "**/__manifest__.py")
    return [path.split("/")[-2] for path in glob.glob(search_path)]

def create_package_list(modules):
    return [module + postfix for module in modules for postfix in ("", ".*")]

def create_package_data_map(modules):
    return {
        module: ["**/*.csv", "**/*.xml"]
        for module in modules
    }

PROJECT_ROOT = os.path.abspath(os.path.dirname(__file__))

with open(os.path.join(PROJECT_ROOT, "README.md")) as f:
    README = f.read()

ODOO_MODULES = find_odoo_modules(PROJECT_ROOT)

PYTHON_PACKAGES = create_package_list(ODOO_MODULES)

DATA_PACKAGES = create_package_data_map(ODOO_MODULES)

setup(
    name="${{VAR_PROJECT_NAME_LOWER}}",
    version="0.0.1",
    description="${{VAR_PROJECT_DESCRIPTION}}",
    long_description=README,
    long_description_content_type="text/markdown",
    url="${{VAR_PROJECT_ORGANISATION_URL}}",
    author="${{VAR_PROJECT_ORGANISATION_NAME}}",
    author_email="${{VAR_PROJECT_ORGANISATION_EMAIL}}",
    license="${{VAR_PROJECT_LICENSE}}",
    packages=find_namespace_packages(
        include=PYTHON_PACKAGES,
        exclude=["*.tests"]
    ),
    include_package_data=True,
    package_data=DATA_PACKAGES,
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent"
    ],
    python_requires=">=${{VAR_PYTHON_VERSION}}",
    install_requires=[],
)
