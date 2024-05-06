import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swopin/data/path/path.dart';

import '../../models/task_model.dart';

abstract class TaskRepository {
  /// Fetches the list of tasks.
  ///
  /// Returns a [BehaviorSubject] that emits a list of tasks.
  BehaviorSubject<List<Task>> fetchTasks();

  /// Claims a reward for completing a task.
  ///
  /// The [userId] parameter specifies the user's ID.
  /// The [reward] parameter specifies the reward to be claimed.
  /// The [taskId] parameter specifies the ID of the task.
  /// Returns a [BehaviorSubject] that emits the claim status.
  BehaviorSubject<String> claim(
      {required String userId, required int reward, required int taskId});
}

class TaskRepositoryImpl implements TaskRepository {
  final _supaBase = Supabase.instance.client;

  @override
  BehaviorSubject<List<Task>> fetchTasks() {
    final BehaviorSubject<List<Task>> result = BehaviorSubject<List<Task>>();

    _supaBase
        .from(DatabasePath.tasks)
        .select()
        .gt('endDate', DateTime.now())
        .then((value) {
      result.add(value.map((e) => Task.fromMap(e)).toList());
    }).catchError((onError) {
      if (onError is PostgrestException) {
        result.addError(onError.message);
      } else {
        result.addError(onError);
      }
    });

    return result;
  }

  @override
  BehaviorSubject<String> claim(
      {required String userId, required int reward, required int taskId}) {
    final BehaviorSubject<String> result = BehaviorSubject<String>();

    _supaBase.rpc(DatabasePath.checkTask, params: {
      DatabasePath.checkTask1: userId,
      DatabasePath.checkTask2: taskId,
      DatabasePath.checkTask3: reward
    }).then((value) {
      result.add("Success");
    }).catchError((onError) {
      if (onError is PostgrestException) {
        result.addError(onError.message);
      } else {
        result.addError(onError);
      }
    });
    return result;
  }
}
