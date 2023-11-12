${{VAR_COPYRIGHT_HEADER}}
"""${{VAR_PROJECT_DESCRIPTION}}"""

import os

${{VAR_SETUP_PY_SETUPTOOLS_IMPORT}}
from setuptools import Extension
from Cython.Build import cythonize


PROJECT_ROOT = os.path.abspath(os.path.dirname(__file__))

with open(os.path.join(PROJECT_ROOT, "README.md")) as f:
    README = f.read()


native_module = Extension(
    name="${{VAR_NAMESPACE_DECLARATION}}._index_finder",
    sources=["${{VAR_NAMESPACE_DECLARATION_PATH}}/_index_finder.pyx"],
    include_dirs=[],
    library_dirs=[],
    runtime_library_dirs=[],
    libraries=[]
)

ext_modules = [native_module]

annotation_enabled = False
if os.getenv("CYTHON_BUILD_ANNOTATION", "0") == "1":
    annotation_enabled = True


ext_modules = cythonize(
    ext_modules,
    build_dir="build/cython",
    annotate=annotation_enabled
)

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
       "Programming Language :: Cython",
       "${{VAR_LICENSE_CLASSIFIER_SETUP_PY}}",
       "Operating System :: POSIX :: Linux"  # Adjust as needed
    ],
    python_requires=">=${{VAR_PYTHON_VERSION}}",
    zip_safe=False,
    install_requires=[],
    ext_modules = ext_modules
)

