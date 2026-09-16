import 'package:get_it/get_it.dart';

import '../../data/network/api_client.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../data/services/auth_remote_data_source.dart';
import '../../data/services/auth_remote_data_source_http.dart';
import '../../data/services/customer_remote_data_source.dart';
import '../../data/services/customer_remote_data_source_http.dart';
import '../../data/services/expense_remote_data_source.dart';
import '../../data/services/expense_remote_data_source_http.dart';
import '../../data/services/report_remote_data_source.dart';
import '../../data/services/report_remote_data_source_http.dart';
import '../../ui/auth/view_models/auth_cubit.dart';
import '../../ui/core/theme/theme_cubit.dart';
import '../../ui/customer/view_models/customer_cubit.dart';
import '../../ui/expense/view_models/expense_cubit.dart';
import '../../ui/report/view_models/report_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  getIt.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

  _registerAuth();
  _registerCustomer();
  _registerReport();
  _registerExpense();

  getIt<ApiClient>().onUnauthorized = () => getIt<AuthCubit>().logout();
}

void _registerAuth() {
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceHttp(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>(), getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(getIt<AuthRepository>()),
  );
}

void _registerCustomer() {
  getIt.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceHttp(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(getIt<CustomerRemoteDataSource>()),
  );
  getIt.registerLazySingleton<CustomerCubit>(
    () => CustomerCubit(getIt<CustomerRepository>()),
  );
}

void _registerReport() {
  getIt.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSourceHttp(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(getIt<ReportRemoteDataSource>()),
  );
  getIt.registerLazySingleton<ReportCubit>(
    () => ReportCubit(getIt<ReportRepository>()),
  );
}

void _registerExpense() {
  getIt.registerLazySingleton<ExpenseRemoteDataSource>(
    () => ExpenseRemoteDataSourceHttp(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(getIt<ExpenseRemoteDataSource>()),
  );
  getIt.registerLazySingleton<ExpenseCubit>(
    () => ExpenseCubit(getIt<ExpenseRepository>()),
  );
}
