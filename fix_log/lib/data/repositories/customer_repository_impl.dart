import '../../domain/models/customer.dart';
import '../services/customer_remote_data_source.dart';
import 'customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._dataSource);

  final CustomerRemoteDataSource _dataSource;

  @override
  Future<Customer> createCustomer(
    String name,
    String email,
    String phoneNumber,
  ) {
    return _dataSource.createCustomer(name, email, phoneNumber);
  }

  @override
  Future<void> deleteCustomer(int id) {
    return _dataSource.deleteCustomer(id);
  }

  @override
  Future<List<Customer>> fetchCustomers() {
    return _dataSource.fetchCustomers();
  }

  @override
  Future<Customer> updateCustomer(Customer customer) {
    return _dataSource.updateCustomer(customer);
  }
}
