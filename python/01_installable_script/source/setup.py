${{VAR_COPYRIGHT_HEADER}}
"""${{VAR_PROJECT_DESCRIPTION}}"""

import os

${{VAR_SETUP_PY_SETUPTOOLS_IMPORT}}


PROJECT_ROOT = os.path.abspath(os.path.dirname(__file__))

with open(os.path.join(PROJECT_ROOT, "README.md")) as f:
    README = f.read()


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
    ${{VAR_SETUP_PY_FIND_PACKAGES}}
    classifiers=[
        "Programming Language :: Python :: 3",
        "${{VAR_LICENSE_CLASSIFIER_SETUP_PY}}",
        "Operating System :: OS Independent"
    ],
    entry_points={
        "console_scripts": [
            "${{VAR_EXEC_SCRIPT_NAME}}=${{VAR_NAMESPACE_DECLARATION}}:main"
        ]
    },
    python_requires=">=${{VAR_PYTHON_VERSION}}",
    install_requires=[],
)
