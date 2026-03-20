import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../network/dio_client.dart';
import '../../data/datasources/remote/remote_data_source.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/user/get_user_profile.dart';
import '../../domain/usecases/auth/login.dart';
import '../../domain/usecases/auth/register.dart';

final GetIt sl = GetIt.instance;

class DependencyInjection {
  static Future<void> init() async {
    // External
    sl.registerLazySingleton(() => Dio());
    
    // Core
    sl.registerLazySingleton(() => DioClient(sl()));
    
    // Data sources
    sl.registerLazySingleton<RemoteDataSource>(
      () => RemoteDataSourceImpl(),
    );
    
    // Repositories
    sl.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(sl()),
    );
    
    // Use cases
    sl.registerLazySingleton(() => GetUserProfile(sl()));
    sl.registerLazySingleton(() => Login(sl()));
    sl.registerLazySingleton(() => Register(sl()));
  }
}
