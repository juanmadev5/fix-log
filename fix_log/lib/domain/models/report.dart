class Report {
  final int id;
  final int customerId;
  final DateTime date;
  final String details;
  final bool isCompleted;
  final bool isPaid;
  final double cost;

  Report({
    required this.id,
    required this.customerId,
    required this.date,
    required this.details,
    required this.isCompleted,
    required this.isPaid,
    this.cost = 0,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as int,
      customerId: json['customer_id'] as int,
      date: DateTime.parse(json['date'] as String),
      details: json['details'] as String,
      isCompleted: json['is_completed'] as bool,
      isPaid: json['is_paid'] as bool,
      cost: (json['cost'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'date': date.toIso8601String(),
      'details': details,
      'is_completed': isCompleted,
      'is_paid': isPaid,
      'cost': cost,
    };
  }
}
