import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/error_handler.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../domain/models/auth_response.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required ApiClient apiClient}) {
    _apiClient = apiClient;
    _repository = AuthRepositoryImpl(AuthRemoteDataSource(_apiClient));
  }

  late final ApiClient _apiClient;
  late final AuthRepository _repository;

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _token;
  String? _email;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get email => _email;
  String? get errorMessage => _errorMessage;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final AuthResponse response = await _repository.login(email, password);
      _setAuthenticated(response.token, response.email);
    } catch (error) {
      _errorMessage = friendlyError(error);
    }
    _setLoading(false);
  }

  Future<void> register(String email, String password) async {
    _setLoading(true);
    try {
      final AuthResponse response = await _repository.register(email, password);
      _setAuthenticated(response.token, response.email);
    } catch (error) {
      _errorMessage = friendlyError(error);
    }
    _setLoading(false);
  }

  void logout() {
    _isAuthenticated = false;
    _token = null;
    _email = null;
    _apiClient.clearToken();
    notifyListeners();
  }

  void _setAuthenticated(String token, String email) {
    _token = token;
    _email = email;
    _isAuthenticated = true;
    _apiClient.setToken(token);
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
