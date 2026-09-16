import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/customer.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/report.dart';
import '../../ui/auth/view_models/auth_cubit.dart';
import '../../ui/auth/widgets/login_screen.dart';
import '../../ui/auth/widgets/register_screen.dart';
import '../../ui/customer/widgets/customer_form_screen.dart';
import '../../ui/expense/widgets/expense_form_screen.dart';
import '../../ui/home/widgets/home_screen.dart';
import '../../ui/report/widgets/report_form_screen.dart';
import '../di/service_locator.dart';
import 'app_routes.dart';

/// Turns a Cubit's state stream into a [Listenable] so GoRouter can
/// re-evaluate `redirect` whenever auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter buildAppRouter() {
  final authCubit = getIt<AuthCubit>();

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final isAuthenticated = authCubit.state.isAuthenticated;
      final isOnAuthScreen =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (!isAuthenticated && !isOnAuthScreen) return AppRoutes.login;
      if (isAuthenticated && isOnAuthScreen) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerNew,
        builder: (context, state) => const CustomerFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerEdit,
        builder: (context, state) =>
            CustomerFormScreen(customer: state.extra as Customer?),
      ),
      GoRoute(
        path: AppRoutes.expenseNew,
        builder: (context, state) => const ExpenseFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.expenseEdit,
        builder: (context, state) =>
            ExpenseFormScreen(expense: state.extra as Expense?),
      ),
      GoRoute(
        path: AppRoutes.reportNew,
        builder: (context, state) => const ReportFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.reportEdit,
        builder: (context, state) =>
            ReportFormScreen(report: state.extra as Report?),
      ),
    ],
  );
}
