import 'package:flutter/foundation.dart';
import 'package:swopin/data/telegram/telegram_app.dart';
import 'dart:async';
import 'package:telegram_web_app/telegram_web_app.dart';

import '../path/path.dart';

class TelegramProvider implements TelegramApp {
  TelegramProvider._privateConstructor();

  static final tg = kDebugMode ? TelegramWebAppFake() : TelegramWebApp.instance;

  static final TelegramProvider instance =
      TelegramProvider._privateConstructor();

  @override
  int? get userId => tg.initDataUnsafe?.user?.id;

  @override
  String? get username => tg.initDataUnsafe?.user?.username;

  @override
  String? get firstName => tg.initDataUnsafe?.user?.first_name;

  @override
  bool get isTelegram => tg.platform != 'unknown' || kDebugMode;

  @override
  bool get isMobile =>
      tg.platform == 'android' || tg.platform == 'ios' || kDebugMode;

  @override
  Future<String?> getPassword() {
    Completer<String?> completer = Completer<String?>();
    tg.cloudStorage.getItem(DatabasePath.passwordKey, (error, [result]) {
      if (error != null) {
        completer.completeError(error);
      } else {
        completer.complete(result);
      }
    });
    return completer.future;
  }

  @override
  void savePassword(String password) {
    tg.cloudStorage.setItem(DatabasePath.passwordKey, password);
  }

  @override
  void expandApp() async {
    await tg.expand();
  }

  @override
  void openTelegramLink(String url) async {
    await tg.openTelegramLink(url);
  }

  @override
  void openWebLink(String url) async {
    await tg.openLink(url);
  }

  @override
  void requestRefLink() async {
    await tg.openTelegramLink(DatabasePath.inviteLink);
    await tg.close();
  }

  @override
  void showConfirm({required bool show}) async {
    if (show) {
      await tg.enableClosingConfirmation();
    } else {
      await tg.disableClosingConfirmation();
    }
  }

  @override
  void hapticFeedback({bool softVibration = false}) {
    tg.hapticFeedback.impactOccurred(softVibration
        ? HapticFeedbackImpact.light
        : HapticFeedbackImpact.heavy);
  }
}
