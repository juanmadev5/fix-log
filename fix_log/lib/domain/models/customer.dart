import 'report.dart';

class Customer {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final List<Report> reports;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.reports = const [],
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    final reportsJson = json['reports'] as List<dynamic>?;

    return Customer(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      reports: reportsJson != null
          ? reportsJson
                .map((item) => Report.fromJson(item as Map<String, dynamic>))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'phoneNumber': phoneNumber};
  }
}
