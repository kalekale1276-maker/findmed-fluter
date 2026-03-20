import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class Register {
  Register(this._repository);
  
  final UserRepository _repository;
  
  Future<User> call(String email, String password, String firstName, String lastName) {
    return _repository.register(email, password, firstName, lastName);
  }
}
