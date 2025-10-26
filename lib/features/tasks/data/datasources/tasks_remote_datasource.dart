import 'package:smart_task_manager/core/network/dio_client.dart';
import 'package:smart_task_manager/features/tasks/data/models/task_model.dart';

class TasksRemoteDataSource {
  
  TasksRemoteDataSource(this._dioClient);
  final DioClient _dioClient;
  
  // POST: Create a new task
  Future<TaskModel> createTask(TaskModel task) async {
    final taskJson = task.toJson();
    taskJson['userId'] = 1; // Hardcode userId for now
    final response = await _dioClient.post(
      '/posts', // JSONPlaceholder endpoint
      data: taskJson,
    );
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  }
  
  // GET: Fetch task details
  Future<TaskModel> getTaskDetails(int taskId) async {
    final response = await _dioClient.get('/posts/$taskId');
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  }
  
  // GET: Fetch all tasks
  Future<List<TaskModel>> getAllTasks() async {
    final response = await _dioClient.get('/posts');
    return (response.data as List)
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // DELETE: Delete a task
  Future<void> deleteTask(int taskId) async {
    await _dioClient.delete('/posts/$taskId');
  }
}
