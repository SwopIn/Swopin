import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swopin/data/path/path.dart';

abstract class DailyClaimRepository {
  /// Claims a certain amount for the user.
  ///
  /// The [userId] parameter specifies the user's ID.
  /// The [amount] parameter specifies the amount to be claimed.
  /// Returns a [BehaviorSubject] that emits the claim status.
  BehaviorSubject<String> claim(String userId, int amount);
}

class DailyClaim implements DailyClaimRepository {
  final _supaBase = Supabase.instance.client;

  @override
  BehaviorSubject<String> claim(String userId, int amount) {
    final BehaviorSubject<String> result = BehaviorSubject<String>();

    _supaBase
        .rpc(DatabasePath.claimToken, params: {
          DatabasePath.claimToken1: userId,
          DatabasePath.claimToken2: amount
        })
        .then((value) => result.add('Success'))
        .catchError((onError) {
          if (onError is PostgrestException) {
            result.addError(onError.message);
          } else {
            result.addError(onError.toString());
          }
        });

    return result;
  }
}
