${{VAR_COPYRIGHT_HEADER}}

from odoo.http import Controller, route


class NewController(Controller):
    """Controller class."""

    @route("/hello/<name>",
           methods=["GET"],
           type="http",
           auth="public",
    )
    def hello(self, name):
        """The hello endpoint.

        Args:
            name: The name to greet, as a str.

        Returns:
            A greeting, as a plain text str.
        """
        return f"Hello {name}, it's nice to meet you!"

