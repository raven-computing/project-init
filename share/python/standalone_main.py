#!/usr/bin/env python

import sys


def main(argc: int, argv: list[str]) -> int:
    print("${{VAR_PROJECT_SLOGAN_STRING}}")
    return 0


if __name__ == "__main__":
    sys.exit(main(len(sys.argv), sys.argv))
