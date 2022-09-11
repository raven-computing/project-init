# ${{VAR_PROJECT_NAME}}: ${{VAR_PROJECT_DESCRIPTION}}

A loadable Linux kernel module.  
Add a brief summary here. What is the kernel module used for? What does it do?

## Getting Started

Add the most important kernel module information for the end user here.  
This section should be used to instruct the user on how to accomplish the most basic use case.


## Compatibility

Specify here the kernel versions the module is compatible to.  
Are there any special system dependencies to be aware of?

## Documentation

Add the link to the project documentation here.


## Build

It is assumed that you have a C compiler and the necessary kernel header files are available.
In order to build the kernel module you require **Make** and **Kbuild**.

Use the ```build.sh``` script to build the kernel module:
```
./build.sh
```
See ```build.sh -?``` for available options.  
The module will be built against the running kernel of your underlying system.


## Installation

After having built the kernel module, you can look at the module information of the created *${{VAR_KERNEL_MODULE_NAME}}.ko* file with:
```
modinfo build/${{VAR_KERNEL_MODULE_NAME}}.ko
```

You may then decide to install the kernel module with:
```
sudo insmod build/${{VAR_KERNEL_MODULE_NAME}}.ko
```

When you now list the available kernel modules on your system, you should see the installed module:
```
sudo lsmod |grep "${{VAR_KERNEL_MODULE_NAME}}"
```

When you look at the systemd journal, you should be able to see the module's initialization message:
```
sudo journalctl --since "5 minutes ago" |grep "kernel"
```

You can uninstall the kernel module at any time with:
```
sudo rmmod ${{VAR_KERNEL_MODULE_NAME}}
```


## Development

Add notes and links here to inform about how to change or add code in this project.


## License

${{VAR_LICENSE_README_NOTE}}

