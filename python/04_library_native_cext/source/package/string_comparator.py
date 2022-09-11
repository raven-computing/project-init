${{VAR_COPYRIGHT_HEADER}}
"""Implementation of the Comparator ABC using strings."""

try:
    import ${{VAR_NAMESPACE_DECLARATION}}._string_comparator as internal_impl
except ModuleNotFoundError:
    raise ImportError("C extension module must be compiled") from None

from ${{VAR_NAMESPACE_DECLARATION}}.comparator import Comparator


class StringComparator(Comparator):
    """An implementation of the Comparator ABC using strings.

    This implementation only supports comparing strings containing
    ASCII characters.
    This class uses the native strcmp() C function for string comparisons.
    """

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
        return internal_impl.compare(str(self.val), str(val))
