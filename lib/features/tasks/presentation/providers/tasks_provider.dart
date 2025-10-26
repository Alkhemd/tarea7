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
  Future<Task?> updateTask(Task updatedTask) async {
    state = const AsyncValue.loading();
    try {
      final tasksRepository = ref.read(tasksRepositoryProvider);
      // Aquí deberías tener un método updateTask en el repositorio, pero si no existe, simula la actualización localmente
      // final task = await tasksRepository.updateTask(updatedTask);
      // Por ahora, solo actualiza la lista localmente:
      final tasksListNotifier = ref.read(tasksListProvider.notifier);
      final currentTasks = tasksListNotifier.state.value ?? [];
      final updatedTasks = currentTasks.map((task) =>
        task.id == updatedTask.id ? updatedTask : task
      ).toList();
      tasksListNotifier.state = AsyncValue.data(updatedTasks);
      state = AsyncValue.data(updatedTask);
      return updatedTask;
    } on Object catch (e, s) {
      state = AsyncValue.error(e, s);
      return null;
    }
  }
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
  Future<void> updateTask(Task updatedTask) async {
    try {
      // Si tu backend soporta update, llama aquí
      // await tasksRepository.updateTask(updatedTask);
      // Por ahora, solo actualiza la lista localmente:
      final currentTasks = state.value ?? [];
      final updatedTasks = currentTasks.map((task) =>
        task.id == updatedTask.id ? updatedTask : task
      ).toList();
      state = AsyncValue.data(updatedTasks);
    } on Object {
      // Manejo de error opcional
    }
  }

  Future<void> toggleTaskCompleted(Task task) async {
    final updatedTask = task.copyWith(completed: !task.completed);
    await updateTask(updatedTask);
  }
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

  Future<void> deleteTask(int taskId) async {
    try {
      final tasksRepository = ref.read(tasksRepositoryProvider);
      await tasksRepository.deleteTask(taskId);
      
      // Manually update the tasks list
      final currentTasks = state.value ?? [];
      state = AsyncValue.data(
        currentTasks.where((task) => task.id != taskId).toList(),
      );
    } on Object {
      // If the delete fails, we can show an error
      // For simplicity, we are not handling the error state here
    }
  }
}
// 7. NotifierProvider for the tasks list
final tasksListProvider =
    NotifierProvider<TasksListNotifier, AsyncValue<List<Task>>>(
  TasksListNotifier.new,
);
