import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swopin/data/auth/auth_controller.dart';
import 'package:swopin/data/remote/remote_config.dart';

import 'data/telegram/telegram_app.dart';
import 'env/env.dart';
import 'app/error_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// run only on Telegram
  if (!telegram.isTelegram) {
    runApp(const ErrorApp());
    return;
  }

  /// run only on mobile
  if (!telegram.isMobile) {
    runApp(const ErrorApp(
      error: 'Desktop app is not supported',
    ));
    return;
  }

  /// expand app
  telegram.expandApp();

  /// initialize firebase
  if (kIsWeb) {
    FirebaseOptions options = const FirebaseOptions(
        apiKey: Env.API_KEY,
        authDomain: Env.AUTH_DOMAIN,
        projectId: Env.PROJECT_ID,
        storageBucket: Env.STORAGE_BUCKET,
        messagingSenderId: Env.MESSAGING_SENDER_ID,
        appId: Env.APP_ID,
        measurementId: Env.MEASUREMENT_ID);
    await Firebase.initializeApp(options: options);
  } else {
    await Firebase.initializeApp();
  }

  /// initialize supabase
  await Supabase.initialize(
    url: Env.DB,
    anonKey: Env.ANON_KEY,
  );
  final supabase = Supabase.instance.client;
  final auth = AuthController();

  /// initialize remote config
  await RemoteConfigService().initialize();

  /// initialize user
  telegram.getPassword().then((password) {
    final userId = telegram.userId!;
    final currentUser = supabase.auth.currentUser;

    if (password != null && password.isNotEmpty) {
      if (currentUser == null) {
        auth.authAttempt(userId: userId, password: password);
      } else {
        currentUser.phone! == telegram.userId.toString()
            ? auth.checkUser(id: currentUser.id)
            : auth.signOutAndAuthAttempt(userId: userId, password: password);
      }
    } else {
      currentUser == null
          ? auth.signUpAttempt(userId: userId)
          : auth.signOutAndAuthAttempt(userId: userId, password: password!);
    }
  }).catchError((error) {
    runApp(const ErrorApp());
  });

  /// listen for auth changes
  supabase.auth.onAuthStateChange.listen((data) {
    final AuthChangeEvent event = data.event;

    if (event == AuthChangeEvent.signedIn) {
      auth.checkUser(id: supabase.auth.currentUser!.id);
    }
  });
}
