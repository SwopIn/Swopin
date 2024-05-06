import 'package:equatable/equatable.dart';

/// This class represents a user in the application.
class User extends Equatable {

  /// The unique Telegram ID of the user.
  final int tgId;

  /// The unique ID of the user in the application.
  final String id;

  /// The Telegram ID of the user who referred this user (if any).
  final int? tgRefId;

  /// The timestamp when the user joined the application.
  final DateTime joinTimestamp;

  /// The timestamp when the user claimed a reward (if any).
  final DateTime? claimTimestamp;

  /// The ID of the chat in which the user is participating (if any).
  final int? chatId;

  /// The timestamp when the user was banned (if any).
  final DateTime? banTimestamp;

  /// The balance of the user's claims.
  final int claimBalance;

  /// The balance of the user's tasks.
  final int taskBalance;

  /// The number of referrals made by the user.
  final int refCount;

  /// The list of tasks completed by the user (if any).
  final List<int>? tasks;

  User({
    required this.tgId,
    required this.id,
    this.tgRefId,
    required this.joinTimestamp,
    this.claimTimestamp,
    required this.chatId,
    this.banTimestamp,
    required this.claimBalance,
    required this.taskBalance,
    required this.refCount,
    required this.tasks,
  });

  @override
  List<Object> get props =>
      [tgId, id, joinTimestamp, claimBalance, taskBalance, refCount];

  int get balance =>
      calculateReward() + taskBalance + refCount * 100;

  int get refBalance => refCount * 100;

  int todayCoins() {
    return rewards[claimBalance] ?? 100;
  }

  int tomorrowCoins() {
    return rewards[claimBalance+1] ?? 100;
  }

  int calculateReward() {
    int total = 0;
    for (int i = 0; i <= claimBalance; i++) {
      total += rewards[i] ?? 0;
    }
    return total;
  }

  @override
  String toString() {
    return 'user { tgId: $tgId, id: $id, tgRefId: $tgRefId, joinTimestamp: $joinTimestamp, claimTimestamp: $claimTimestamp, chatId: $chatId, banTimestamp: $banTimestamp, claimBalance: $claimBalance, taskBalance: $taskBalance, refCount: $refCount, tasks: $tasks }';
  }

  Map<String, dynamic> toMap() {
    return {
      'tg_id': tgId,
      'id': id,
      'tg_ref_id': tgRefId,
      'join_timestamp': joinTimestamp.toIso8601String(),
      'claim_timestamp': claimTimestamp?.toIso8601String(),
      'chat_id': chatId,
      'ban_timestamp': banTimestamp?.toIso8601String(),
      'claim_balance': claimBalance,
      'task_balance': taskBalance,
      'ref_count': refCount,
      'tasks': tasks,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      tgId: map['tg_id'],
      id: map['id'],
      tgRefId: map['tg_ref_id'],
      joinTimestamp: DateTime.parse(map['join_timestamp']),
      claimTimestamp: map['claim_timestamp'] == null
          ? DateTime(2020)
          : DateTime.parse(map['claim_timestamp']),
      chatId: map['chat_id'],
      banTimestamp: map['ban_timestamp'] == null
          ? null
          : DateTime.parse(map['ban_timestamp']),
      claimBalance: map['claim_balance'],
      taskBalance: map['task_balance'],
      refCount: map['ref_count'],
      tasks: List<int>.from(map['tasks'] ?? []),
    );
  }

  User copyWith({
    int? tgId,
    String? id,
    int? tgRefId,
    DateTime? joinTimestamp,
    DateTime? claimTimestamp,
    int? chatId,
    DateTime? banTimestamp,
    int? claimBalance,
    int? taskBalance,
    int? refCount,
    List<int>? tasks,
  }) {
    return User(
      tgId: tgId ?? this.tgId,
      id: id ?? this.id,
      tgRefId: tgRefId ?? this.tgRefId,
      joinTimestamp: joinTimestamp ?? this.joinTimestamp,
      claimTimestamp: claimTimestamp ?? this.claimTimestamp,
      chatId: chatId ?? this.chatId,
      banTimestamp: banTimestamp ?? this.banTimestamp,
      claimBalance: claimBalance ?? this.claimBalance,
      taskBalance: taskBalance ?? this.taskBalance,
      refCount: refCount ?? this.refCount,
      tasks: tasks ?? this.tasks,
    );
  }

  final Map<int, int> rewards = {
    0: 0,
    1: 1,
    2: 4,
    3: 12,
    4: 26,
    5: 60,
    6: 102,
    7: 160,
    8: 204,
    9: 236,
    10: 264,
    11: 286,
    12: 306,
    13: 324,
    14: 338,
    15: 354,
    16: 366,
    17: 378,
    18: 390,
    19: 400,
    20: 410,
    21: 420,
    22: 428,
    23: 436,
    24: 444,
    25: 452,
    26: 460,
    27: 466,
    28: 474,
    29: 480,
    30: 486,
    31: 494,
    32: 500,
    33: 506,
    34: 510,
    35: 516,
    36: 522,
    37: 528,
    38: 532,
    39: 538,
    40: 542,
    41: 548,
    42: 552,
    43: 558,
    44: 562,
    45: 568,
    46: 572,
    47: 576,
    48: 580,
    49: 586,
    50: 590,
    51: 594,
    52: 598,
    53: 602,
    54: 606,
    55: 612,
    56: 616,
    57: 620,
    58: 624,
    59: 628,
    60: 632,
    61: 636,
    62: 640,
    63: 644,
    64: 648,
    65: 652,
    66: 656,
    67: 660,
    68: 664,
    69: 668,
    70: 672,
    71: 676,
    72: 680,
    73: 684,
    74: 688,
    75: 692,
    76: 696,
    77: 700,
    78: 704,
    79: 708,
    80: 712,
    81: 716,
    82: 720,
    83: 724,
    84: 728,
    85: 732,
    86: 736,
    87: 740,
    88: 744,
    89: 748,
    90: 752,
    91: 756,
    92: 760,
    93: 762,
    94: 766,
  };

}
