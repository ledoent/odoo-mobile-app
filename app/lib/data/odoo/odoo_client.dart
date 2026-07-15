import 'package:dio/dio.dart';

/// Raised when the Odoo server returns a JSON-RPC error payload.
class OdooRpcException implements Exception {
  OdooRpcException(this.message, {this.data});

  final String message;
  final Map<String, dynamic>? data;

  @override
  String toString() => 'OdooRpcException: $message';
}

/// Raised when authentication fails (bad db/login/API key).
class OdooAuthException extends OdooRpcException {
  OdooAuthException(super.message, {super.data});
}

/// Minimal JSON-RPC client for Odoo (14+).
///
/// Authenticates with an API key (Preferences → Account Security → API Keys)
/// used as the RPC password — a real password never has to leave the device.
class OdooClient {
  OdooClient({
    required this.baseUrl,
    required this.db,
    required this.username,
    required this.apiKey,
    Dio? dio,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 30),
             ),
           );

  final String baseUrl;
  final String db;
  final String username;
  final String apiKey;
  final Dio _dio;

  int? _uid;
  int _rpcId = 0;

  int? get uid => _uid;

  Future<dynamic> _jsonRpc(
    String service,
    String method,
    List<dynamic> args,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/jsonrpc',
      data: {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {'service': service, 'method': method, 'args': args},
        'id': ++_rpcId,
      },
      options: Options(contentType: Headers.jsonContentType),
    );
    final body = response.data;
    if (body == null) {
      throw OdooRpcException('Empty response from $baseUrl');
    }
    if (body['error'] != null) {
      final error = body['error'] as Map<String, dynamic>;
      final data = error['data'] as Map<String, dynamic>?;
      final message =
          (data?['message'] ?? error['message'] ?? 'Unknown Odoo error')
              .toString();
      // A revoked/expired key on a cached uid comes back as a generic
      // AccessDenied RPC error, not a login failure — classify it as an
      // auth problem so the sync engine stops instead of mass-conflicting.
      final errorName = (data?['name'] ?? '').toString();
      if (errorName.endsWith('AccessDenied') ||
          message.contains('Access Denied')) {
        throw OdooAuthException(message, data: data);
      }
      throw OdooRpcException(message, data: data);
    }
    return body['result'];
  }

  /// Logs in with the API key; caches and returns the uid.
  Future<int> authenticate() async {
    final result = await _jsonRpc('common', 'login', [db, username, apiKey]);
    if (result is! int || result == 0) {
      throw OdooAuthException('Authentication failed for $username on $db');
    }
    _uid = result;
    return result;
  }

  /// `execute_kw` against any model, authenticating first if needed.
  Future<dynamic> executeKw(
    String model,
    String method,
    List<dynamic> args, [
    Map<String, dynamic>? kwargs,
  ]) async {
    final uid = _uid ?? await authenticate();
    return _jsonRpc('object', 'execute_kw', [
      db,
      uid,
      apiKey,
      model,
      method,
      args,
      kwargs ?? <String, dynamic>{},
    ]);
  }

  Future<List<Map<String, dynamic>>> searchRead(
    String model,
    List<dynamic> domain,
    List<String> fields, {
    int? limit,
    String? order,
  }) async {
    final result = await executeKw(
      model,
      'search_read',
      [domain],
      {'fields': fields, 'limit': ?limit, 'order': ?order},
    );
    return (result as List).cast<Map<String, dynamic>>();
  }
}
