/// Helpers for Odoo's JSON quirks, shared by all module DTOs.
library;

/// Display name from a many2one value (`[id, "name"]`, `false`, or an id).
String relName(dynamic value) =>
    value is List && value.length > 1 ? value[1] as String : '';

/// Id from a many2one value, or null when unset (`false`).
int? relId(dynamic value) =>
    value is List ? value[0] as int : (value is int ? value : null);

/// String field that Odoo returns as `false` when empty.
String odooString(dynamic value) => value is String ? value : '';
