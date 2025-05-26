${{VAR_COPYRIGHT_HEADER}}
"""HTTP server main entry point."""

import sys
import platform

from datetime import datetime

import cherrypy

from ${{VAR_NAMESPACE_DECLARATION}}.controller import Controller


def main(argc: int, argv: list[str]) -> int:
    """Main function of the ${{VAR_PROJECT_NAME}} server application.

    Args:
        argc (int): The argument count.
        argv (list[str]): The list of program arguments.

    Returns:
        int: The exit code of the program.
    """
    # Global configuration
    cherrypy.config.update({
        "server.socket_host": "0.0.0.0",
        "server.socket_port": 8080
        })

    # Logger configuration
    logger = cherrypy._cplogging.LogManager
    logger.time = lambda self: datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
    logger.access_log_format = "{t} {h} {r} {s} {b} {f} {a}"


    # Application configuration
    config = {
        "/": {
            "tools.sessions.on": True
        }
    }

    cherrypy.log(f"Running on Python {platform.python_version()}")
    if argc > 1:
        cherrypy.log("Args: " + str(argv[1:]))

    cherrypy.quickstart(Controller(), "/", config)
    return 0


if __name__ == "__main__":
    sys.exit(main(len(sys.argv), sys.argv))
