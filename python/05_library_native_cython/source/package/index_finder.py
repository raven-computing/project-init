${{VAR_COPYRIGHT_HEADER}}
"""Implementation of the `Finder` ABC using strings."""

try:
    import ${{VAR_NAMESPACE_DECLARATION}}._index_finder as internal_impl # pyright: ignore [reportMissingImports]
except ModuleNotFoundError:
    raise ImportError("C extension module must be compiled with Cython") from None

from ${{VAR_NAMESPACE_DECLARATION}}.finder import Finder


class IndexFinder(Finder):
    """An implementation of the `Finder` ABC using strings.

    This implementation finds the index of a character within
    the set string of an `IndexFinder` object.
    """

    def __init__(self, data: str):
        """Initializes a new `IndexFinder` object for searching in
        the specified string object.

        Args:
            data (str): The string to be searched. As a str. May not be `None`.
        """
        if data is None:
            data = list("${{VAR_PROJECT_SLOGAN_STRING}}")

        super().__init__(data)

    def find(self, val):
        self.ncalls += 1
        if val is None:
            raise TypeError("Invalid argument. Cannot compare with None")

        return self._compare_native_0(val)

    def _compare_native_0(self, val):
        """Implementation of `find()` using native function calls."""
        return internal_impl.find_index(self.data, val)

