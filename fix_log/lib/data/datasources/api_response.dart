class ApiResponse<T> {
  final T response;
  final String message;
  final String status;

  ApiResponse({
    required this.response,
    required this.message,
    required this.status,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) parseResponse,
  ) {
    return ApiResponse(
      response: parseResponse(json['response']),
      message: json['message'] as String,
      status: json['status'] as String,
    );
  }
}
