import 'dart:convert';

import '../../domain/models/auth_response.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceHttp implements AuthRemoteDataSource {
  AuthRemoteDataSourceHttp(this._client);

  final ApiClient _client;

  @override
  Future<AuthResponse> login(String email, String password) async {
    final uri = Uri.parse('$fixLogApiBaseUrl$authLoginPath');
    final response = await _client.post(uri, {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  @override
  Future<AuthResponse> register(String email, String password) async {
    final uri = Uri.parse('$fixLogApiBaseUrl$authRegisterPath');
    final response = await _client.post(uri, {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
