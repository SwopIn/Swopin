import '../data/user/user_repository.dart';

class UserModule {
  static UserRepository? _repository;

  static UserRepository userRepository() {
    _repository ??= UserRepositoryImpl();
    return _repository!;
  }

}