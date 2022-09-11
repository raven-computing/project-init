${{VAR_COPYRIGHT_HEADER}}
"""Unit tests for the installable script implementation."""

import unittest

from ${{VAR_NAMESPACE_DECLARATION}}.application import main


class TestScript(unittest.TestCase):
    """Tests the functionality of the script main function."""

    def setUp(self):
        pass

    def test_trivial(self):
        self.assertTrue(True is not False, "This is a trivial test")

    def test_main_is_callable(self):
        self.assertTrue(callable(main), "The main() function should be callable")


if __name__ == "__main__":
    unittest.main()
