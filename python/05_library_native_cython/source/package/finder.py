${{VAR_COPYRIGHT_HEADER}}
"""This module provides an abstract Finder class."""

from abc import ABC, abstractmethod


class Finder(ABC):
    """Dummy abstract base class.

    Attributes:
        data: The base value used by the Finder, any type.
        ncalls: The number of calls to the find() method of
            the Finder instance, as an int.
    """

    def __init__(self, data):
        self.data = data
        self.ncalls = 0

    @abstractmethod
    def find(self, val):
        """Finds the specified object in the set data object of this Finder.

        Args:
            val: The object to find, as any type.

        Returns:
            The found result, as any type.
        """
        pass
