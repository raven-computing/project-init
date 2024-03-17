${{VAR_COPYRIGHT_HEADER}}
"""Installable script main entry point."""

import sys


def main():
    """Main function of the ${{VAR_PROJECT_NAME}} application.

    Returns:
        int: The exit code of the program.
    """
    print("${{VAR_PROJECT_SLOGAN_STRING}}")
    if len(sys.argv) > 1:
        print("Args: " + str(sys.argv[1:]))

    return 0


if __name__ == "__main__":
    sys.exit(main())
