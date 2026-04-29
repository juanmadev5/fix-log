class Expense {
  final int id;
  final String title;
  final String details;
  final double price;
  final int quantity;

  Expense({
    required this.id,
    required this.title,
    required this.details,
    required this.price,
    required this.quantity,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int,
      title: json['title'] as String,
      details: json['details'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'details': details,
      'price': price,
      'quantity': quantity,
    };
  }
}
