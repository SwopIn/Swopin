import '../data/auth/auth_repository.dart';

class AuthModule {
  static AuthRepository? _repository;

  static AuthRepository authRepository() {
    _repository ??= Auth();
    return _repository!;
  }
}
