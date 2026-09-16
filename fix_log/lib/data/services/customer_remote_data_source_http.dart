import 'dart:convert';

import '../../domain/models/customer.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import 'customer_remote_data_source.dart';

class CustomerRemoteDataSourceHttp implements CustomerRemoteDataSource {
  CustomerRemoteDataSourceHttp(this._client);

  final ApiClient _client;

  @override
  Future<List<Customer>> fetchCustomers() async {
    final uri = Uri.parse(
      '$fixLogApiBaseUrl$customersPath?page=1&pageSize=100',
    );
    final response = await _client.get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>;
    return items
        .map((item) => Customer.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
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
    return Customer.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<Customer> updateCustomer(Customer customer) async {
    final uri = Uri.parse('$fixLogApiBaseUrl$customersPath/${customer.id}');
    final response = await _client.put(uri, customer.toJson());
    return Customer.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteCustomer(int id) async {
    final uri = Uri.parse('$fixLogApiBaseUrl$customersPath/$id');
    await _client.delete(uri);
  }
}
