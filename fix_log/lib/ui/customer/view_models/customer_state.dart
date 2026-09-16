import '../../../domain/models/customer.dart';

enum CustomerStatus { initial, loading, success, failure }

class CustomerState {
  const CustomerState({
    this.status = CustomerStatus.initial,
    this.customers = const [],
    this.errorMessage,
  });

  final CustomerStatus status;
  final List<Customer> customers;
  final String? errorMessage;

  bool get isLoading => status == CustomerStatus.loading;

  CustomerState copyWith({
    CustomerStatus? status,
    List<Customer>? customers,
    String? errorMessage,
  }) {
    return CustomerState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      errorMessage: errorMessage,
    );
  }
}
