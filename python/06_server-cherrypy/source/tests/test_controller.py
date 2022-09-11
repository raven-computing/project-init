${{VAR_COPYRIGHT_HEADER}}
"""Unit tests for the server controller."""

import unittest

from ${{VAR_NAMESPACE_DECLARATION}}.controller import Controller


class TestController(unittest.TestCase):
    """Tests the functionality of the example Controller class."""

    def setUp(self):
        self.ctrl = Controller()

    def test_endpoint_index(self):
        val = self.ctrl.index()
        self.assertTrue(val is not None, "Return value should not be None")
        self.assertTrue(val == "${{VAR_PROJECT_SLOGAN_STRING}}",
            "Return value does not match expected")

    def test_endpoint_data(self):
        expected = {
            "key1": "value1",
            "key2": "value2",
            "list1": [
                "item1",
                "item2",
                "item3"
            ]
        }
        val = self.ctrl.data()
        self.assertTrue(val is not None, "Return value should not be None")
        self.assertTrue(val == expected,
            "Return value does not match expected")


if __name__ == "__main__":
    unittest.main()
