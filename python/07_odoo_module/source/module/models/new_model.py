${{VAR_COPYRIGHT_HEADER}}

from odoo import models, fields


class NewModel(models.Model):
    """A New Model.

    A description of what the purpose of this model is.
    """
    _name = "rc.new.model"
    _description = "A New Model"

    field_a = fields.Char(
        string="Some Field",
        help="A very helpful description.",
    )

    field_b = fields.Integer(
        string="Other Field",
        help="Also very helpful description.",
    )

    field_c = fields.Float(
        string="Other Value",
        help="Some other value.",
    )

