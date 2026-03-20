import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote/remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._remoteDataSource);
  
  final RemoteDataSource _remoteDataSource;
  
  @override
  Future<User> login(String email, String password) {
    return _remoteDataSource.login(email, password);
  }
  
  @override
  Future<User> register(String email, String password, String firstName, String lastName) {
    return _remoteDataSource.register(email, password, firstName, lastName);
  }
  
  @override
  Future<User> getUserProfile(String userId) {
    return _remoteDataSource.getUserProfile(userId);
  }
}
