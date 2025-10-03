#!/usr/bin/env python
# Copyright (C) 2025 Raven Computing
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
"""Documentation generator for the Project Init API reference docs."""

import sys
import os
import io
import argparse
import re
import json


# All the files to be considered by the script.
SOURCE_FILES = ["libinit.sh",
                "libform.sh",
                "c/init.sh",
                "cpp/init.sh",
                "java/init.sh",
                "js/init.sh",
                "python/init.sh",
                "r/init.sh",
                "tests/utils.sh",
                "tests/functionality_tests.sh"]

# The name of the file to be created.
OUTPUT_FILE = "api_docs"

# The URL to the Project Init repository.
PROJECT_BASE_URL = "https://github.com/raven-computing/project-init"

# The path to the directory of this script.
DOCS_DIR = os.path.abspath(os.path.dirname(__file__))

# Boolean flag indicating that at least one function
# has encountered some invalid format.
INCORRECT_FORMAT = False

# The base URL to be used when generating links inside
# the generated documentation.
# Use the get_link_base_url() function to get this value.
_LINK_BASE_URL = None

# The Project Init version, as a tuple of version identifiers.
# Use the get_project_init_version() function to get this value.
_PROJECT_INIT_VERSION = "?"

# The used text encoding when reading/writing files.
_FILE_ENCODING = "UTF-8"

def parse_args():
    """Parses the arguments passed to this program.

    Returns:
        The result from the ArgumentParser.parse_args() method.
    """
    parser = argparse.ArgumentParser(
        description="Generates Project Init API documentation "
                    "in Markdown format."
    )
    parser.add_argument(
        "-filter-type",
        required=False,
        metavar="<str>",
        choices=["exitstatus", "global", "function"],
        help="only show the documentation of the specified type. "
             "Must be one of 'exitstatus', 'global', 'function'"
    )
    parser.add_argument(
        "-filter-name",
        required=False,
        metavar="<str>",
        help="only show the documentation for the code object "
             "with the specified name. This argument is interpreted as a regex"
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="save the parsed documentation structure "
             "in JSON format"
    )
    parser.add_argument(
        "--stdout",
        action="store_true",
        help="print the generated output to stdout instead of "
             "saving to a file"
    )

    return parser.parse_args()

def warn(msg):
    """Prints a warning message and marks the doc generation as incorrect.

    Args:
        msg: The warning message to print, as a str.
    """
    global INCORRECT_FORMAT
    INCORRECT_FORMAT = True
    print(f"WARN: {msg}")

def parse_obj_attr(line, doc_type):
    """Parses the specified line to compute the code object attributes.

    The line must representing the first piece of executable code after
    the end of the documentation segment. The list of attributes represents
    relevant appendages and keywords part of the code object, e.g. the
    modifiers of a variable.

    Args:
        line: The first line of code of the documented entity, as a str.
        doc_type: The type of documentation, as a str.
            Must be 'exitstatus', 'global' or 'function'.

    Returns:
        A list of code entity attributes, as a list of str.
    """
    res = []
    if doc_type in ("global", "exitstatus"):
        tokens = line.split(sep="=")[0].split()
        res = tokens[:-1]

    return res

def parse_obj_name(line, doc_type):
    """Parses the specified line to compute the code object name.

    The line must representing the first piece of executable code after
    the end of the documentation segment. The name represents the
    identifying name of the code object, e.g. the name of the function
    or variable, which is documented in the comments above
    the specified line.

    Args:
        line: The first line of code of the documented entity, as a str.
        doc_type: The type of documentation, as a str.
            Must be 'exitstatus', 'global' or 'function'.

    Returns:
        The identifying name of the documented code entity, as a str.
    """
    name = ""
    if doc_type == "function":
        name = line[9:-4]
    elif doc_type == "global":
        name = line.split(sep="=")[0].split()[-1]
    elif doc_type == "exitstatus":
        name = line.split(sep="=")[0].split()[-1]
    else:
        warn(f"Cannot parse object name for document type '{doc_type}'")

    return name

def parse_obj_definition(src_lines, doc, doc_type):
    """Parses the specified source lines to compute information about
    the definition of the code object which is documented by the specified
    doc segment slice.

    Args:
        src_lines: All lines of the corresponding source file to parse,
            as a list of str.
        doc: A slice denoting the start and end position of
            the document segment which precedes the definition of
            the underlying code object.
        doc_type: The type of documentation as framed by the doc
            slice argument, as a str.
            Must be 'exitstatus', 'global' or 'function'.

    Returns:
        A dict holding information about the code object definition,
        e.g. relevant numbers of code lines.
    """
    definition = {}
    doc_lines = src_lines[doc]
    first_src_line = doc_lines[-1]
    if doc_type == "function":
        if not first_src_line.strip().endswith("{"):
            warn("Incorrect function definition "
                f"statement: '{first_src_line}' (at line {doc.stop})")

        line_begin = doc.stop
        line_end = line_begin
        while not src_lines[line_end].strip().startswith("}"):
            line_end += 1

        line_end += 1
        definition = {
            "line": "{}:{}".format(line_begin, line_end)
        }
    elif doc_type in ("exitstatus", "global"):
        val = first_src_line.split(sep="=")[1].replace(";", "").split()[-1]
        definition = {
            "line": str(doc.stop)
        }
        if val != "\"\"":
            definition["value"] = val

    else:
        warn("Cannot parse object definition "
            f"for document type '{doc_type}'")

    return definition

def parse_doc_type(line):
    """Parses the specified line representing a documentation declaration.

    Args:
        line: The source code documentation declaration line, as a str.

    Returns:
        The internal name of the documentation type, as a str.
        Is one of 'exitstatus', 'global', 'function' or an empty str
        if the doc type is unrecognised.
    """
    doc_type = ""
    if line == "# [API function]":
        doc_type = "function"
    elif line == "# [API Global]":
        doc_type = "global"
    elif line == "# [API Exit Code]":
        doc_type = "exitstatus"
    else:
        warn(f"Unknown document type '{line}'")

    return doc_type

def parse_obj_text(lines):
    """Parses the specified lines representing the documentation main text.

    Args:
        lines: The documentation main text lines, as a list of str.

    Returns:
        The documentation main text, as a single str.
    """
    lines = [line[1:].strip() for line in lines]

    keywords = ("Args:", "Stdout:", "Stderr:", "Returns:",
                "Globals:", "Examples:", "Since:", "Deprecated:")

    ikeys = [i for i, line in enumerate(lines) if line in keywords]

    first_key = min(ikeys) if len(ikeys) > 0 else len(lines)

    text = "\n".join(lines[:first_key])
    return text.strip("\n")

def parse_obj_key_text_since(key_lines):
    """Parses the specified lines representing the documentation
    main text's "Since" segment.

    Args:
        key_lines: The documentation main text's "Since" lines,
            as a list of str.

    Returns:
        The text of the main documentation's "Since" segment,
        as a str.
    """
    key_lines = [line[1:] if line and line[0] == " " else line
                for line in key_lines]

    return " ".join(key_lines).strip()

def parse_obj_key_text_deprecated(key_lines):
    """Parses the specified lines representing the documentation
    main text's "Deprecated" segment.

    Args:
        key_lines: The documentation main text's "Deprecated" lines,
            as a list of str.

    Returns:
        The text of the main documentation's "Deprecated" segment,
        as a str.
    """
    key_lines = [line[1:] if line and line[0] == " " else line
                for line in key_lines]

    return " ".join(key_lines).strip()

def parse_obj_key_list_args(key_lines):
    """Parses the specified lines representing the documentation
    main text's "Args" segment.

    Args:
        key_lines: The documentation main text's "Args" lines,
            as a list of str.

    Returns:
        A list holding a list of size 2 for each declared argument.
        The first item of each inner list is the argument name,
        the second item is the argument doc text.
    """
    key_lines = [line.strip() for line in key_lines]
    key_text = "\n".join(key_lines)
    key_list = []
    pattern = r"(\$\d+|\$\*|\$\@)"
    tokens = list(filter(bool, re.split(pattern, key_text)))
    iargs = [i for i, token in enumerate(tokens) if re.match(pattern, token)]
    if len(iargs) > 0:
        for argname_idx in iargs[:-1]:
            argname = tokens[argname_idx]
            argtext = tokens[argname_idx+1].strip()     \
                                           .strip("-")  \
                                           .strip()     \
                                           .strip("\n")

            key_list.append([argname, argtext])

        last = iargs[-1]
        argname = tokens[last]
        argtext = tokens[last+1].strip().strip("-").strip().strip("\n")
        key_list.append([argname, argtext])

    return key_list

def parse_obj_key_text_stdouterr(key_lines):
    """Parses the specified lines representing the documentation
    main text's "Stdout" or "Stderr" segment.

    Args:
        key_lines: The documentation main text's "Stdout" or "Stderr" lines,
            as a list of str.

    Returns:
        The text of the main documentation's "Stdout" or "Stderr" segment,
        as a str.
    """
    key_lines = [line[1:] if line and line[0] == " " else line
                for line in key_lines]

    return " ".join(key_lines).strip()

def parse_obj_key_list_returns(key_lines):
    """Parses the specified lines representing the documentation
    main text's "Returns" segment.

    Args:
        key_lines: The documentation main text's "Returns" lines,
            as a list of str.

    Returns:
        A list holding a list of size 2 for each declared return value.
        The first item of each inner list is the return value,
        the second item is the return value's doc text.
    """
    key_lines = [line.strip() for line in key_lines]
    key_text = "\n".join(key_lines)
    key_list = []

    lines = key_text.split("\n")
    begins = [i for i, line in enumerate(lines) if " - " in line]

    for i, begin_idx in enumerate(begins):
        line = lines[begin_idx]
        tokens = line.split(" - ")
        retval = tokens[0].strip()
        rettext = tokens[1].strip().strip("-").strip()
        sfrom = begin_idx+1
        suntil = len(lines) if (i == len(begins)-1) else begins[i+1]
        to_append = " ".join(lines[sfrom:suntil])
        rettext += " " + to_append
        key_list.append([retval, rettext])

    return key_list

def parse_obj_key_list_globals(key_lines):
    """Parses the specified lines representing the documentation
    main text's "Globals" segment.

    Args:
        key_lines: The documentation main text's "Globals" lines,
            as a list of str.

    Returns:
        A list holding a list of size 2 for each declared global variable.
        The first item of each inner list is the name of the global variable,
        the second item is the variable's doc text.
    """
    key_lines = [line.strip() for line in key_lines]
    key_text = "\n".join(key_lines)
    key_list = []

    lines = key_text.split("\n")
    begins = [i for i, line in enumerate(lines) if " - " in line]

    for i, begin_idx in enumerate(begins):
        line = lines[begin_idx]
        tokens = line.split(" - ")
        globalname = tokens[0].strip()
        globaltext = tokens[1].strip().strip("-").strip()
        sfrom = begin_idx+1
        suntil = len(lines) if (i == len(begins)-1) else begins[i+1]
        to_append = " ".join(lines[sfrom:suntil])
        globaltext += " " + to_append
        key_list.append([globalname, globaltext])

    return key_list

def parse_obj_key_text_examples(key_lines):
    """Parses the specified lines representing the documentation
    main text's "Examples" segment.

    Args:
        key_lines: The documentation main text's "Examples" lines,
            as a list of str.

    Returns:
        The text of the main documentation's "Example" segment, as a str.
    """
    key_lines = [line[1:] if line and line[0] == " " else line
                 for line in key_lines]

    return "\n".join(key_lines)

def parse_obj_keys(lines):
    """Parses the specified lines representing the documentation main text.

    Args:
        lines: The documentation main text lines, as a list of str.

    Returns:
        The documentation main text's key segments, as a dict.
    """
    keys = {
        "Since:": "",
        "Deprecated:": "",
        "Args:": [],
        "Stdout:": "",
        "Stderr:": "",
        "Returns:": [],
        "Globals:": [],
        "Examples:": "",
    }
    lines = [line[1:] for line in lines]

    keywords = tuple(keys.keys())

    ikeys = [i for i, line in enumerate(lines) if line.strip() in keywords]

    if len(ikeys) > 0:
        for i, line_idx in enumerate(ikeys[:-1]):
            key_lines = lines[line_idx+1:ikeys[i+1]]
            key = lines[line_idx].strip()
            if key in keys:
                if key == "Since:":
                    keys[key] = parse_obj_key_text_since(key_lines)
                elif key == "Deprecated:":
                    keys[key] = parse_obj_key_text_deprecated(key_lines)
                elif key == "Args:":
                    keys[key] = parse_obj_key_list_args(key_lines)
                elif key in ("Stdout:", "Stderr:") :
                    keys[key] = parse_obj_key_text_stdouterr(key_lines)
                elif key == "Returns:":
                    keys[key] = parse_obj_key_list_returns(key_lines)
                elif key == "Globals:":
                    keys[key] = parse_obj_key_list_globals(key_lines)
                elif key == "Examples:":
                    keys[key] = parse_obj_key_text_examples(key_lines)
                else:
                    warn(f"Unknown object key '{key}'")

        key_lines = lines[ikeys[-1]+1:]
        key = lines[ikeys[-1]].strip()
        if key in keys:
            if key == "Since:":
                keys[key] = parse_obj_key_text_since(key_lines)
            elif key == "Deprecated:":
                keys[key] = parse_obj_key_text_deprecated(key_lines)
            elif key == "Args:":
                keys[key] = parse_obj_key_list_args(key_lines)
            elif key in ("Stdout:", "Stderr:") :
                keys[key] = parse_obj_key_text_stdouterr(key_lines)
            elif key == "Returns:":
                keys[key] = parse_obj_key_list_returns(key_lines)
            elif key == "Globals:":
                keys[key] = parse_obj_key_list_globals(key_lines)
            elif key == "Examples:":
                keys[key] = parse_obj_key_text_examples(key_lines)
            else:
                warn(f"Unknown object key '{key}'")

    return keys

def parse_doc_segment(src_file, src_lines, doc):
    """Parses the documentation segment, which is inside all of
    the specified source lines, denoted by the specified slice.

    Args:
        src_file: The path to the source file which contains
            the specified lines, as a str.
        src_lines: All lines of the source file to parse,
            as a list of str.
        doc: A slice denoting the start and end position of
            the document segment to parse.

    Returns:
        The parsed documentation segment, as a dict.
    """
    segment = {
        "file": src_file,
        "type": "",
        "name": "",
        "attr": [],
        "definition": {},
        "text": "",
        "since": "",
        "deprecated": "",
        "args": [],
        "stdout": "",
        "stderr": "",
        "returns": [],
        "globals": [],
        "examples": "",
    }

    doc_lines = remove_shellcheck_directives(src_lines[doc])
    segment["type"] = parse_doc_type(doc_lines[0])
    segment["name"] = parse_obj_name(doc_lines[-1], segment["type"])
    segment["attr"] = parse_obj_attr(doc_lines[-1], segment["type"])
    segment["definition"] = parse_obj_definition(
        src_lines, doc, segment["type"]
    )
    segment["text"] = parse_obj_text(doc_lines[1:-1])
    keys = parse_obj_keys(doc_lines[1:-1])
    segment["since"] = keys["Since:"]
    segment["deprecated"] = keys["Deprecated:"]
    segment["args"] = keys["Args:"]
    segment["stdout"] = keys["Stdout:"]
    segment["stderr"] = keys["Stderr:"]
    segment["returns"] = keys["Returns:"]
    segment["globals"] = keys["Globals:"]
    segment["examples"] = keys["Examples:"]

    return segment

def parse_source_file(src_file):
    """Parses the specified source file and returns an intermediate
    structure describing the source code documentation.

    Args:
        src_file: The path to the source file to read and parse,
            as a str.

    Returns:
        An intermediate structure, as a dict.
    """
    project_root = os.path.split(DOCS_DIR)[0]
    source = ""
    file_path = f"{project_root}/{src_file}"
    with open(file_path, "rt", encoding=_FILE_ENCODING) as file:
        source = file.read()

    source = source.splitlines()
    nlines = len(source)
    doc_lines = []
    for i, line in enumerate(source, 1):
        if line.startswith("# [API "):
            i_comment_end = i
            while source[i_comment_end].startswith("#"):
                i_comment_end += 1
                if i_comment_end >= nlines:
                    warn(
                        "Source file has trailing documentation segment "
                        f"without any code lines: '{src_file}' (at line {i})"
                    )
                    break

            if not INCORRECT_FORMAT:
                doc_lines.append(slice(i-1, i_comment_end+1))

    doc_segments = []
    for doc in doc_lines:
        try:
            doc_segments.append(parse_doc_segment(src_file, source, doc))
        except IndexError:
            warn(f"Invalid documentation format in source file: '{src_file}'")

    parsed = {
        "file": src_file,
        "docs": doc_segments
    }
    return parsed

def remove_shellcheck_directives(doc_lines):
    """Removes any Shellcheck 'disable' directives.

    Args:
        doc_lines: The documentation main text lines, as a list of str.

    Returns:
        The given documentation main text lines with Shellcheck directives
        removed from the list, as a list of str.
    """
    return [
        line for line in doc_lines
        if not line.startswith("# shellcheck disable=SC")
    ]

def filter_docs(files, func, merge_files=True):
    """Filters the specified intermediate structure by applying
    the specified function on each documentation entry.

    Args:
        files: The intermediate structure of the source code documentation,
            as a dict.
        func: The function to use for the filter, as a callable.
            Must accept a single argument (the doc entry) and return a
            bool indicating whether to keep (True) the underlying doc
            entry or discard it (False).
        merge_files: A boolean flag indicating whether to collapse the
            documentation entries of all files into a single list in
            the returned structure. If this is False, then the
            structure as in the input is preserved.

    Returns:
        A list containing all documentation objects for which the specified
        filter function is true.
    """
    l = []
    for source in files:
        docs = list(filter(func, source["docs"]))
        if merge_files:
            l.extend(docs)
        else:
            if len(docs) > 0:
                l.append({
                    "file": source["file"],
                    "docs": docs
                    }
                )

    return l

def filter_docs_by_type(files, doctype, merge_files=True):
    """Filters the specified intermediate structure to only contain
    the documentation of the specified type.

    Args:
        files: The intermediate structure of the source code documentation,
            as a dict.
        doctype: The type of documentation to filter for, as a str.
        merge_files: A boolean flag indicating whether to collapse the
            documentation entries of all files into a single list in
            the returned structure. If this is False, then the
            structure as in the input is preserved.

    Returns:
        A list containing all documentation objects which have
        the specified doc type.
    """
    return filter_docs(files, lambda doc: doc["type"] == doctype, merge_files)

def filter_docs_by_name(files, pattern, merge_files=True):
    """Filters the specified intermediate structure to only contain
    the documentation of the code objects with the specified name.

    Args:
        files: The intermediate structure of the source code documentation,
            as a dict.
        pattern: The name pattern of documentation object to filter for,
            as a regex str.
        merge_files: A boolean flag indicating whether to collapse the
            documentation entries of all files into a single list in
            the returned structure. If this is False, then the
            structure as in the input is preserved.

    Returns:
        A list containing all documentation objects which have
        the specified name.
    """
    return filter_docs(
        files,
        lambda doc: re.match(pattern, doc["name"]),
        merge_files
    )

def get_all_names_for_doctype(files, doctype):
    """Returns all code entity names for which the attached
    documentation is of the specified type.

    The computed list is not controlled for potential duplicates.

    Args:
        files: The intermediate structure of the source code documentation,
            as a dict.
        doctype: The type of documentation to filter for, as a str.

    Returns:
        A list of all code entity identifying names contained in the specified
        intermediate structure which have the specifed doc type.
    """
    return [doc["name"] for doc in filter_docs_by_type(files, doctype)]

def process_doc_text_markdown(files):
    """Processes the text documentation segments in place.

    The text is transformed to fit the Markdown format.

    Args:
        files: The intermediate structure of the source code documentation,
            as a dict.
    """
    for source in files:
        for doc in source["docs"]:
            text = doc["text"]
            text = list(text.replace("\n\n", "  \n\n"))
            for i, char in enumerate(text[1:-1], 1):
                if char == "\n"                       \
                    and text[i-1] not in ("\n", "|")  \
                    and text[i+1] != "\n":

                    text[i] = " "

            text = "".join(text)
            doc["text"] = text
            for arg in doc["args"]:
                arg_text = arg[1]
                arg_text = arg_text.replace("\n", " ")
                arg[1] = arg_text

            for ret in doc["returns"]:
                ret_text = ret[1]
                ret_text = ret_text.replace("\n\n", "  \n\n")
                ret[1] = ret_text

            for glob in doc["globals"]:
                glob_text = glob[1]
                glob_text = glob_text.replace("\n", " ")
                glob[1] = glob_text

def transform_link_global(text, all_globals):
    """Transforms the specified identifying name of a source code
    global variable to a linked text entry.

    Args:
        text: The text name of the global variable to potentially transform,
            as a str.
        all_globals: The list of all global variable names to consider
            in the transformation, as a list of str.

    Returns:
        The potentially transformed global variable name, as a str.
    """
    if text in all_globals:
        glob_ref = "#{}".format(text.lower().replace(" ", "-"))
        text = "[{}]({})".format(text, glob_ref)

    return text

def transform_link_text(text, all_globals, all_functions):
    """Transforms the specified source code documentation text
    to include linked text entries.

    Args:
        text: The doc text to transform, as a str.
        all_globals: The list of all global variable names to consider
            in the transformation, as a list of str.
        all_functions: The list of all function names to consider
            in the transformation, as a list of str.

    Returns:
        The transformed doc text, as a str.
    """
    for glob in all_globals:
        glob_ref = "#{}".format(glob.lower().replace(" ", "-"))
        text = text.replace(
            " ${} ".format(glob),
            " [{}]({}) ".format(glob, glob_ref)
        )
        text = text.replace(
            " ${}.".format(glob),
            " [{}]({}).".format(glob, glob_ref)
        )
        text = text.replace(
            " ${},".format(glob),
            " [{}]({}),".format(glob, glob_ref)
        )
    for func in all_functions:
        func_ref = "#{}".format(func.lower().replace(" ", "-"))
        text = text.replace(
            " {}() ".format(func),
            " [{}\\(\\)]({}) ".format(func, func_ref)
        )

    return text

def create_doc_text_links(files, all_globals, all_functions):
    """Transforms all documentation text entries in the specified
    intermediate structure to include linked text entries.

    Args:
        files: The intermediate structure of the source code documentation,
            as a dict.
        all_globals: The list of all global variable names to consider
            in the transformation, as a list of str.
        all_functions: The list of all function names to consider
            in the transformation, as a list of str.
    """
    for source in files:
        for doc in source["docs"]:
            doc["text"] = transform_link_text(
                doc["text"], all_globals, all_functions
            )
            for arg in doc["args"]:
                arg[1] = transform_link_text(
                    arg[1], all_globals, all_functions
                )

            for ret in doc["returns"]:
                ret[1] = transform_link_text(
                    ret[1], all_globals, all_functions
                )

            for glob in doc["globals"]:
                glob[0] = transform_link_global(
                    glob[0], all_globals
                )
                glob[1] = transform_link_text(
                    glob[1], all_globals, all_functions
                )

            if doc["deprecated"]:
                doc["deprecated"] = transform_link_text(
                    doc["deprecated"], all_globals, all_functions
                )

def get_link_base_url():
    """Gets the base URL to be used when generating links inside
    the generated documentation.

    Returns:
        The base URL used for hyperlinks.
    """
    global _LINK_BASE_URL
    if _LINK_BASE_URL is not None:
        return _LINK_BASE_URL

    version = get_project_init_version()
    major_version = version[0]
    _LINK_BASE_URL = "{}/blob/v{}-latest".format(
        PROJECT_BASE_URL,
        major_version
    )

    return _LINK_BASE_URL

def get_project_init_version():
    """Gets the version information for the Project Init system.

    The returned 4-tuple has types (int, int, int, str).

    Returns:
        A 4-tuple holding the major-minor-patch-postfix information,
        or None if the version could not be determined.
    """
    global _PROJECT_INIT_VERSION
    if _PROJECT_INIT_VERSION != "?":
        return _PROJECT_INIT_VERSION

    project_root = os.path.split(DOCS_DIR)[0]
    version_file = project_root + "/VERSION"
    if os.path.isfile(version_file):
        version_str = ""
        with open(version_file, "rt", encoding=_FILE_ENCODING) as file:
            version_str = file.readline()

        if version_str:
            version_str = version_str.replace("\n", "")
            # Check is valid version string
            is_valid = re.match(r"^[0-9]+\.[0-9]+\.[0-9]+(-dev)?$", version_str)
            if not is_valid:
                warn(f"Invalid version string: '{version_str}'")
                _PROJECT_INIT_VERSION = None
                return None

            vitems = version_str.replace("-", ".").split(".")
            if len(vitems) in (3, 4):
                vmajor = vitems[0]
                vminor = vitems[1]
                vpatch = vitems[2]
                vpostfix = ""
                if len(vitems) == 4:
                    vpostfix = vitems[3]

                _PROJECT_INIT_VERSION = (
                    int(vmajor), int(vminor), int(vpatch), vpostfix
                )
                return _PROJECT_INIT_VERSION

    _PROJECT_INIT_VERSION = None
    return None

def get_intermediate_structure_json(docs):
    """Gets the specified documentation intermediate structure
    in a readable JSON format.

    Args:
        docs: The intermediate structure of the source code documentation,
            as a dict or list.

    Returns:
        The intermediate structure as a JSON-encoded str.
    """
    return json.dumps(docs, indent=2)

def save_to_file(content, filename):
    """Saves the specified text content to the specified file.

    Args:
        content: The text content to save, as a str.
        filename: The name of the file to save, as a str.
    """
    file_path = f"{DOCS_DIR}/{filename}"
    with open(file_path, "wt", encoding=_FILE_ENCODING) as file:
        file.write(content)

def create_markdown_content(docs):
    """Generates a Markdown-formatted text documentation from the
    specified documentation intermediate structure.

    Args:
        docs: The intermediate structure of the source code documentation,
            as a dict.

    Returns:
        The source code documentation in Markdown format, as a str.
    """
    process_doc_text_markdown(docs)

    all_exitstatus = filter_docs_by_type(docs, "exitstatus")
    all_globals = filter_docs_by_type(docs, "global")
    all_functions = filter_docs_by_type(docs, "function")

    # names_exitstatus = get_all_names_for_doctype(docs, "exitstatus")
    names_globals = get_all_names_for_doctype(docs, "global")
    names_functions = get_all_names_for_doctype(docs, "function")

    all_exitstatus.sort(key=lambda status: status["definition"]["value"])
    all_globals.sort(key=lambda glob: glob["name"])
    all_functions.sort(key=lambda func: func["name"])

    create_doc_text_links(docs, names_globals, names_functions)

    buffer = io.StringIO()

    buffer.write("# Project Init: API Reference\n\n")

    link_base_url = get_link_base_url()

    version = get_project_init_version()
    if version is not None:
        vmajor = version[0]
        vminor = version[1]
        vpatch = version[2]
        vpostfix = version[3]
        buffer.write("This document is the API reference for the ")
        buffer.write(f"Project Init system v{vmajor}.{vminor}.{vpatch}")
        if vpostfix:
            buffer.write(f"-{vpostfix}")
            if vpostfix == "dev":
                buffer.write(" (Development Version)")

        buffer.write("\n\n")

    if len(all_exitstatus) > 0:
        buffer.write("# **Exit Codes**\n\n")
        buffer.write("| Code          |              |      |\n")
        buffer.write("|:-------------:|:-------------|:-----|\n")

    for exitstatus in all_exitstatus:
        buffer.write("| {} | {} | {} |\n".format(
            exitstatus["definition"]["value"],
            exitstatus["name"],
            exitstatus["text"]
        ))

    if len(all_globals) > 0:
        buffer.write("\n\n")
        buffer.write("# **Globals**\n\n")

    for glob in all_globals:
        buffer.write("## **{}**\n".format(glob["name"]))
        src_file  = glob["file"]
        line = glob["definition"]["line"]
        buffer.write(f"[\\[source\\]]({link_base_url}/{src_file}#L{line})\n\n")
        if "readonly" in glob["attr"]:
            buffer.write("Attributes: \\[**constant**\\]\n\n")

        buffer.write(glob["text"])

        if glob["since"]:
            buffer.write("\n\n")
            buffer.write("**Since:** ")
            buffer.write(glob["since"])

        if glob["deprecated"]:
            buffer.write("\n\n")
            buffer.write(":warning:  \n**Deprecated:** ")
            buffer.write(glob["deprecated"])

        buffer.write("\n\n---\n\n")

    if len(all_functions) > 0:
        buffer.write("# **Functions**\n\n")

    for func in all_functions:
        buffer.write("## **{}\\(\\)**\n".format(func["name"]))
        src_file = func["file"]
        lbegin, lend = func["definition"]["line"].split(":")
        buffer.write(
            f"[\\[source\\]]({link_base_url}/{src_file}#L{lbegin}-L{lend})\n\n"
        )
        buffer.write(func["text"])
        buffer.write("\n")

        if func["since"]:
            buffer.write("\n")
            buffer.write("**Since:** ")
            buffer.write(func["since"])
            buffer.write("\n")

        if func["deprecated"]:
            buffer.write("\n")
            buffer.write(":warning:  \n**Deprecated:** ")
            buffer.write(func["deprecated"])
            buffer.write("\n")

        if len(func["args"]) > 0:
            buffer.write("\n")
            buffer.write("**Arguments:**\n\n")
            buffer.write("|      |              |\n")
            buffer.write("|:-----|:-------------|\n")
            for farg in func["args"]:
                buffer.write("| {} | {} |\n".format(farg[0], farg[1]))

        if func["stdout"]:
            buffer.write("\n")
            buffer.write("**Stdout:**\n\n")
            buffer.write(func["stdout"])
            buffer.write("\n")

        if func["stderr"]:
            buffer.write("\n")
            buffer.write("**Stderr:**\n\n")
            buffer.write(func["stderr"])
            buffer.write("\n")

        if len(func["returns"]) > 0:
            buffer.write("\n")
            buffer.write("**Returns:**\n\n")
            buffer.write("|      |              |\n")
            buffer.write("|:-----|:-------------|\n")
            for fret in func["returns"]:
                buffer.write("| {} | {} |\n".format(fret[0], fret[1]))

        if len(func["globals"]) > 0:
            buffer.write("\n")
            buffer.write("**Globals:**\n\n")
            buffer.write("|      |              |\n")
            buffer.write("|:-----|:-------------|\n")
            for fglob in func["globals"]:
                buffer.write("| {} | {} |\n".format(fglob[0], fglob[1]))

        if func["examples"]:
            buffer.write("\n")
            buffer.write("**Examples:**\n\n")
            buffer.write("```bash\n")
            buffer.write(func["examples"])
            buffer.write("```\n")

        buffer.write("\n\n---\n\n")

    return buffer.getvalue()

def main():
    args = parse_args()
    docs = []
    for source_file in SOURCE_FILES:
        docs.append(parse_source_file(source_file))

    if args.filter_type is not None:
        docs = filter_docs_by_type(docs, args.filter_type, merge_files=False)

    if args.filter_name is not None:
        docs = filter_docs_by_name(docs, args.filter_name, merge_files=False)

    if args.json:
        docs = get_intermediate_structure_json(docs)
        if args.stdout:
            print(docs)
        else:
            save_to_file(docs, OUTPUT_FILE + ".json")
    else:
        markdown = create_markdown_content(docs)
        if args.stdout:
            print(markdown)
        else:
            save_to_file(markdown, OUTPUT_FILE + ".md")

    return 0 if not INCORRECT_FORMAT else 1


if __name__ == "__main__":
    sys.exit(main())
