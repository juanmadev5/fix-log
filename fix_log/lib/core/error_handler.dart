import '../domain/exceptions/app_exception.dart';
import '../ui/core/strings.dart';

const _messagesByCode = {
  'NETWORK_ERROR': AppStrings.noConnection,
  'EMAIL_ALREADY_REGISTERED': AppStrings.emailAlreadyRegistered,
  'INVALID_CREDENTIALS': AppStrings.invalidCredentials,
  'VALIDATION_FAILED': AppStrings.validationFailed,
  'CUSTOMER_NOT_FOUND': AppStrings.customerNotFound,
  'EXPENSE_NOT_FOUND': AppStrings.expenseNotFound,
  'REPORT_NOT_FOUND': AppStrings.reportNotFound,
};

/// Converts an [AppException] into a user-friendly Spanish message.
///
/// The data layer (see `data/network/api_client.dart`) is the only place
/// that maps raw platform/HTTP exceptions into [AppException] — by the time
/// an error reaches here, it is always a typed [AppException].
String friendlyError(AppException error) {
  final messageForCode = _messagesByCode[error.code];
  if (messageForCode != null) return messageForCode;

  final statusCode = error.statusCode;
  if (statusCode != null && statusCode >= 500) {
    return AppStrings.serverErrorFallback;
  }
  return switch (statusCode) {
    401 => AppStrings.sessionExpired,
    403 => AppStrings.forbiddenAction,
    _ => error.message.isNotEmpty ? error.message : AppStrings.unexpectedError,
  };
}
