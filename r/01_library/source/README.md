# ${{VAR_PROJECT_NAME}}: ${{VAR_PROJECT_DESCRIPTION}}

Add a brief summary here. What is the library used for? What does it do?

## Getting Started

Add the most important library information for the end user here.  
This section should be used to instruct the user on how to accomplish the most basic use case.


## Compatibility

This library requires ${{VAR_R_VERSION_LABEL}} or higher.

Specify here the platforms the library is compatible to.  
Are there any special system dependencies to be aware of?


## Documentation

Add the link to the project documentation here.


## Development

Add notes and links here to inform about how to change or add code in this project.

### Setup

The following instructions show how to achieve things on a command line. The R *devtools* are required in a development environment. The below instructions assume that devtools are loaded within the underlying development environment when calling the R functions directly. The provided scripts take care of loading the *devtools* functions in R but you can always open an R prompt and call the functions directly.

### Loading Library Functions

When in the project root directory, you may load the library code with:

```r
load_all()
```

This will temporarily install the library code in a non-global workspace.
You can then directly call all functions provided by the library.

### Tests

Execute all unit tests by running the ```test.sh``` script:
```
./test.sh
```

Alternatively, from within an R prompt, you can run all unit tests with:
```r
test()
```

### Build Documentation

Build the documentation by running the ```build.sh``` script:
```
./build.sh --docs
```

Alternatively, from within an R prompt, you can build the documentation with:
```r
document()
```

The above commands will build the documentation in the *man* directory
with *roxygen2*.

### Perform Checks

If you want to install the library from source, it is highly recommended to run
the automated checks before installing. You can use the ```test.sh``` script to perform the checks:
```
./test.sh --check
```

Alternatively, from within an R prompt, you can perform the checks with:
```r
check()
```

### Install from Source

If all checks have passed, you can install the library from source by opening an R prompt and calling:
```r
install()
```

You can then attach the library package in your projects like any other
package.

### Build

Use the ```build.sh``` script to build the library as a distributable package:
```
./build.sh
```
See ```build.sh -?``` for available options.

Alternatively, from within an R prompt, you can build a distribution file with:
```r
build()
```

The built file can then be distributed manually.


## License

${{VAR_LICENSE_README_NOTE}}

