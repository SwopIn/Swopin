import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../data/telegram/telegram_app.dart';

class SubTask extends Equatable {
  final int type;
  final String link;
  final String title;

  const SubTask({
    required this.type,
    required this.link,
    required this.title,
  });

  @override
  List<Object> get props => [type, link, title];

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'link': link,
      'title': title,
    };
  }

  static SubTask fromMap(Map<String, dynamic> map) {
    return SubTask(
      type: map['type'],
      link: map['link'],
      title: map['title'],
    );
  }

  @override
  String toString() {
    return 'SubTask { type: $type, link: $link, title: $title }';
  }

  SubTask copyWith({
    int? type,
    String? link,
    String? title,
  }) {
    return SubTask(
      type: type ?? this.type,
      link: link ?? this.link,
      title: title ?? this.title,
    );
  }

  IconData getIcon() {
    switch (type) {
      case 0:
        return Icons.telegram;
      case 1:
        return Icons.web;
      case 2:
        return Icons.currency_bitcoin;
      default:
        return Icons.task_alt;
    }
  }

  Future<void> openLink() async {
    switch (type) {
      case 0:
        telegram.openTelegramLink(link);
      default:
        telegram.openWebLink(link);
    }
  }
}
