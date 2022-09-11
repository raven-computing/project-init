${{VAR_COPYRIGHT_HEADER}}
"""Implementation of the Generator ABC using strings."""

from ${{VAR_NAMESPACE_DECLARATION}}.generator import Generator


class StringGenerator(Generator):
    """A dummy implementation of the Generator ABC."""

    def __init__(self):
        super().__init__("${{VAR_PROJECT_SLOGAN_STRING}}")

    def generate(self):
        """Generates a dummy String of this StringGenerator.

        Returns:
            A String object of this Generator
        """
        index = self.index
        self.index += 1
        return self.val + " " + str(index)
