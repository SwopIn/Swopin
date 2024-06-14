import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as base;
import 'package:swopin/data/path/path.dart';

import '../../models/user_model.dart';

abstract class UserRepository {
  /// A [BehaviorSubject] that emits the current user.
  BehaviorSubject<User> user = BehaviorSubject<User>();

  /// Fetches the user by their unique identifier.
  ///
  /// The [id] parameter specifies the unique identifier of the user.
  /// The [onError] callback is executed when the operation encounters an error.
  /// The [onSuccess] callback is executed when the operation is successful
  /// and returns the fetched user.
  void fetchUserByUid(
      {required String id,
      required Function(dynamic error) onError,
      required Function(User user) onSuccess});

  /// Fetches the user by their Telegram ID.
  ///
  /// The [id] parameter specifies the Telegram ID of the user.
  /// Returns a [BehaviorSubject] that emits the fetched user.
  BehaviorSubject<User> fetchUserByTg({required int id});

  /// Checks if the user has access to the beta version of the trade bot
  ///
  /// The [id] parameter specifies the Telegram ID of the user.
  /// The [onSuccess] callback is executed when the operation is successful
  /// and returns the fetched user.
  void checkBetaAccess({required int id, required Function() onSuccess});
}

class UserRepositoryImpl implements UserRepository {
  final _supaBase = base.Supabase.instance.client;

  @override
  BehaviorSubject<User> user = BehaviorSubject<User>();

  @override
  BehaviorSubject<User> fetchUserByTg({required int id}) {
    // TODO: implement fetchUserByTg
    throw UnimplementedError();
  }

  @override
  void fetchUserByUid(
      {required String id,
      required Function(dynamic error) onError,
      required Function(User user) onSuccess}) {
    _supaBase.from(DatabasePath.user).select().eq('id', id).then((value) {
      if (value.isEmpty) {
        user.addError('User not found');
        return;
      }
      final fetchedUser = User.fromMap(value[0]);
      user.add(fetchedUser);
      onSuccess(User.fromMap(value[0]));
    }).catchError((error) {
      user.addError(error);
      onError(error);
    });
  }

  @override
  void checkBetaAccess({required int id, required Function() onSuccess}) {
    _supaBase.from('b_testers').select().eq('tg_id', id).then((value) {
      if (value.isNotEmpty) {
        onSuccess();
      }
    });
  }
}
