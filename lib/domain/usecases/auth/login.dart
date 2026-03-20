import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class Login {
  Login(this._repository);
  
  final UserRepository _repository;
  
  Future<User> call(String email, String password) {
    return _repository.login(email, password);
  }
}
