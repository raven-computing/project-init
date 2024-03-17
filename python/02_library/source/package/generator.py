${{VAR_COPYRIGHT_HEADER}}
"""Module providing a Generator class."""

from abc import ABC, abstractmethod


class Generator(ABC):
    """Dummy abstract base class.

    Attributes:
        val (any): The base value used by the Generator.
        index (int): The index used by the Generator.
    """

    def __init__(self, val):
        self.val = val
        self.index = 0

    @abstractmethod
    def generate(self):
        """Generates an object of the Generator.

        Returns:
            any: An object of the Generator
        """
        pass
