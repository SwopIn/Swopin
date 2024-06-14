import 'package:flutter/foundation.dart';
import 'package:swopin/data/telegram/telegram_provider.dart';

import 'debug_telegram_provider.dart';

/// `TelegramApp` is a singleton class that provides access to the Telegram application.
TelegramApp get telegram => kDebugMode ? DebugTelegramProvider.instance : TelegramProvider.instance;

/// `TelegramApp` is an abstract class that defines the structure and behavior of a Telegram application.
abstract class TelegramApp {
  /// Gets the unique identifier of the user.
  int? get userId;

  /// Gets the username of the user.
  String? get username;

  /// Gets the first name of the user.
  String? get firstName;

  /// Checks if the application is a Telegram application.
  bool get isTelegram;

  /// Checks if the application is running on a mobile device.
  bool get isMobile;

  /// Shows or hides the confirmation dialog.
  ///
  /// The [show] parameter determines whether to show or hide the confirmation dialog.
  void showConfirm({required bool show});

  /// Expands the application to full screen.
  void expandApp();

  /// Opens a web link in the application.
  ///
  /// The [url] parameter specifies the web link to be opened.
  void openWebLink(String url);

  /// Opens a Telegram link in the application.
  ///
  /// The [url] parameter specifies the Telegram link to be opened.
  void openTelegramLink(String url);

  /// Requests a referral link from the server.
  void requestRefLink();

  /// Saves the user's password.
  ///
  /// The [password] parameter specifies the password to be saved.
  void savePassword(String password);

  /// Create vibration, use for haptic feedback.
  void hapticFeedback({bool softVibration = false});

  /// Retrieves the user's saved password.
  ///
  /// Returns a `Future` that completes with the password.
  Future<String?> getPassword();
}
