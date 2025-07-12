${{VAR_COPYRIGHT_HEADER}}
"""Implementation of the Finder ABC using strings."""

try:
    import ${{VAR_NAMESPACE_DECLARATION}}._index_finder as internal_impl # pyright: ignore [reportMissingImports]
except ModuleNotFoundError:
    raise ImportError("C extension module must be compiled with Cython") from None

from ${{VAR_NAMESPACE_DECLARATION}}.finder import Finder


class IndexFinder(Finder):
    """An implementation of the Finder ABC using strings.

    This implementation finds the index of a character within
    the set string of an IndexFinder object.
    """

    def __init__(self, data=None):
        """Constructs a new IndexFinder object for searching in
        the specified string object.

        Args:
            data: The string to be searched. As a str. May not be None
        """
        if data is None:
            data = list("${{VAR_PROJECT_SLOGAN_STRING}}")

        super().__init__(data)

    def find(self, val):
        """Finds the index of the specified character within the
        set string of this IndexFinder instance.

        Args:
            val: The character to find the index for, as a str of length one.
                Must not be None

        Returns:
            The index of the specified character as an int or -1 if the
            set string of this IndexFinder instance does not contain
            the specified character.
            Never returns None.
        """
        self.ncalls += 1
        if val is None:
            raise TypeError("Invalid argument. Cannot compare with None")

        return self._compare_native_0(val)

    def _compare_native_0(self, val):
        """Implementation of find() method using native function calls.

        Args:
            val: The string character to find, as a str. Must not be None

        Returns:
            An int indicating the index of the found character. Or -1 if the
            set data object does not contain the specified character.
        """
        return internal_impl.find_index(self.data, val)

