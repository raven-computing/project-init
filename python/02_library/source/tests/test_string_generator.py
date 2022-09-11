${{VAR_COPYRIGHT_HEADER}}
"""Unit tests for the StringGenerator implementation."""

import unittest

from ${{VAR_NAMESPACE_DECLARATION}}.string_generator import StringGenerator


class TestStringGenerator(unittest.TestCase):
    """Tests the functionality of the StringGenerator class."""

    def setUp(self):
        self.dummy = StringGenerator()

    def test_string_is_not_empty(self):
        val = self.dummy.generate()
        self.assertTrue(val is not None, "Value should not be None")
        self.assertTrue(val, "Value should not be empty")

    def test_string_values_are_different(self):
        val1 = self.dummy.generate()
        val2 = self.dummy.generate()
        self.assertTrue(val1 is not None, "Value 1 should not be None")
        self.assertTrue(val2 is not None, "Value 2 should not be None")
        self.assertTrue(val1, "Value 1 should not be empty")
        self.assertTrue(val2, "Value 2 should not be empty")
        self.assertTrue(val1 != val2, "Values should not be equal")

    def test_same_string_generation(self):
        val1 = self.dummy.generate()
        generator = StringGenerator()
        val2 = generator.generate()
        self.assertTrue(val1 is not None, "Value 1 should not be None")
        self.assertTrue(val2 is not None, "Value 2 should not be None")
        self.assertTrue(val1, "Value 1 should not be empty")
        self.assertTrue(val2, "Value 2 should not be empty")
        self.assertTrue(val1 == val2, "Values should be equal")


if __name__ == "__main__":
    unittest.main()
