import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fix_log/data/repositories/auth_repository.dart';
import 'package:fix_log/domain/exceptions/app_exception.dart';
import 'package:fix_log/domain/models/auth_response.dart';
import 'package:fix_log/ui/auth/view_models/auth_cubit.dart';
import 'package:fix_log/ui/auth/view_models/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  group('given valid credentials', () {
    blocTest<AuthCubit, AuthState>(
      'when logging in, then emits loading and then authenticated with the token',
      build: () {
        when(() => repository.login('user@test.com', 'password123')).thenAnswer(
          (_) async => AuthResponse(token: 'token123', email: 'user@test.com'),
        );
        return AuthCubit(repository);
      },
      act: (cubit) => cubit.login('user@test.com', 'password123'),
      expect: () => [
        isA<AuthState>().having(
          (state) => state.status,
          'status',
          AuthStatus.loading,
        ),
        isA<AuthState>()
            .having((state) => state.status, 'status', AuthStatus.authenticated)
            .having((state) => state.token, 'token', 'token123')
            .having((state) => state.email, 'email', 'user@test.com'),
      ],
    );
  });

  group('given invalid credentials', () {
    blocTest<AuthCubit, AuthState>(
      'when logging in, then emits loading and then failure with a friendly message',
      build: () {
        when(() => repository.login('user@test.com', 'wrong')).thenThrow(
          const AppException(
            'Invalid credentials',
            statusCode: 401,
            code: 'INVALID_CREDENTIALS',
          ),
        );
        return AuthCubit(repository);
      },
      act: (cubit) => cubit.login('user@test.com', 'wrong'),
      expect: () => [
        isA<AuthState>().having(
          (state) => state.status,
          'status',
          AuthStatus.loading,
        ),
        isA<AuthState>()
            .having((state) => state.status, 'status', AuthStatus.failure)
            .having((state) => state.errorMessage, 'errorMessage', isNotNull),
      ],
    );
  });

  group('given an authenticated session', () {
    blocTest<AuthCubit, AuthState>(
      'when logging out, then clears the session and emits unauthenticated',
      setUp: () => when(() => repository.logout()).thenReturn(null),
      build: () => AuthCubit(repository),
      act: (cubit) => cubit.logout(),
      expect: () => [
        isA<AuthState>().having(
          (state) => state.status,
          'status',
          AuthStatus.unauthenticated,
        ),
      ],
      verify: (_) => verify(() => repository.logout()).called(1),
    );
  });
}
