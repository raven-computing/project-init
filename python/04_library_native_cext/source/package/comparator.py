${{VAR_COPYRIGHT_HEADER}}
"""Module providing a Comparator class."""

from abc import ABC, abstractmethod


class Comparator(ABC):
    """Dummy abstract base class.

    Attributes:
        val: The base value used by the Comparator, any type.
        ncalls: The number of calls to the compare() method of
            the Comparator instance, as an int.
    """

    def __init__(self, val):
        self.val = val
        self.ncalls = 0

    @abstractmethod
    def compare(self, val):
        """Compares the specified object to the set object of this Comparator.

        Args:
            val: The object with which to compare, as any type.

        Returns:
            An int indicating the result of the comparison.
            Returns 0 (zero) if both objects are equal.
            Returns a negative int value if the set object is less than
                the specified object.
            Returns a positive int value if the set object is greater
                than the specified object.
        """
        pass
