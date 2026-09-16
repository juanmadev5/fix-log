import '../../domain/models/auth_response.dart';
import '../network/api_client.dart';
import '../services/auth_remote_data_source.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource, this._apiClient);

  final AuthRemoteDataSource _dataSource;
  final ApiClient _apiClient;

  @override
  Future<AuthResponse> login(String email, String password) async {
    final response = await _dataSource.login(email, password);
    _apiClient.setToken(response.token);
    return response;
  }

  @override
  Future<AuthResponse> register(String email, String password) async {
    final response = await _dataSource.register(email, password);
    _apiClient.setToken(response.token);
    return response;
  }

  @override
  void logout() {
    _apiClient.clearToken();
  }
}
