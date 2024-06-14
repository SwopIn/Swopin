import 'dart:async';

import 'package:swopin/data/path/path.dart';
import 'package:swopin/data/telegram/telegram_app.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

class DebugTelegramProvider implements TelegramApp {
  DebugTelegramProvider._privateConstructor();

  //static final tg = TelegramWebAppFake();
  static final tg = TelegramWebApp.instance;

  static final DebugTelegramProvider instance =
      DebugTelegramProvider._privateConstructor();

  @override
  int? get userId => DatabasePath.debugUserId;

  @override
  String? get username => DatabasePath.debugUser;

  @override
  String? get firstName => DatabasePath.debugUserFirstName;

  @override
  bool get isTelegram => true;

  @override
  bool get isMobile => true;

  @override
  Future<String?> getPassword() {
    Completer<String?> completer = Completer<String?>();
    completer.complete(DatabasePath.debugUserPassword);
    return completer.future;
  }

  @override
  void savePassword(String password) {}

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
        : HapticFeedbackImpact.medium);
  }
}
