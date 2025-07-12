${{VAR_COPYRIGHT_HEADER}}
"""Module providing a Generator class."""

from abc import ABC, abstractmethod


class Generator(ABC):
    """Dummy abstract base class.

    Attributes:
        basis (str): The base value used by the Generator.
        index (int): The index used by the Generator.
    """

    def __init__(self, basis: str):
        self.basis: str = basis
        self.index: int = 0

    @abstractmethod
    def generate(self) -> str:
        """Generates a dummy string of this Generator.

        Returns:
            str: A dummy string of the Generator
        """
