import 'dart:io';

// Override at build time: flutter run --dart-define=API_BASE_URL=http://192.168.x.x:5167/api
const _definedBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

String get fixLogApiBaseUrl {
  if (_definedBaseUrl.isNotEmpty) return _definedBaseUrl;
  // Android emulator routes localhost traffic through 10.0.2.2
  return Platform.isAndroid
      ? 'http://10.0.2.2:5167/api'
      : 'http://localhost:5167/api';
}

const String authLoginPath = '/auth/login';
const String authRegisterPath = '/auth/register';
const String customersPath = '/customer';
const String expensesPath = '/expense';
const String reportsPath = '/report';
