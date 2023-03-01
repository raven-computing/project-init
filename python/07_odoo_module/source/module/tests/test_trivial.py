${{VAR_COPYRIGHT_HEADER}}
"""Unit tests."""

import unittest


class TestSomething(unittest.TestCase):
    """Tests something."""

    def setUp(self):
        self.dummy = True

    def test_trivial(self):
        val = self.dummy
        self.assertTrue(val is not False, "Trivial test")


if __name__ == "__main__":
    unittest.main()

