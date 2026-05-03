import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'core/api_client.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/customer_provider.dart';
import 'presentation/providers/expense_provider.dart';
import 'presentation/providers/report_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux)) {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(const Size(380, 640));
    await windowManager.setMaximumSize(const Size(520, 960));
    await windowManager.setMaximizable(false);
  }

  runApp(const FixLogApp());
}

class FixLogApp extends StatelessWidget {
  const FixLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiClient: apiClient)),
        ChangeNotifierProvider(create: (_) => CustomerProvider(apiClient: apiClient)),
        ChangeNotifierProvider(create: (_) => ExpenseProvider(apiClient: apiClient)),
        ChangeNotifierProvider(create: (_) => ReportProvider(apiClient: apiClient)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Fix Log',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}
