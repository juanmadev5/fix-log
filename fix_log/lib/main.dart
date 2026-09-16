import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import 'core/di/service_locator.dart';
import 'core/error_boundary.dart';
import 'core/router/app_router.dart';
import 'ui/auth/view_models/auth_cubit.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/core/theme/theme_cubit.dart';
import 'ui/customer/view_models/customer_cubit.dart';
import 'ui/expense/view_models/expense_cubit.dart';
import 'ui/report/view_models/report_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupErrorBoundary();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(const Size(380, 640));
    await windowManager.setMaximumSize(const Size(1280, 900));
    await windowManager.setMaximizable(true);
  }

  await setupServiceLocator();

  runApp(FixLogApp(router: buildAppRouter()));
}

class FixLogApp extends StatelessWidget {
  const FixLogApp({super.key, required this.router});

  final RouterConfig<Object> router;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<ThemeCubit>()),
        BlocProvider.value(value: getIt<AuthCubit>()),
        BlocProvider.value(value: getIt<CustomerCubit>()),
        BlocProvider.value(value: getIt<ExpenseCubit>()),
        BlocProvider.value(value: getIt<ReportCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Fix Log',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
