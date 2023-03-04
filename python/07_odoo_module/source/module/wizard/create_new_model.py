${{VAR_COPYRIGHT_HEADER}}

from odoo import models, fields


class CreateNewModelWizard(models.TransientModel):
    """A New Wizard.

    Describe what this wizard does.
    """
    _name = "create.new.model.wizard"
    _description = "Wizard: Create New Model Records"

    field_a = fields.Char(
        string="New Chars",
    )

    field_b = fields.Integer(
        string="New Int",
    )

    field_c = fields.Float(
        string="New Float",
    )

    def action_create_new(self):
        self.ensure_one()
        self.env["rc.new.model"].create({
            "field_a": self.field_a,
            "field_b": self.field_b,
            "field_c": self.field_c,
        })
        return True

