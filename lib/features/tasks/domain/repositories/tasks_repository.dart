import 'package:smart_task_manager/features/tasks/domain/entities/task.dart';

abstract class TasksRepository {
  Future<Task> createTask(Task task);
  Future<Task> getTaskDetails(int taskId);
  Future<List<Task>> getAllTasks();
}
