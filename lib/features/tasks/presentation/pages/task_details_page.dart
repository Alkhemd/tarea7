import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/tasks_provider.dart';

class TaskDetailsPage extends ConsumerStatefulWidget {
  const TaskDetailsPage({required this.taskId, super.key});
  final int taskId;

  @override
  ConsumerState<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends ConsumerState<TaskDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Fetch the task details when the page is initialized
    Future.microtask(
      () => ref
          .read(tasksProvider.notifier)
          .getTaskDetails(widget.taskId),
    );
  }

  @override
  Widget build(BuildContext context) {
  final taskAsyncValue = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Task Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: taskAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (task) {
          if (task == null) {
            // This can happen if the initial state is null or if the task is not found.
            // You might want to show a more specific message or UI.
            return const Center(
              child: Text('Task not found'),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    task.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Text(
                        'Status:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          task.completed ? 'Completed' : 'Pending',
                          style: TextStyle(
                            color: task.completed
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        backgroundColor: task.completed
                            ? Colors.green
                            : Colors.amber,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
