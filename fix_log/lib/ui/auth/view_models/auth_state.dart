enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.token,
    this.email,
    this.errorMessage,
  });

  final AuthStatus status;
  final String? token;
  final String? email;
  final String? errorMessage;

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    String? token,
    String? email,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      email: email ?? this.email,
      errorMessage: errorMessage,
    );
  }
}
