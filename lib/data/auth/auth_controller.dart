import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/app.dart';
import '../../dependency/auth_module.dart';
import '../../dependency/user_module.dart';
import '../../app/error_app.dart';
import '../path/path.dart';
import '../telegram/telegram_app.dart';
import 'auth_repository.dart';

mixin class AuthController {
  final supabase = Supabase.instance.client;
  final AuthRepository auth = AuthModule.authRepository();

  void signUpAttempt({required int userId}) {
    final newPassword = generatePassword(userId);

    auth.signUp(
        userId: userId,
        password: newPassword,
        onSuccess: () {
          telegram.savePassword(newPassword);
          checkUser(id: supabase.auth.currentUser!.id);
        },
        onError: (error) {
          runApp(const ErrorApp());
        });
  }

  void signOutAndAuthAttempt({required int userId, required String password}) {
    supabase.auth.signOut().then((value) {
      authAttempt(userId: userId, password: password);
    });
  }

  void authAttempt({required int userId, required String password}) {
    auth.signIn(
        userId: userId,
        password: password,
        onSuccess: () {},
        onError: (error) {
          final newPassword = generatePassword(userId);
          auth.signUp(
              userId: userId,
              password: newPassword,
              onSuccess: () {
                telegram.savePassword(newPassword);
                checkUser(id: supabase.auth.currentUser!.id);
              },
              onError: (error) {
                runApp(const ErrorApp());
              });
        });
  }

  void checkUser({required String id}) {
    UserModule.userRepository().fetchUserByUid(
        id: id,
        onError: (error) {
          runApp(const ErrorApp());
        },
        onSuccess: (user) {
          runApp(const MainApp());
        });
  }

  String generatePassword(int userId) {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int password = (userId + timestamp).hashCode;
    return kDebugMode ? DatabasePath.debugUserPassword : password.toString();
  }
}
