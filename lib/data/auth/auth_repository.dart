import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swopin/data/auth/auth_controller.dart';
import 'package:swopin/data/path/path.dart';

/// `AuthRepository` is an abstract class that defines the structure and behavior of an authentication repository.
abstract class AuthRepository {
  /// Saves the user's Telegram ID.
  ///
  /// The [tgId] parameter specifies the Telegram ID to be saved.
  /// The [onSuccess] callback is executed when the operation is successful.
  /// The [onError] callback is executed when the operation encounters an error.
  void saveUser(
      {required int tgId,
      required Function() onSuccess,
      required Function(dynamic error) onError});

  /// Signs in the user.
  ///
  /// The [userId] parameter specifies the user's ID.
  /// The [password] parameter specifies the user's password.
  /// The [onSuccess] callback is executed when the operation is successful.
  /// The [onError] callback is executed when the operation encounters an error.
  void signIn(
      {required int userId,
      required String password,
      required Function() onSuccess,
      required Function(dynamic error) onError});

  /// Signs up the user.
  ///
  /// The [userId] parameter specifies the user's ID.
  /// The [password] parameter specifies the user's password.
  /// The [onSuccess] callback is executed when the operation is successful.
  /// The [onError] callback is executed when the operation encounters an error.
  void signUp(
      {required int userId,
      required String password,
      required Function() onSuccess,
      required Function(dynamic error) onError});
}

class Auth implements AuthRepository {
  final _supaBase = Supabase.instance.client;

  @override
  void saveUser(
      {required int tgId,
      required Function() onSuccess,
      required Function(dynamic error) onError}) {
    _supaBase.rpc(DatabasePath.saveUser, params: {
      DatabasePath.saveUser1: _supaBase.auth.currentUser!.id,
      DatabasePath.saveUser2: tgId,
    }).then((value) {
      onSuccess();
    }).catchError((error) {
      onError(error);
    });
  }

  @override
  void signIn(
      {required int userId,
      required String password,
      required Function() onSuccess,
      required Function(dynamic error) onError}) {
    _supaBase.auth
        .signInWithPassword(
      phone: userId.toString(),
      password: password.toString(),
    )
        .then((value) {
      onSuccess();
      if (kDebugMode) {
        print('success sign in with password $password');
      }
    }).catchError((error) {
      onError(onError);
      if (kDebugMode) {
        print('error sign in with password $password $error');
      }
    });
  }

  @override
  void signUp(
      {required int userId,
      required String password,
      required Function() onSuccess,
      required Function(dynamic error) onError}) {
    _supaBase.auth
        .signUp(
      phone: userId.toString(),
      password: password.toString(),
    )
        .then((value) {
      saveUser(
          tgId: userId,
          onSuccess: () {
            onSuccess();
          },
          onError: (error) {
            onError(error);
          });
    }).catchError((error) {
      if (kDebugMode) {
        print('error sign up $error');
      }
      onError(error);
    });
  }
}
