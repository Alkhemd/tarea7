import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/core/network/dio_client.dart';
import 'package:smart_task_manager/features/tasks/data/datasources/tasks_remote_datasource.dart';
import 'package:smart_task_manager/features/tasks/data/repositories/tasks_repository_impl.dart';
import 'package:smart_task_manager/features/tasks/domain/entities/task.dart';
import 'package:smart_task_manager/features/tasks/domain/repositories/tasks_repository.dart';

// 1. Provider for DioClient
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

// 2. Provider for TasksRemoteDataSource
final tasksRemoteDataSourceProvider = Provider<TasksRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return TasksRemoteDataSource(dioClient);
});

// 3. Provider for TasksRepository
final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  final remoteDataSource = ref.watch(tasksRemoteDataSourceProvider);
  return TasksRepositoryImpl(remoteDataSource);
});

// 4. Notifier for managing task state
class TasksNotifier extends Notifier<AsyncValue<Task?>> {
  @override
  AsyncValue<Task?> build() {
    return const AsyncValue.data(null);
  }

  Future<Task?> createTask(String title, String description) async {
    state = const AsyncValue.loading();
    try {
      final tasksRepository = ref.read(tasksRepositoryProvider);
      final task = Task(title: title, description: description);
      final createdTask = await tasksRepository.createTask(task);
      state = AsyncValue.data(createdTask);

      // Manually update the tasks list
      final tasksListNotifier = ref.read(tasksListProvider.notifier);
      final currentTasks = tasksListNotifier.state.value ?? [];
      tasksListNotifier.state = AsyncValue.data([createdTask, ...currentTasks]);

      return createdTask;
    } on Object catch (e, s) {
      state = AsyncValue.error(e, s);
      return null;
    }
  }

  Future<void> getTaskDetails(int taskId) async {
    state = const AsyncValue.loading();
    try {
      final tasksRepository = ref.read(tasksRepositoryProvider);
      final task = await tasksRepository.getTaskDetails(taskId);
      state = AsyncValue.data(task);
    } on Object catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}

// 5. NotifierProvider
final tasksProvider =
    NotifierProvider<TasksNotifier, AsyncValue<Task?>>(TasksNotifier.new);

// 6. Notifier for managing tasks list state
class TasksListNotifier extends Notifier<AsyncValue<List<Task>>> {
  @override
  AsyncValue<List<Task>> build() {
    return const AsyncValue.loading();
  }

  Future<void> getAllTasks() async {
    state = const AsyncValue.loading();
    try {
      final tasksRepository = ref.read(tasksRepositoryProvider);
      final tasks = await tasksRepository.getAllTasks();
      state = AsyncValue.data(tasks);
    } on Object catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}

// 7. NotifierProvider for the tasks list
final tasksListProvider =
    NotifierProvider<TasksListNotifier, AsyncValue<List<Task>>>(
  TasksListNotifier.new,
);

