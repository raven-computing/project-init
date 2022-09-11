${{VAR_COPYRIGHT_HEADER}}
"""Implementation of the Comparator ABC using strings."""

import sys
import ctypes

from ctypes.util import find_library

from ${{VAR_NAMESPACE_DECLARATION}}.comparator import Comparator


def _load_native_library():
    """Loads the native library on which this module depends on.

    Returns:
        The ctypes CDLL native library object.
    """
    libname = "msvcrt" if sys.platform.lower().startswith("win") else "c"
    lib = find_library(libname)
    libc = ctypes.CDLL(lib)
    return libc


class StringComparator(Comparator):
    """An implementation of the Comparator ABC using strings.

    This implementation only supports comparing strings containing
    ASCII characters.
    This class uses the native strcmp() C function for string comparisons.
    """

    # Object representing the loaded native DLL/shared library
    _CDLL_LIB_C = _load_native_library()

    def __init__(self, val="${{VAR_PROJECT_SLOGAN_STRING}}"):
        """Constructs a new StringComparator object for comparing
        strings with the specified string object.

        Args:
            val: The str used for all comparisons. May not be None
        """
        if val is None:
            raise TypeError("Invalid argument. None is not allowed")

        super().__init__(val)

    def compare(self, val):
        """Compares the specified string to the set string
        of this StringComparator.

        Args:
            val: The string with which to compare, as a str.

        Returns:
            An int indicating the result of the comparison.
            Returns 0 (zero) if both strings are equal.
            Returns a negative int value if the set string is less than
            the specified string.
            Returns a positive int value if the set string is greater
            than the specified string.

        Raises:
            ValueError: If either the internal or specified string
                cannot be encoded to ASCII bytes.
        """
        self.ncalls += 1
        if val is None:
            raise TypeError("Invalid argument. Cannot compare with None")

        return self._compare_native_0(val)

    def _compare_native_0(self, val):
        """Implementation of compare() method using native function calls.

        Args:
            val: The string with which to compare, as a str.

        Returns:
            An int indicating the result of the strcmp() comparison.
        """
        # Convert str to bytes objects
        arg1 = str(self.val).encode(encoding="ascii")
        arg2 = str(val).encode(encoding="ascii")
        # Get the function pointer to the C function
        _cfunc = StringComparator._CDLL_LIB_C.strcmp
        # Specify C function return type
        _cfunc.restype = ctypes.c_int
        # Call C function and convert arguments to corresponding C types
        res = _cfunc(ctypes.c_char_p(arg1), ctypes.c_char_p(arg2))
        # As the return type is a c_int, we get a Python int and return it as is
        return res
