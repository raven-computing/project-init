${{VAR_COPYRIGHT_HEADER}}
"""This module provides an abstract `Finder` class."""

from abc import ABC, abstractmethod


class Finder(ABC):
    """Dummy abstract base class.

    Attributes:
        data (any): The base value used by the `Finder`.
        ncalls (int): The number of calls to the `find()` method of
            the Finder instance.
    """

    def __init__(self, data):
        self.data = data
        self.ncalls: int = 0

    @abstractmethod
    def find(self, val):
        """Finds the specified object in the set data object of this Finder.

        Args:
            val (any): The object to find.

        Returns:
            any: The found result.
        """
