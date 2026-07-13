import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OdooSession {
  const OdooSession({
    required this.serverUrl,
    required this.db,
    required this.username,
    required this.apiKey,
  });

  final String serverUrl;
  final String db;
  final String username;
  final String apiKey;
}

/// Persists the connection settings. The API key lives only in the platform
/// keystore (flutter_secure_storage) — no password is ever stored or sent.
class SessionRepository {
  SessionRepository([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kUrl = 'odoo_server_url';
  static const _kDb = 'odoo_db';
  static const _kUser = 'odoo_username';
  static const _kApiKey = 'odoo_api_key';

  Future<OdooSession?> load() async {
    final values = await Future.wait(
      [_kUrl, _kDb, _kUser, _kApiKey].map((k) => _storage.read(key: k)),
    );
    if (values.any((v) => v == null || v.isEmpty)) return null;
    return OdooSession(
      serverUrl: values[0]!,
      db: values[1]!,
      username: values[2]!,
      apiKey: values[3]!,
    );
  }

  Future<void> save(OdooSession session) async {
    await Future.wait([
      _storage.write(key: _kUrl, value: session.serverUrl),
      _storage.write(key: _kDb, value: session.db),
      _storage.write(key: _kUser, value: session.username),
      _storage.write(key: _kApiKey, value: session.apiKey),
    ]);
  }

  Future<void> clear() => _storage.deleteAll();
}
