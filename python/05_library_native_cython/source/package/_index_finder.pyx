${{VAR_COPYRIGHT_HEADER}}
"""Native implementation of index_finder functions."""


def find_index(data, val):
    """Finds the index of the specified character within the
    specified string data object.

    Args:
        data (str): The data object to search in. Must not be `None`.
        val (str): The character to find the index for, as a `str` of
            length one. Must not be `None`.

    Returns:
        int: The index of the specified character. Returns -1 if the
            set string of this `IndexFinder` instance does not contain
            the specified character. Never `None`.
    """
    # This is a kinda pointless example for Cython as we are
    # heavily relying on interpreter calls
    for i in range(len(data)):
        if data[i] == val:
            return i

    return -1

