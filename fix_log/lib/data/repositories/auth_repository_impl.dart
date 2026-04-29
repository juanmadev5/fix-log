import '../../domain/models/auth_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final AuthRemoteDataSource _dataSource;

  @override
  Future<AuthResponse> login(String email, String password) {
    return _dataSource.login(email, password);
  }

  @override
  Future<AuthResponse> register(String email, String password) {
    return _dataSource.register(email, password);
  }
}
