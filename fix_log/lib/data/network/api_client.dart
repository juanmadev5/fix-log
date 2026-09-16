import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/logger.dart';
import '../../domain/exceptions/app_exception.dart';

const _correlationIdHeader = 'X-Correlation-Id';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _token;
  String? _correlationId;
  void Function()? onUnauthorized;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> _headers() {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    if (_correlationId != null) {
      headers[_correlationIdHeader] = _correlationId!;
    }

    return headers;
  }

  Future<http.Response> get(Uri uri) {
    return _send(() => _client.get(uri, headers: _headers()));
  }

  Future<http.Response> post(Uri uri, Object body) {
    return _send(
      () => _client.post(uri, headers: _headers(), body: jsonEncode(body)),
    );
  }

  Future<http.Response> put(Uri uri, Object body) {
    return _send(
      () => _client.put(uri, headers: _headers(), body: jsonEncode(body)),
    );
  }

  Future<http.Response> delete(Uri uri) {
    return _send(() => _client.delete(uri, headers: _headers()));
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request();
    } on SocketException catch (error) {
      appLogger.w('Network request failed: no connection ($error)');
      throw const AppException('No network connection', code: 'NETWORK_ERROR');
    } on HttpException catch (error) {
      appLogger.w('Network request failed: $error');
      throw const AppException('No network connection', code: 'NETWORK_ERROR');
    }

    _validateResponse(response);
    return response;
  }

  void _validateResponse(http.Response response) {
    final correlationId = response.headers[_correlationIdHeader.toLowerCase()];
    if (correlationId != null) _correlationId = correlationId;

    if (response.statusCode < 400) return;

    if (response.statusCode == 401) {
      onUnauthorized?.call();
    }

    var message = 'Server error (${response.statusCode})';
    String? code;
    var fieldErrors = const <FieldError>[];
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final detail = body['detail'];
      if (detail is String && detail.isNotEmpty) message = detail;
      code = body['code'] as String?;
      final rawErrors = body['errors'];
      if (rawErrors is List) {
        fieldErrors = rawErrors
            .map((item) => FieldError.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    appLogger.w(
      'API request failed: ${response.request?.method} ${response.request?.url} '
      '-> ${response.statusCode} $code (correlationId: $_correlationId)',
    );

    throw AppException(
      message,
      statusCode: response.statusCode,
      code: code,
      fieldErrors: fieldErrors,
    );
  }
}
