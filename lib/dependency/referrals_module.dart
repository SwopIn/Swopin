import 'package:swopin/dependency/user_module.dart';

import '../data/referals/referals_repository.dart';

class ReferralsModule {
  static ReferralsRepository? _repository;

  static ReferralsRepository referralsRepository() {
    _repository ??=
        ReferralsRepositoryImpl(userRepository: UserModule.userRepository());
    return _repository!;
  }
}
