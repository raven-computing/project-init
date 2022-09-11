## Bootstrap and Installation

This directory contains the scripts to bootstrap and install the Project Init system. There are multiple ways you can use Project Init. You may choose the one that best fits your preferences. The scripts in this directory are provided for your convenience.

## Bootstrap

Use this method if you don't want to install anything on your working system. This is intended to be used in situations when you want to integrate the Project Init functionality into other existing tools of your infrastructure. For example, if you already have a tool which is used for project-management-related tasks and you want to launch and control Project Init in a specific step of your workflow, then that should be quite easy to accomplish no matter what major technology your tool is written in because in the end all you have to do is make an HTTP GET request and pass the received code to Bash as input. The other situation where it is convenient to bootstrap Project Init is when you simply want to try it out once. Of course, you can always decide to install it at a later time.

If you just use the bootstrap method, either with the commands shown below or via your own implementation for fetching the code of the *run.sh* script in this direcrory, then nothing will be permanently stored on your working system. The *run.sh* script will only use your system's temporary directory (i.e. /tmp) to download the Project Init code and template content. You can even specify an option to automatically remove the cached files as soon as the program exists. That way you could decide to only run Project Init like that, create a new project and then have everything else removed again so you only keep the created files of the newly initialized project.


For your convenience, we provide example commands using **wget** or **curl**, respectively. You can use whichever you want. They are functionally equivalent.

If you simply want to bootstrap Project Init from your command line directly, you can use the below commands:

with ```wget```:
```bash
bash <(wget -q -O - https://github.com/raven-computing/project-init/raw/v1-latest/bootstrap/run.sh)
```

with ```curl```:
```bash
bash <(curl -sL https://github.com/raven-computing/project-init/raw/v1-latest/bootstrap/run.sh)
```

There is a special argument ```--no-cache``` which only has an effect when using the bootstrap *run.sh* script. It causes the cached temporary directory to be removed once the program finishes. You can use it like this:

with ```wget```:
```bash
bash <(wget -q -O - https://github.com/raven-computing/project-init/raw/v1-latest/bootstrap/run.sh) --no-cache
```

with ```curl```:
```bash
bash <(curl -sL https://github.com/raven-computing/project-init/raw/v1-latest/bootstrap/run.sh) --no-cache
```


## Installation

The best way to install Project Init on your working system is to place the bootstrap *run.sh* script from the previous section in a directory of your choice. When you rename the script to "project-init" and make sure that the directory you place it in is on your PATH, then you can launch Project Init conveniently by typing ```project-init``` on your command line. This is exactly what the bootstrap *install.sh* script does for you.

Run the following command to install the bootstrap *run.sh* script on your working system:

with ```wget```:
```bash
bash <(wget -q -O - https://github.com/raven-computing/project-init/raw/v1-latest/bootstrap/install.sh)
```

with ```curl```:
```bash
bash <(curl -sL https://github.com/raven-computing/project-init/raw/v1-latest/bootstrap/install.sh)
```

You will be asked for confirmation. After installation you can use Project Init by simply typing the command:

```bash
project-init
```

The directory where Project Init will be installed depends on the user that executes the command. If you run the *install.sh* script as a regular user, then Project Init is installed in the user's private bin directory "$HOME/.local/bin". That directory should automatically be added to the $PATH environment variable for the underlying user on supported systems.  
If you run the *install.sh* script as root, then Project Init is installed in the system's bin directory "usr/local/bin". This will make the ```project-init``` command available to all users on the system. You might find it more convenient to install Project Init system-wide if managing a multi-user system. Otherwise, if you used on your own personal workstation, we recommend to install it as a regular user.

### Disable Confirmation Prompt

If you want to automate the installation based on your own script or workflow you can specify the ```--yes``` option to skip the confirmation prompt:

with ```wget```:
```bash
bash <(wget -q -O - https://github.com/raven-computing/project-init/raw/v1-latest/bootstrap/install.sh) --yes
```

with ```curl```:
```bash
bash <(curl -sL https://github.com/raven-computing/project-init/raw/v1-latest/bootstrap/install.sh) --yes
```


### Uninstallation

If you have installed Project Init as shown in the previous section and want to uninstall it again, you can use the *install.sh* script with the ```--uninstall``` option. Use the followong command to uninstall:

with ```wget```:
```bash
bash <(wget -q -O - https://github.com/raven-computing/project-init/raw/v1-latest/bootstrap/install.sh) --uninstall
```

with ```curl```:
```bash
bash <(curl -sL https://github.com/raven-computing/project-init/raw/v1-latest/bootstrap/install.sh) --uninstall
```

You will be asked for confirmation. Alternatively, you may also simply remove the *project-init* bootstrap file manually from the file system.
