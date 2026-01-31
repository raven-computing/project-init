${{VAR_COPYRIGHT_HEADER}}
"""Unit tests for the `IndexFinder` implementation."""

import unittest

from ${{VAR_NAMESPACE_DECLARATION}}.index_finder import IndexFinder


class TestIndexFinder(unittest.TestCase):
    """Tests the functionality of the IndexFinder class."""

    def setUp(self):
        self.dummy = IndexFinder("This is a test!")

    def test_find_with_default_attr(self):
        val = self.dummy.find("a")
        self.assertTrue(isinstance(val, int), "Return value should be an int")
        self.assertTrue(val == 8, "Return value should be 8")

    def test_find_with_custom_attr(self):
        finder = IndexFinder("ABCDEFG")
        val = finder.find("D")
        self.assertTrue(isinstance(val, int), "Return value should be an int")
        self.assertTrue(val == 3, "Return value should be 3")

    def test_find_with_custom_attr_no_match(self):
        finder = IndexFinder("ABCDEFG")
        val = finder.find("K")
        self.assertTrue(isinstance(val, int), "Return value should be an int")
        self.assertTrue(val == -1, "Return value should be -1 (no match)")

    def test_attr_ncalls(self):
        self.dummy.find("s")
        self.dummy.find("a")
        self.dummy.find("t")
        val = self.dummy.ncalls
        self.assertTrue(
            isinstance(val, int),
            "Attribute 'ncalls' should be an int"
        )
        self.assertTrue(val == 3, "Attribute 'ncalls' should be 6")


if __name__ == "__main__":
    unittest.main()
