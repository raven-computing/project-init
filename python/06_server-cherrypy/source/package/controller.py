${{VAR_COPYRIGHT_HEADER}}
"""HTTP server controller."""

import cherrypy


class Controller:
    """Controller class for HTTP example endpoints."""

    @cherrypy.expose
    def index(self):
        """Path '/'

        Returns:
            An example string.
        """
        return "${{VAR_PROJECT_SLOGAN_STRING}}"

    @cherrypy.expose
    @cherrypy.tools.json_out()
    def data(self):
        """Path '/data'

        Returns:
            An example JSON-encoded data string.
        """
        data = {
            "key1": "value1",
            "key2": "value2",
            "list1": [
                "item1",
                "item2",
                "item3"
            ]
        }
        return data
