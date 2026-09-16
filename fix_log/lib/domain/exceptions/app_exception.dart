class FieldError {
  const FieldError({required this.field, required this.message});

  final String field;
  final String message;

  factory FieldError.fromJson(Map<String, dynamic> json) {
    return FieldError(
      field: json['field'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}

class AppException implements Exception {
  const AppException(
    this.message, {
    this.statusCode,
    this.code,
    this.fieldErrors = const [],
  });

  final String message;
  final int? statusCode;
  final String? code;
  final List<FieldError> fieldErrors;

  @override
  String toString() => message;
}
