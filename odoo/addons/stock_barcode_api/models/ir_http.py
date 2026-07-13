# Copyright 2026 Ledo (https://ledoweb.com)
# License AGPL-3.0 or later (https://www.gnu.org/licenses/agpl).
import werkzeug.exceptions

from odoo import models
from odoo.http import request


class IrHttp(models.AbstractModel):
    _inherit = "ir.http"

    @classmethod
    def _auth_method_api_key(cls):
        """Authenticate from an ``Authorization: Bearer <api key>`` header.

        Keys are the standard Odoo API keys (Preferences → Account Security),
        so no password ever transits and keys can be revoked per device.
        """
        auth_header = request.httprequest.headers.get("Authorization", "")
        if not auth_header.startswith("Bearer "):
            raise werkzeug.exceptions.Unauthorized(
                "Missing 'Authorization: Bearer <api key>' header"
            )
        key = auth_header[len("Bearer ") :].strip()
        uid = request.env["res.users.apikeys"]._check_credentials(scope="rpc", key=key)
        if not uid:
            raise werkzeug.exceptions.Unauthorized("Invalid API key")
        request.update_env(user=uid)
