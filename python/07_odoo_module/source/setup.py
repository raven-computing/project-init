${{VAR_COPYRIGHT_HEADER}}
"""${{VAR_PROJECT_DESCRIPTION}}"""

import os

from setuptools import setup, find_namespace_packages


PROJECT_ROOT = os.path.abspath(os.path.dirname(__file__))

with open(os.path.join(PROJECT_ROOT, "README.md")) as f:
    README = f.read()

PACKAGES = ["${{VAR_ODOO_MODULE_NAME}}", "${{VAR_ODOO_MODULE_NAME}}.*"]

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
        include=PACKAGES,
        exclude=["*.tests"]
    ),
    include_package_data=True,
    package_data={
        "": ["security/ir.model.access.csv"],
    },
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent"
    ],
    python_requires=">=${{VAR_PYTHON_VERSION}}",
    install_requires=[],
)
