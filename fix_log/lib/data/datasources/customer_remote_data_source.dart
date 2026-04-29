import 'dart:convert';

import '../../core/api_client.dart';
import '../../core/api_constants.dart';
import '../../core/app_exception.dart';
import '../../domain/models/customer.dart';
import 'api_response.dart';

class CustomerRemoteDataSource {
  CustomerRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Customer>> fetchCustomers() async {
    try {
      final uri = Uri.parse('$fixLogApiBaseUrl$customersPath');
      final response = await _client.get(uri);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(body, (json) {
        final list = json as List<dynamic>;
        return list
            .map((item) => Customer.fromJson(item as Map<String, dynamic>))
            .toList();
      });
      return apiResponse.response;
    } on AppException catch (e) {
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<Customer> createCustomer(
    String name,
    String email,
    String phoneNumber,
  ) async {
    final uri = Uri.parse('$fixLogApiBaseUrl$customersPath');
    final response = await _client.post(uri, {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    });
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = ApiResponse.fromJson(
      body,
      (json) => Customer.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.response;
  }

  Future<Customer> updateCustomer(Customer customer) async {
    final uri = Uri.parse('$fixLogApiBaseUrl$customersPath');
    final response = await _client.put(uri, customer.toJson());
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = ApiResponse.fromJson(
      body,
      (json) => Customer.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.response;
  }

  Future<void> deleteCustomer(int id) async {
    final uri = Uri.parse('$fixLogApiBaseUrl$customersPath/$id');
    await _client.delete(uri);
  }
}
