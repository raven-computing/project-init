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
        "account",
    ],
    "data": [
${{VAR_MANIFEST_SECURITY_DECL}}
${{VAR_MANIFEST_VIEWS_DECL}}
${{VAR_MANIFEST_WIZARD_DECL}}
    ],
    "assets": {
       "web.assets_backend": [],
        "web.assets_frontend": [],
    },
    "auto_install": False,
    "installable": True,
}

