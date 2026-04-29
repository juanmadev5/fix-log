import '../models/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> fetchCustomers();
  Future<Customer> createCustomer(
    String name,
    String email,
    String phoneNumber,
  );
  Future<Customer> updateCustomer(Customer customer);
  Future<void> deleteCustomer(int id);
}
