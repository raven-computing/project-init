${{VAR_COPYRIGHT_HEADER}}

{
    "name": "${{VAR_ODOO_MODULE_NAME}}",
    "summary": "${{VAR_PROJECT_DESCRIPTION}}",
    "version": "0.0.1",
    "author": "${{VAR_PROJECT_ORGANISATION_NAME}}",
    "website": "${{VAR_PROJECT_ORGANISATION_URL}}",
    "category": "Unknown",
    "license": "GPL-2",
    "depends": [
        "base",
    ],
    "data": [
        "security/ir.model.access.csv",
        "security/my_module_groups.xml",
        "security/new_model_security.xml",
        "views/new_model_menus.xml",
        "views/new_model_views.xml",
        "views/report_invoice.xml",
        "wizard/create_new_model_views.xml",
    ],
    "assets": {
       "web.assets_backend": [
            "${{VAR_ODOO_MODULE_NAME}}/static/src/js/**/*",
            "${{VAR_ODOO_MODULE_NAME}}/static/src/xml/**/*",
        ],
        "web.assets_frontend": [],
    },
    "auto_install": False,
    "installable": True,
}

