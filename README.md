# Project-init: Quickly Set Up New Projects

Project Init is our tool to quickly initialize new software projects from scratch. It is an interactive program which asks you some basic questions and then creates a complete new project in a directory of your choice. The aim is to get you going as quickly as possible so you can start writing code. Therefore, it takes care of all the initial boilerplate stuff, project directory layouts and even provides some example source code. Newly initialized projects should for the most part work out-of-the-box on operating systems supported by Raven Computing, provided that you have the necessary toolchain. You can choose from numerous different languages and project types.

![Example Usage](docs/example_usage.gif)

This repository also contains the content for the base project source templates. All major languages on our tech stack are supported. But Project Init also provides an add-on mechanism which allows you to add more project source templates without having to change the core code of the system. You can also change what is shown to the user, i.e. text and visuals, to match your organisation's brand. It's easy to set up and convenient to use. All you need to know for creating add-ons is a little Bash programming.

## Getting Started

There are multiple ways you can use the Project Init system whenever you want to initialize a new softwre project. The easiest way is to [install](#install) the *run.sh* script on your system. This makes the **project-init** command available for your convenience. If you don't want to install anything or just try it out once, simply [bootstrap](#bootstrap) the system temporarily by running the *run.sh* script with the provided commands. You may also [clone](#clone) this entire repository to a location of your choice.

We recommend that you first read the [Compatibility](#compatibility) section.

### Bootstrap

If you want to use the Project Init system to initialize a new software project, but don't want to install anything on your machine, you can directly use one of the below commands to bootstrap the program:

with ```wget```:
```bash
bash <(wget -q -O - https://github.com/raven-computing/project-init/raw/v1-latest/bootstrap/run.sh)
```

with ```curl```:
```bash
bash <(curl -sL https://github.com/raven-computing/project-init/raw/v1-latest/bootstrap/run.sh)
```

With above commands you always get the latest stable version of Project Init. Regardless whether you use *wget* or *curl*, the above commands essentially download the source of the bootstrap *run.sh* script and feed it to *bash*. The files of the Project Init system are only cached in your system's temporary directory, so nothing is actually installed.

### Install

If you want to install the Project Init system on your machine, you can run the bootstrap *install.sh* script instead:

with ```wget```:
```bash
bash <(wget -q -O - https://github.com/raven-computing/project-init/raw/v1-latest/bootstrap/install.sh)
```

with ```curl```:
```bash
bash <(curl -sL https://github.com/raven-computing/project-init/raw/v1-latest/bootstrap/install.sh)
```

This will install the *run.sh* script in a non-temporary directory. After installation you can initialize a new software project simply by invoking the command:

```bash
project-init
```

For more information about bootstrapping and installing the system please see the [Bootstrap README](bootstrap/README.md).

### Clone

Alternatively, you can of course clone this repository and then simply run the **initmain.sh** script to set up a new project. This is essentially what the bootstrap scripts do for you, while ensuring that you always use the latest stable version. If you use the **initmain.sh** script directly from a cloned repository, you have to remember to manually checkout the latest version.


## Compatibility

Project Init requires at least **Bash version 4**.

Currently, we only officially support Linux/Debian-based systems. Although in principle it should be possible to run it on most Linux distributions.

The Project Init system requires some very common utilities, e.g. *awk* and *grep*, which should be available on pretty much any system. See the [dependencies.txt](dependencies.txt) file for a full list.

The program uses fairly common arguments when calling external utilities. They should by supported by most versions found by default on common Linux distributions. However, if you're unsure whether your system meets all requirements, you can run compatibility tests. See the [Tests](#tests) Section for more information.

## Documentation

The Project Init system can be extended by an add-ons mechanism.  
Please consult the [Developer Documentation](https://github.com/raven-computing/project-init/wiki) and [API Reference](https://github.com/raven-computing/project-init/wiki/API-Reference) for more information.

All documentation is located in the GitHub Wiki.

## Tests

Execute the test suite by running the ```test.sh``` script:
```bash
./test.sh
```

This will show you if the underlying system is compatible and perform functionality tests for the Project Init tool.

See ```test.sh -?``` for available options.

## License

This program is licensed under the Apache License Version 2 - see the [LICENSE](LICENSE) for details.

The content, including all source code, which is generated by the Project Init system when executed, i.e. the program's output, is licensed according to the user's wishes. Neither Raven Computing nor any contributor to Project Init have copyright or license claims against the output of this program when executed.

Various license text incorporated into this repository under the [licenses](licenses) directory is designated to be used by the Project Init program at runtime. The text of those licenses may be licensed under a different license.
