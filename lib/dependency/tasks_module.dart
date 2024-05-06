import '../data/tasks/tasks_repository.dart';

class TaskModule {
  static TaskRepository? _repository;

  static TaskRepository taskRepository() {
    _repository ??= TaskRepositoryImpl();
    return _repository!;
  }

}