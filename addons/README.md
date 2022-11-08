# Project-init Addons: Extensions to the Project Init System

This directory contains example files for Project Init addons.


## **Directories:**

### example

Contains init code and resources showing how to add another programming language via an addon. The example is emblematic for any language, but does only contain a small project type with a shell script for illustrative purposes. See [documentation](https://github.com/raven-computing/project-init/wiki/Addons#add-custom-programming-languages).

### java

Contains init code and resources showing how to add another project type via an addon for a programming language which is already supported by the base system. The example is emblematic for any supported language, but does only contain a small project type in Java for illustrative purposes. See [documentation](https://github.com/raven-computing/project-init/wiki/Addons#add-custom-project-types).

### licenses

Contains resources showing how to add another license via an addon. The example license is imaginary without any real use. See [documentation](https://github.com/raven-computing/project-init/wiki/Addons#add-custom-licenses).


## **Files:**

### project.properties

Contains key-value-properties to override the base default properties. See [documentation](https://github.com/raven-computing/project-init/wiki/Addons#configuration).

### files.txt

Defines filenames and file patterns to be considered by Project Init for variable substitution, in addition to the files already included by the base *files.txt* configuration file. See [documentation](https://github.com/raven-computing/project-init/wiki/Addons#variable-substitution).

### load-hook.sh

An executable Bash shell script which is automatically executed BEFORE the project initialization procedure starts. It can contain arbitrary shell code. See [documentation](https://github.com/raven-computing/project-init/wiki/Addons#load-hook).

### after-init-hook.sh

An executable Bash shell script which is automatically executed AFTER a new project was successfully initialized. It can contain arbitrary shell code. See [documentation](https://github.com/raven-computing/project-init/wiki/Addons#after-init-hook).

### title.txt

Redefines the title message shown at startup. See [documentation](https://github.com/raven-computing/project-init/wiki/Addons#title).

### description.txt

Redefines the description message shown at startup. See [documentation](https://github.com/raven-computing/project-init/wiki/Addons#description).

### icon.ascii.txt

Redefines the text icon shown at startup. See [documentation](https://github.com/raven-computing/project-init/wiki/Addons#icon).

### VERSION

Defines the version of the addon resource. Must contain a single text line indicating the version identifier (major.minor.patch). See [documentation](https://github.com/raven-computing/project-init/wiki/Addons#versioning).

