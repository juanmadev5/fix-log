import 'package:flutter_test/flutter_test.dart';

import 'package:fix_log/domain/models/expense.dart';

void main() {
  group('given an expense with a price and quantity', () {
    group('when computing the total', () {
      test('then multiplies price by quantity', () {
        // Given
        final expense = Expense(
          id: 1,
          title: 'Gasolina',
          details: 'Combustible',
          price: 50000,
          quantity: 3,
        );

        // When
        final total = expense.total;

        // Then
        expect(total, 150000);
      });
    });
  });
}
