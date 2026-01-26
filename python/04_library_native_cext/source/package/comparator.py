${{VAR_COPYRIGHT_HEADER}}
"""Module providing a `Comparator` class."""

from abc import ABC, abstractmethod
from typing import Any


class Comparator(ABC):
    """Dummy abstract base class.

    Attributes:
        val (Any): The base value used by the Comparator.
        ncalls (int): The number of calls to the compare() method of
            the Comparator instance.
    """

    def __init__(self, val: Any):
        self.val = val
        self.ncalls: int = 0

    @abstractmethod
    def compare(self, val: Any) -> int:
        """Compares the specified object to the set object of this Comparator.

        Args:
            val (Any): The object with which to compare.

        Returns:
            int: An int indicating the result of the comparison.
                0 (zero) if both objects are equal.
                A negative int value if the set object is less than
                the specified object.
                A positive int value if the set object is greater
                than the specified object.
        Raises:
            ValueError: If either the internal or specified value is invalid
                or cannot be used.
        """
