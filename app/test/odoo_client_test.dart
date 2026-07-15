import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odoo_scanner/data/odoo/odoo_client.dart';

/// Canned-response adapter: each queued handler answers one /jsonrpc POST.
class _FakeAdapter implements HttpClientAdapter {
  final List<Map<String, dynamic> Function(Map<String, dynamic> request)>
  handlers = [];
  final List<Map<String, dynamic>> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final raw = options.data;
    final request = raw is String
        ? jsonDecode(raw) as Map<String, dynamic>
        : (raw as Map).cast<String, dynamic>();
    requests.add(request);
    final handler = handlers.removeAt(0);
    return ResponseBody.fromString(
      jsonEncode(handler(request)),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _FakeAdapter adapter;
  late OdooClient client;

  setUp(() {
    adapter = _FakeAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://odoo.test'));
    dio.httpClientAdapter = adapter;
    client = OdooClient(
      baseUrl: 'https://odoo.test',
      db: 'testdb',
      username: 'scanner@test',
      apiKey: 'the-api-key',
      dio: dio,
    );
  });

  Map<String, dynamic> ok(dynamic result) => {
    'jsonrpc': '2.0',
    'result': result,
  };

  test('authenticate logs in with the API key as password', () async {
    adapter.handlers.add((req) {
      expect(req['params']['service'], 'common');
      expect(req['params']['method'], 'login');
      expect(req['params']['args'], ['testdb', 'scanner@test', 'the-api-key']);
      return ok(7);
    });

    final uid = await client.authenticate();
    expect(uid, 7);
    expect(client.uid, 7);
  });

  test('authenticate throws OdooAuthException on falsy uid', () async {
    adapter.handlers.add((_) => ok(false));
    expect(client.authenticate(), throwsA(isA<OdooAuthException>()));
  });

  test('executeKw authenticates lazily and passes kwargs', () async {
    adapter.handlers.add((_) => ok(7));
    adapter.handlers.add((req) {
      final args = req['params']['args'] as List;
      expect(args.sublist(0, 3), ['testdb', 7, 'the-api-key']);
      expect(args[3], 'stock.picking');
      expect(args[4], 'search_read');
      expect(args[6], {'limit': 5});
      return ok([
        {'id': 1, 'name': 'WH/IN/00001'},
      ]);
    });

    final result = await client.executeKw(
      'stock.picking',
      'search_read',
      [
        [
          ['state', '=', 'assigned'],
        ],
      ],
      {'limit': 5},
    );
    expect(result, hasLength(1));
  });

  test('server error payload becomes OdooRpcException with message', () async {
    adapter.handlers.add((_) => ok(7));
    adapter.handlers.add(
      (_) => {
        'jsonrpc': '2.0',
        'error': {
          'message': 'Odoo Server Error',
          'data': {'message': 'Record does not exist or has been deleted.'},
        },
      },
    );

    expect(
      client.executeKw('stock.move.line', 'write', []),
      throwsA(
        isA<OdooRpcException>().having(
          (e) => e.message,
          'message',
          contains('does not exist'),
        ),
      ),
    );
  });

  test('AccessDenied on a cached uid maps to OdooAuthException', () async {
    adapter.handlers.add((_) => ok(7));
    adapter.handlers.add(
      (_) => {
        'jsonrpc': '2.0',
        'error': {
          'message': 'Odoo Server Error',
          'data': {
            'name': 'odoo.exceptions.AccessDenied',
            'message': 'Access Denied',
          },
        },
      },
    );

    expect(
      client.executeKw('stock.move.line', 'write', []),
      throwsA(isA<OdooAuthException>()),
    );
  });
}
