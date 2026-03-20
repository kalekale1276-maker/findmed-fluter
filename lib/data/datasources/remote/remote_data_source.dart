import '../../../domain/entities/user.dart';

abstract class RemoteDataSource {
  Future<User> login(String email, String password);
  Future<User> register(String email, String password, String firstName, String lastName);
  Future<User> getUserProfile(String userId);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  RemoteDataSourceImpl();
  
  // final DioClient _dioClient;
  
  @override
  Future<User> login(String email, String password) async {
    // TODO: Implement login API call
    throw UnimplementedError();
  }
  
  @override
  Future<User> register(String email, String password, String firstName, String lastName) async {
    // TODO: Implement register API call
    throw UnimplementedError();
  }
  
  @override
  Future<User> getUserProfile(String userId) async {
    // TODO: Implement getUserProfile API call
    throw UnimplementedError();
  }
}
