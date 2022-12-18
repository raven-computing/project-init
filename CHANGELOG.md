#### 1.1.1
* Fixed usage of sub() awk function in replace_var() causing unreplaced substitution variables when using the same key multiple times on the same line of a source template. Changed to use gsub() awk function instead to always match all keys globally.
* Improved project source templates.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.1.0...v1.1.1)

#### 1.1.0
* Added desktop success notifications with programming language icons when a new project is initialized.
* Added *sys.notification.success.show* system property.
* Added PROJECT_INIT_SUCCESS_MESSAGE global variable to customize final success message.
* Added make_hyperlink() API function and HYPERLINK_VALUE global variable to create clickable links with terminal escape codes. Can be used when logging information.
* Added *sys.output.hyperlinks.escape* system property.
* Added functionality tests to test suite.
* Added _get_form_answer() function to automatically get the set answers. Used in test mode.
* Changed _load_configuration() function to consider test mode configuration.
* Changed logW() and logE() functions to track the number of logged warnings and errors.
* Changed _read_properties() function to take the variable to populate via an argument.
* Changed form question functions and main form implementation to set the FORM_QUESTION_ID variable before calling read user input functions.
* Changed many functions to include hyperlinks when logging warnings/errors/failures to point to the relevant documentation.
* Changed finish_project_init() function to return the application status code instead if directly calling exit() with it.
* Improved error messages to include various help texts links.
* Improved read_user_input_selection() function to also accept the item text as input, instead of just their list number.
* Improved addon documentation and example code.
* Improved base init script code.
* Improved documentation generator script.
* Improved project source templates.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.0.4...v1.1.0)

#### 1.0.4
* Fixed handling of short form help argument.
* Improved project and source documentation.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.0.3...v1.0.4)

#### 1.0.3
* Improved reading of text files.
* Improved documentation.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.0.2...v1.0.3)

#### 1.0.2
* Added missing license processing for GPL-2 and BSL-1 in R library project type.
* Fixed minor typos in project.properties file.
* Improved file reading of dependencies.txt files.
* Improved release script.
* Updated dependency versions in project source templates.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.0.1...v1.0.2)

#### 1.0.1
* Fixed overwriting of current working directory when calling init main entry point in bootstrap run.sh script.
* Improved warning message when the common copyright header substitution variable is in the set of unreplaced variables.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.0.0...v1.0.1)

#### 1.0.0
* Open source release
