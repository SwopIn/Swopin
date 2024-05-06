import 'package:equatable/equatable.dart';
import 'package:swopin/models/subtasks_model.dart';

enum SocialTaskType { telegram, web, crypto, other }

/*
  добавил новые типы для комментариев, чтобы было удобнее контролировать время
 выполнения задачи, например, если задача содержит комментарии, то таймаут на выполнение
 увеличивается с 5 секунд до 10-15, потому что юзер за 5 секунд вряд ли успеет написать коммент
 0 - telegram link,
 1 - web link,
 2- telegram comment
 3 - web comment
 4 - crypto link
 5 - other
 */

class Task extends Equatable {
  final int id;
  final String title;
  final int reward;
  final String imageUrl;
  final String description;
  final DateTime? endDate;
  final bool isCompleted;
  final List<SubTask> subTasks;

  const Task({
    required this.id,
    required this.title,
    required this.reward,
    required this.imageUrl,
    required this.description,
    required this.isCompleted,
    this.endDate,
    required this.subTasks,
  });

  @override
  List<Object> get props =>
      [id, title, imageUrl, description, subTasks, reward, isCompleted];

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'image_url': imageUrl,
      'description': description,
      'reward': reward,
      'endDate': endDate?.toIso8601String(),
      'sub_tasks': subTasks.map((subTask) => subTask.toMap()).toList(),
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      reward: map['reward'],
      imageUrl: map['image_url'],
      description: map['description'],
      isCompleted: false,
      endDate: map['endDate'] == null ? null : DateTime.parse(map['endDate']),
      subTasks: List<SubTask>.from(
          map['sub_tasks'].map((subTaskMap) => SubTask.fromMap(subTaskMap))),
/*      subTasks: [],*/
    );
  }

  @override
  String toString() {
    return 'Task { id: $id,endDate: $endDate, title: $title, image_url: $imageUrl, '
        'description: $description, reward: $reward, subTasks: $subTasks, isCompleted $isCompleted }';
  }

  Task copyWith({
    int? id,
    String? title,
    String? imageUrl,
    int? reward,
    bool? isCompleted,
    String? description,
    DateTime? endDate,
    List<SubTask>? subTasks,
  }) {
    return Task(
      id: id ?? this.id,
      reward: reward ?? this.reward,
      title: title ?? this.title,
      endDate: endDate ?? this.endDate,
      imageUrl: imageUrl ?? this.imageUrl,
      isCompleted: isCompleted ?? this.isCompleted,
      description: description ?? this.description,
      subTasks: subTasks ?? this.subTasks,
    );
  }
}
