#### 1.4.4
* Improved Python server application project source template. Added support in the project control code for interactive testing.
* Updated Docker image for Python projects to use Python 3.12 as the base image.
* Updated Node.js versions. Removed v14, added v20.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.4.3...v1.4.4)

#### 1.4.3
* Added language version support for Java 21.
* Changed Java example namespace for form question.
* Fixed minor formatting issue.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.4.2...v1.4.3)

#### 1.4.2
* Fixed wrong handling of special ampersand characters in value of substitution variables when replacing them in the _process_include_directives() function.
* Fixed minor formatting issues.
* Improved project source templates.
* Improved bootstrap installation script.
* Improved test suite.
* Refactored Docker-related files in project source templates to be provided by include directives when used more than once.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.4.1...v1.4.2)

#### 1.4.1
* Fixed some compatibility issues with older Bash versions by avoiding the usage of the '-g' option of the 'declare' builtin.
* Fixed some compatibility issues with older Bash versions by avoiding the usage of negative indices in string expressions.
* Fixed invalid read of USER_INPUT_ENTERED_INDEX when total_number_of_langs is 1 in main form implementation.
* Improved error messages and code formatting.
* Improved project source templates.
* Improved main form license handling by adding missing check for 'DISABLE' info file.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.4.0...v1.4.1)

#### 1.4.0
* Added Quickstart feature.
* Added optional argument to read_user_input_text() function to be able to specify a validation function.
* Added the copy_resource() API function.
* Added PROJECT_INIT_ADDONS_PATH API global.
* Added USER_CWD API global.
* Added PROJECT_INIT_USED_SOURCE API global.
* Added _load_default_subst_vars() and _replace_default_subst_vars() function to load and replace some default substitution variables.
* Added _find_files_impl() function for common files finding operation.
* Added _find_subst_vars() function for common substitution variable finding operation.
* Added _is_absolute_path() internal function used throughout the code base.
* Changed various places in form function implementations where the read_user_input_text() function is called to use a validation function.
* Changed libform.sh main form implementation and refactored common code and setting of substitution variables out into libinit.sh.
* Changed handling of project name form answer to allow spaces in given name and silently convert to underscores.
* Changed implementation of _check_is_valid_project_dir() function and added more return status codes.
* Changed implementation of copy_shared() function to use copy_resource() internally.
* Improved implementations of read_user_input_selection() and read_user_input_yes_no() functions to handle invalid user input by allowing the user to reenter his answer instead of failing by means of the failure() function.
* Improved object name handling for globals in API generator script.
* Improved find_all_files() function implementation.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.3.0...v1.4.0)

#### 1.3.0
* Added a file include feature to remove some duplicated code in project source templates. A source template may delcare the inclusion of another shared template file with the include directive.
* Added C++ desktop GUI application with ImGUI (using GLFW and OpenGL) project type source template.
* Added the _NL internal global variable to hold a literal new line character.
* Added form_docker_integration() API function.
* Added copy_shared() API function.
* Added internal _project_init_process_forms() callback function which will be called by libinit.sh to let other components handle their form processing. Used by libform.sh internally.
* Added 'sys.warn.deprecation' configuration option in project.properties to allow users and/or addons to suppress deprecation warnings.
* Added SUPPRESS_DEPRECATION_WARNING API global to allow addons to suppress specific deprecation warnings.
* Added load_var_from_file() API function and VAR_FILE_VALUE API global.
* Added internal _warn_deprecated() function to standardise how deprecation warnings are shown.
* Changed _check_is_valid_project_dir() function to disallow colon characters (':') in project directory paths.
* Changed internals of replace_var() API function.
* Change 
* Deprecated the load_var() API function. It is superseded by the newly introduced load_var_from_file() API function.
* Fixed some minor code formatting issues.
* Refactored all the language-specific Docker integration form question functions and replaced the corresponding code with calls to the form_docker_integration() API function.
* Refactored substitution variable value files for all project source templates and languages into separate 'var' subdirectories. The naming pattern changed such that the 'var_'-prefix and the '.txt' suffix must be removed. The original behaviour if placing the var files directly into the init level directory is still supported but now deprecated.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.2.1...v1.3.0)

#### 1.2.1
* Updated dependency versions in C++ and Java-JNI project source templates.
* Improved documentation generator script to consider future major version changes automatically when creating document hyperlinks.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.2.0...v1.2.1)

#### 1.2.0
* Added R library with native C++ code using Rcpp project type source template.
* Added Odoo module project type source template.
* Added form_java_native_lib_jni_lang() function in Java init script to let the user choose if he wants C or C++ as the language for the native part of the JNI-based Java library. Added corresponding C source files to project type.
* Added isolated build and test options via Docker for most source templates. This is provided via calls to form_*_add_docker_integration() functions and can be turned off by answering 'No' to the corresponding form question. Docker-related files are put into the '.docker' directory in the source template root. All build.sh and test.sh project control scripts are adjusted to honour a potential Docker integration of the generated project.
* Added project properties to control if the first major form questions for the project name, -description and -license should be asked from the user or have default values globally. Restructured libform.sh show_project_init_main_form() function.
* Added form_r_package_name() function to ask for R library package names.
* Added FORM_QUESTION_ID as public API global so it can be used by addons for testing purposes.
* Added run.sh script to Node.js project source template.
* Added functionality test API and made needed internal functions and globals public for API usage. Adjusted documentation.
* Added test.sh control script for addons.
* Added addons tests project.properties as an example.
* Added addons tests example functionality test case scripts and test parameters.
* Changed bootstrap run.sh script to only make Project Init base resources available without starting the main program when the PROJECT_INIT_BOOTSTRAP_FETCHONLY environment variable is set.
* Changed test.sh control script to allow testing of addons resources via the new --test-path option.
* Changed all affected form_*() functions to mention the FORM_QUESTION_ID global used during testing.
* Changed _load_addons_resource() function to first check for 'project-init-addons-res' and 'project-init-addons-res-branch' config files and let those override any related set environment variables.
* Changed _run_addon_load_hook() function to check exit status of load-hook and show warning if non-zero.
* Changed _run_addon_after_init_hook() function to check exit status of after-init-hook and show warning if non-zero.
* Changed load_var() function to search init level directories in reversed order for var_*.txt files and let lower-level files potentially override higher-level files.
* Changed generate_api_docs.py script to include test-related files containing API functions.
* Changed files.txt to include Docker-, Odoo- and R-related files in project source templates.
* Improved some project source templates.
* Renamed 02_server-shiny to 03_server-shiny project type source template.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.1.5...v1.2.0)

#### 1.1.5
* Improved implementation of project_init_copy() function and add a check for empty project source template directories.
* Improved implementation of find_all_files() function.
* Improved bootstrap run script to also clear local cache directory before initmain is launched.
* Updated supported Node.js versions in project source template.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.1.4...v1.1.5)

#### 1.1.4
* Fixed wrong handling of ampersand characters in value of substitution variables when replacing them with replace_var() function.
* Improved performance by rearranged loading of substitution variable values from var file by calling load_var() function once outside of loop in replace_var() function.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.1.3...v1.1.4)

#### 1.1.3
* Changed _make_func_hl() function to refer to API documentation applicable to correct major version identifier.
* Refactored internal link to project source repository used when creating helptext links.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.1.2...v1.1.3)

#### 1.1.2
* Improved source code and project documentation.
* Improved Java POM project source template formatting.
* Improved start text description.
* Improved selection list item formatting by adding appropriate whitespace padding between list numbers and item names.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.1.1...v1.1.2)

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
