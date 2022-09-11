# ${{VAR_PROJECT_NAME}}: ${{VAR_PROJECT_DESCRIPTION}}

Add a brief summary here. What is the library used for? What does it do?

## Getting Started

Add the most important library information for the end user here.  
This section should be used to instruct the user on how to accomplish the most basic use case.


## Compatibility

This library requires Python ${{VAR_PYTHON_VERSION}} or higher.


## Documentation

Add the link to the project documentation here.


## Build

Use the ```build.sh``` script to build the library wheel:
```
./build.sh
```
See ```build.sh -?``` for available options.


## Development

Add notes and links here to inform about how to change or add code in this project.

### Setup

It is recommended to use virtual environments (virtualenv) and the [virtualenvwrapper](https://virtualenvwrapper.readthedocs.io/en/latest/) utilities for developing Python projects. If you are running on *Linux*, then you can set up your development environment by sourcing the ```setup.sh``` script. This will create a virtual environment *${{VAR_PROJECT_VIRTENV_NAME}}* for you and install all dependencies:
```
source setup.sh
```

### Tests

Execute all unit tests by running the ```test.sh``` script:
```
./test.sh
```
${{VAR_README_DEV_LINT}}
${{VAR_README_DEV_DEPLOY}}


## License

${{VAR_LICENSE_README_NOTE}}
