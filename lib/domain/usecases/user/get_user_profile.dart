import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class GetUserProfile {
  GetUserProfile(this._repository);
  
  final UserRepository _repository;
  
  Future<User> call(String userId) {
    return _repository.getUserProfile(userId);
  }
}
