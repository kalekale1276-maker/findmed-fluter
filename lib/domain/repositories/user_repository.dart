import '../entities/user.dart';

abstract class UserRepository {
  Future<User> login(String email, String password);
  Future<User> register(String email, String password, String firstName, String lastName);
  Future<User> getUserProfile(String userId);
}
