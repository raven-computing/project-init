#### 1.8.2
* Changed _find_subst_vars() function, removed parameter.
* Fixed some issues in build scripts of R project source templates.
* Improved warning() function to ignore duplicate messages.
* Improved Python project source templates.
* Improved code formatting.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.8.1...v1.8.2)

#### 1.8.1
* Added support for R 4.5.0 language standard.
* Added the _file_cache_add() function to add a new file or directory to the file cache array variable. [[Issue#90]](https://github.com/raven-computing/project-init/issues/90)
* Added the _file_cache_remove() function to remove an existing file or directory from the file cache array variable. [[Issue#90]](https://github.com/raven-computing/project-init/issues/90)
* Fixed wrong log warning when directory has dot in filename. [[Issue#92]](https://github.com/raven-computing/project-init/issues/92)
* Fixed minor code formatting issues.
* Improved documentation of file cache usage. [[Issue#93]](https://github.com/raven-computing/project-init/issues/93)
* Improved Linux kernel module project init code.
* Improved Java project init code.
* Improved Python project init code.
* Improved R init code.
* Improved the expand_namespace_direcotory() function implementation.
* Refactored init code to use file processing API functions.
* Refactored file cache updates in copy_resource() function.
* Refactored Docker integration file processing.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.8.0...v1.8.1)

#### 1.8.0
* Added the move_file() API function. [[Issue#63]](https://github.com/raven-computing/project-init/issues/63)
* Added the remove_file() API function. [[Issue#64]](https://github.com/raven-computing/project-init/issues/64)
* Added the write_file() API function. [[Issue#65]](https://github.com/raven-computing/project-init/issues/65)
* Added the append_file() API function. [[Issue#77]](https://github.com/raven-computing/project-init/issues/77)
* Added the file_exists() API function. [[Issue#78]](https://github.com/raven-computing/project-init/issues/78)
* Added the directory_exists() API function. [[Issue#78]](https://github.com/raven-computing/project-init/issues/78)
* Added the replace_str() API function. [[Issue#66]](https://github.com/raven-computing/project-init/issues/66)
* Added support for Python 3.13.
* Added user warning for operating system end of support.
* Added the internal _require_arg() function. [[Issue#80]](https://github.com/raven-computing/project-init/issues/80)
* Added the internal _fail_illegal_call() function. [[Issue#80]](https://github.com/raven-computing/project-init/issues/80)
* Added the internal _ensure_project_files_copied() function.
* Added the _FOUND_ARRAY_MEMBER_IDX variable to the internal _array_contains() utility function.
* Added the '--show-stdout' option to the test.sh script. [[Issue#86]](https://github.com/raven-computing/project-init/issues/86)
* Added the internal PROJECT_INIT_COMPAT_TESTS_ACTIVE variable to distinguish compatibility tests.
* Added a project property to make the default Python version configurable. [[Issue#59]](https://github.com/raven-computing/project-init/issues/59)
* Changed Python version prompt to selection in the form_python_version() API function. [[Issue#73]](https://github.com/raven-computing/project-init/issues/73)
* Changed C and C++ source templates to use pragma once directive instead of header include guards. [[Issue#75]](https://github.com/raven-computing/project-init/issues/75)
* Improved function implementations to adhere to coding conventions.
* Refactored boilerplate checks to use internal functions.
* Removed the now unused _validate_python_version() function and _PYTHON_MIN_VERSION variable. See [[Issue#73]](https://github.com/raven-computing/project-init/issues/73).
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.7.6...v1.8.0)

#### 1.7.6
* Added support for C language standard C17 which was previously held back since it did not introduce any new language features compared to C11 which was already supported. [[Issue#82]](https://github.com/raven-computing/project-init/issues/82)
* Added support for C language standard C23.
* Added support for C++ language standard C++23.
* Added short option '-l' to test script for linter usage, short for '--lint'.
* Improved desktop notifications by showing the app name in the title.
* Improved documentation generator script.
* Refactored the form_cpp_binary_name() and form_c_binary_name() functions.
* Updated Unity dependency version for C projects.
* Updated Gtest dependency version for C++ projects.
* Updated Poco dependency version.
* Updated ImGui dependency version.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.7.5...v1.7.6)

#### 1.7.5
* Fixed prematurely committed version updates to packages in Python projects to stay compatible with Python 3.8.
* Improved Node.js project source templates. [[Issue#69]](https://github.com/raven-computing/project-init/issues/69)
* Improved Node.js project control code. [[Issue#70]](https://github.com/raven-computing/project-init/issues/70)
* Improved Python project control code.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.7.4...v1.7.5)

#### 1.7.4
* Added support for Node.js 22 and removed support for Node.js 16.
* Improved Python project control code source templates.
* Improved implementation of the select_project_type() function.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.7.3...v1.7.4)

#### 1.7.3
* Updated Maven plugin versions.
* Updated Pylint dependency version.
* Updated Python setuptools and related toolchain dependency versions.
* Updated Python packaging source templates.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.7.2...v1.7.3)

#### 1.7.2
* Updated ImGui dependency version.
* Updated Gtest dependency version.
* Updated Python Odoo module project source template to use Odoo v18.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.7.1...v1.7.2)

#### 1.7.1
* Fixed a wrong working directory with the USER_CWD variable when in test mode. [[Issue#57]](https://github.com/raven-computing/project-init/issues/57)
* Fixed failing tests for Java Spring Boot applications when using a database.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.7.0...v1.7.1)

#### 1.7.0
* Added the USER_INPUT_DEFAULT_TEXT variable to set a default text value when using the read_user_input_text() API function. [[Issue#53]](https://github.com/raven-computing/project-init/issues/53)
* Added the USER_INPUT_DEFAULT_INDEX variable to specify a default item index when using the read_user_input_selection() API function. [[Issue#51]](https://github.com/raven-computing/project-init/issues/51)
* Improved documentation. [[Issue#55]](https://github.com/raven-computing/project-init/issues/55)
* Improved setup script for Python project source templates.
* Updated default minimum Python version to 3.8 for all Python project source templates.
* Updated various dependency versions in project source templates.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.6.1...v1.7.0)

#### 1.6.1
* Improved implementation of the project_init_license() function.
* Updated various dependency versions in project source templates.
* Updated supported R versions.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.6.0...v1.6.1)

#### 1.6.0
* Added the project_init_copyright_headers() API function. [[Issue#46]](https://github.com/raven-computing/project-init/issues/46)
* Added the 'sys.baselicenses.disable' project property option to allow addons to disable base licenses. [[Issue#38]](https://github.com/raven-computing/project-init/issues/38)
* Added the PROJECT_INIT_LICENSE_FILE_NAME API global to make license file name configurable. [[Issue#45]](https://github.com/raven-computing/project-init/issues/45)
* Added the internal _load_available_licenses() and _process_copyright_headers() functions.
* Added the internal _PROJECT_AVAILABLE_LICENSES\_* and _PROJECT_SELECTED_LICENSE\_* globals.
* Improved Docker-related project control code to better support arbitrary commands. [[Issue#12]](https://github.com/raven-computing/project-init/issues/12)
* Improved Docker-related project control code by standardising a mechanism for skipping Docker image builds. [[Issue#14]](https://github.com/raven-computing/project-init/issues/14)
* Refactored the project_init_license() and project_init_show_main_form() function implementations.
* Updated supported R versions.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.5.2...v1.6.0)

#### 1.5.2
* Improved shared CMake utility function for C and C++ project source templates. [[Issue#41]](https://github.com/raven-computing/project-init/issues/41)
* Improved test scripts for C and C++ project source templates to better handle multi-config builds. [[Issue#42]](https://github.com/raven-computing/project-init/issues/42)
* Improved internal infrastructure code.
* Updated various dependency versions in project source templates.
* Updated documentation to mention official support via WSL on Windows. [[Issue#43]](https://github.com/raven-computing/project-init/issues/43)
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.5.1...v1.5.2)

#### 1.5.1
* Added support for standard documentation integration in project source templates. [[Issue#34]](https://github.com/raven-computing/project-init/issues/34)
* Fixed documentation text formatting and improved some minor things.
* Improved user input text prompts by allowing line editing. [[Issue#32]](https://github.com/raven-computing/project-init/issues/32)
* Improved Python project source templates by moving build artifacts into the build tree. [[Issue#35]](https://github.com/raven-computing/project-init/issues/35)
* Improved Python project source templates by updating the used build system. [[Issue#10]](https://github.com/raven-computing/project-init/issues/10)
* Refactored some internal seq loop.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.5.0...v1.5.1)

#### 1.5.0
* Added the expand_namespace_directories() API function. [[Issue#2]](https://github.com/raven-computing/project-init/issues/2)
* Added addon mechanism to automatically load custom libraries. [[Issue#26]](https://github.com/raven-computing/project-init/issues/26)
* Added mechanism to define user-specific after-init-hook. [[Issue#25]](https://github.com/raven-computing/project-init/issues/25)
* Added the _cd_or_die() function to safely handle change directory operations.
* Added the _array_contains() function.
* Added linter integration for ShellCheck in test script with --lint option.
* Fixed a bug where the _show_start_title() function would try to read and print the content of a 'title.txt' file under '/' when no addon resource was loaded and such a file actually existed at that location.
* Improved Java init code by not allowing empty namespaces. [[Issue#11]](https://github.com/raven-computing/project-init/issues/11)
* Improved C and C++ libraries project source templates CMake target exports. [[Issue#19]](https://github.com/raven-computing/project-init/issues/19)
* Improved C and C++ project source templates build scripts by providing default configure step control options. [[Issue#21]](https://github.com/raven-computing/project-init/issues/21)
* Improved project source template CMake dependency utility function for C and C++ projects by adding source cache layer. [[Issue#20]](https://github.com/raven-computing/project-init/issues/20)
* Improved Docker integration project source templates by assimilating directory locations. [[Issue#13]](https://github.com/raven-computing/project-init/issues/13)
* Improved how file search is handled in init code, using the _find_files_impl() function instead of calling find command directly.
* Improved how file lists are iterated over, using shell globbing instead of calling ls command directly.
* Refactored lifecycle functions. [[Issue#1]](https://github.com/raven-computing/project-init/issues/1)
* Refactored input prompt definition to _READ_FN_INPUT_PROMPT global.
* Refactored a lot of code by utilizing linter hints.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.4.7...v1.5.0)

#### 1.4.7
* Improved Java isolated builds with Maven cached dependencies when using Docker isolated builds. [[Issue#8]](https://github.com/raven-computing/project-init/issues/8)
* Improved Java builds by adding compiler release option. [[Issue#15]](https://github.com/raven-computing/project-init/issues/15)
* Improved Docker integration when using Java 21. [[Issue#17]](https://github.com/raven-computing/project-init/issues/17)
* Improved Java Readme templates.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.4.6...v1.4.7)

#### 1.4.6
* Improved Python project source templates, updated Pylint version. [[Issue#5]](https://github.com/raven-computing/project-init/issues/5)
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.4.5...v1.4.6)

#### 1.4.5
* Improved bootstrap scripts.
* Improved documentation generator.
* Improved main driver script.
* Improved Python native library with Cython project source template to use Cython v3.
* Improved bootstrap run script by allowing it to be executed as root while in a Docker container. [[Issue#3]](https://github.com/raven-computing/project-init/issues/3)
* Improved Docker integration in project source templates by providing better support for non-rootless Docker.
* See [full changelog](https://github.com/raven-computing/project-init/compare/v1.4.4...v1.4.5)

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
