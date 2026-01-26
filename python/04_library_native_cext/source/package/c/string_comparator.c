${{VAR_COPYRIGHT_HEADER}}

#define PY_SSIZE_T_CLEAN

// Python.h must be the first header to include
#include <Python.h>
#include <string.h>

/**
 * Dummy function comparing two strings using the strcmp() function.
 */
static PyObject* compare(PyObject* self, PyObject* args) {
    const char* str1;
    const char* str2;
    if (!PyArg_ParseTuple(args, "ss", &str1, &str2)) {
        return NULL;
    }
    const int res = strcmp(str1, str2);
    return PyLong_FromLong(res);
}

/**
 * Module method table
 */
static PyMethodDef scMethods[] = {
    {"compare",  compare, METH_VARARGS,
     "Compares two strings using strcmp."},  //Method doc
    {NULL, NULL, 0, NULL}  //Sentinel
};

/**
 * Module definition
 */
static struct PyModuleDef scModule = {
    PyModuleDef_HEAD_INIT,
    "_string_comparator",  //Module name
    "Native implementation of the string_comparator module.",  //Module doc
    -1,  //Size of module state
    scMethods  //Method table
};

/**
 * Module initialization function
 */
PyMODINIT_FUNC PyInit__string_comparator(void) {
    return PyModule_Create(&scModule);
}
