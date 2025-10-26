import 'package:smart_task_manager/core/network/network_exceptions.dart';
import 'package:smart_task_manager/features/tasks/data/datasources/tasks_remote_datasource.dart';
import 'package:smart_task_manager/features/tasks/data/models/task_model.dart';
import 'package:smart_task_manager/features/tasks/domain/entities/task.dart';
import 'package:smart_task_manager/features/tasks/domain/repositories/tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  
  TasksRepositoryImpl(this._remoteDataSource);
  final TasksRemoteDataSource _remoteDataSource;
  
  @override
  Future<Task> createTask(Task task) async {
    try {
      final taskModel = await _remoteDataSource.createTask(
        TaskModel(
          title: task.title,
          description: task.description,
          completed: task.completed,
        ),
      );
      return Task(
        id: taskModel.id,
        title: taskModel.title,
        description: taskModel.description,
        completed: taskModel.completed,
      );
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to create task: $e');
    }
  }
  
  @override
  Future<Task> getTaskDetails(int taskId) async {
    try {
      final taskModel = await _remoteDataSource.getTaskDetails(taskId);
      return Task(
        id: taskModel.id,
        title: taskModel.title,
        description: taskModel.description,
        completed: taskModel.completed,
      );
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch task: $e');
    }
  }

  @override
  Future<List<Task>> getAllTasks() async {
    try {
      final taskModels = await _remoteDataSource.getAllTasks();
      return taskModels
          .map(
            (taskModel) => Task(
              id: taskModel.id,
              title: taskModel.title,
              description: taskModel.description,
              completed: taskModel.completed,
            ),
          )
          .toList();
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch tasks: $e');
    }
  }

  @override
  Future<void> deleteTask(int taskId) async {
    try {
      await _remoteDataSource.deleteTask(taskId);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to delete task: $e');
    }
  }
}
