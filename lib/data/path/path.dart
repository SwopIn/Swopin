import '../../env/env.dart';

class DatabasePath {
  //tables
  static const String user = Env.user;
  static const String tasks = Env.tasks;

  //auth
  static const String saveUser = Env.saveUser;
  static const String saveUser1 = Env.saveUser1;
  static const String saveUser2 = Env.saveUser2;

  //daily claim
  static const String claimToken = Env.claimToken;
  static const String claimToken1 = Env.claimToken1;
  static const String claimToken2 = Env.claimToken2;

  //solve task
  static const String checkTask = Env.checkTask;
  static const String checkTask1 = Env.checkTask1;
  static const String checkTask2 = Env.checkTask2;
  static const String checkTask3 = Env.checkTask3;

  //telegram app
  static const String debugUser = Env.debugUser;
  static const String debugUserFirstName = Env.debugUserFirstName;
  static const int debugUserId = Env.debugUserId;
  static const String debugUserPassword = Env.debugUserPassword;
  static const String passwordKey = Env.passwordKey;
  static const String inviteLink = Env.inviteLink;

  //remote
  static const String totalBalance = Env.totalBalance;
  static const String totalUsers = Env.totalUsers;
  static const String onlineUsers = Env.onlineUsers;
  static const String dailyUsers = Env.dailyUsers;
  static const String newsLink = Env.newsLink;
}
