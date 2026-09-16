import 'package:flutter_test/flutter_test.dart';

import 'package:fix_log/core/di/service_locator.dart';
import 'package:fix_log/core/router/app_router.dart';
import 'package:fix_log/main.dart';

void main() {
  testWidgets('Smoke test loads FixLogApp and shows the login screen', (
    WidgetTester tester,
  ) async {
    await setupServiceLocator();
    await tester.pumpWidget(FixLogApp(router: buildAppRouter()));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido'), findsOneWidget);
  });
}
