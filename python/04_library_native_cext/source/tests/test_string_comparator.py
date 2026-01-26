${{VAR_COPYRIGHT_HEADER}}
"""Unit tests for the `StringComparator` implementation."""

import unittest

from ${{VAR_NAMESPACE_DECLARATION}}.string_comparator import StringComparator


class TestStringComparator(unittest.TestCase):
    """Tests the functionality of the `StringComparator` class."""

    def setUp(self):
        self.dummy = StringComparator("TEST")

    def test_return_value(self):
        val = self.dummy.compare("TEST")
        self.assertTrue(val is not None, "Return value should not be None")
        self.assertTrue(isinstance(val, int), "Return value should be an int")

    def test_compare_equal(self):
        val = self.dummy.compare("TEST")
        self.assertTrue(val is not None, "Return value should not be None")
        self.assertTrue(isinstance(val, int), "Return value should be an int")
        self.assertTrue(val == 0, "Return value should be 0")

    def test_compare_arg_is_greater(self):
        dummy = StringComparator("A")
        val = dummy.compare("B")
        self.assertTrue(val is not None, "Return value should not be None")
        self.assertTrue(isinstance(val, int), "Return value should be an int")
        self.assertTrue(val < 0, "Return value should be a negative int")

    def test_compare_arg_is_smaller(self):
        dummy = StringComparator("B")
        val = dummy.compare("A")
        self.assertTrue(val is not None, "Return value should not be None")
        self.assertTrue(isinstance(val, int), "Return value should be an int")
        self.assertTrue(val > 0, "Return value should be a positive int")

    def test_compare_ncalls(self):
        self.dummy.compare("TEST")
        self.dummy.compare("TEST-A")
        self.dummy.compare("TEST-B")
        ncalls = self.dummy.ncalls
        self.assertTrue(
            ncalls is not None,
            "Attribute ncalls should not be None")

        self.assertTrue(
            isinstance(ncalls, int),
            "Attribute ncalls should be an int")

        self.assertTrue(
            ncalls == 3,
            "Attribute ncalls should equal 3 after 3 method invocations")


if __name__ == "__main__":
    unittest.main()
