import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error_handler.dart';
import '../../../domain/exceptions/app_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final response = await _repository.login(email, password);
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          token: response.token,
          email: response.email,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: friendlyError(error),
        ),
      );
    }
  }

  Future<void> register(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final response = await _repository.register(email, password);
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          token: response.token,
          email: response.email,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: friendlyError(error),
        ),
      );
    }
  }

  void logout() {
    _repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
