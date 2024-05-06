import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:swopin/data/path/path.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  RemoteConfigService();

  Future<void> initialize() async {
    try {
      await _remoteConfig.ensureInitialized();
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 6),
        ),
      );
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      if (kDebugMode) {
        print('Remote Config: $e');
      }
    }
  }

  int get totalBalance => _remoteConfig.getInt(DatabasePath.totalBalance);

  int get totalPlayers => _remoteConfig.getInt(DatabasePath.totalUsers);

  int get onlineUsers => _remoteConfig.getInt(DatabasePath.onlineUsers);

  int get dailyUsers => _remoteConfig.getInt(DatabasePath.dailyUsers);

  String get newsLink => _remoteConfig.getString(DatabasePath.newsLink);
}
