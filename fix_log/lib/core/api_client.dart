import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_exception.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _token;

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

    return headers;
  }

  Future<http.Response> get(Uri uri) async {
    final response = await _client.get(uri, headers: _headers());
    _validateResponse(response);
    return response;
  }

  Future<http.Response> post(Uri uri, Object body) async {
    final response = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode(body),
    );
    _validateResponse(response);
    return response;
  }

  Future<http.Response> put(Uri uri, Object body) async {
    final response = await _client.put(
      uri,
      headers: _headers(),
      body: jsonEncode(body),
    );
    _validateResponse(response);
    return response;
  }

  Future<http.Response> delete(Uri uri) async {
    final response = await _client.delete(uri, headers: _headers());
    _validateResponse(response);
    return response;
  }

  void _validateResponse(http.Response response) {
    if (response.statusCode < 400) return;

    var message = 'Error del servidor (${response.statusCode})';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final apiMessage = body['message'];
      if (apiMessage is String && apiMessage.isNotEmpty) {
        message = apiMessage;
      }
    } catch (_) {}

    throw AppException(message, statusCode: response.statusCode);
  }
}
