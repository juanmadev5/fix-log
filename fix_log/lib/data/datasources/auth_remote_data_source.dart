import 'dart:convert';

import '../../core/api_client.dart';
import '../../core/api_constants.dart';
import '../../domain/models/auth_response.dart';
import 'api_response.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<AuthResponse> login(String email, String password) async {
    final uri = Uri.parse('$fixLogApiBaseUrl$authLoginPath');
    final response = await _client.post(uri, {
      'email': email,
      'password': password,
    });

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = ApiResponse.fromJson(
      body,
      (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.response;
  }

  Future<AuthResponse> register(String email, String password) async {
    final uri = Uri.parse('$fixLogApiBaseUrl$authRegisterPath');
    final response = await _client.post(uri, {
      'email': email,
      'password': password,
    });

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = ApiResponse.fromJson(
      body,
      (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.response;
  }
}
