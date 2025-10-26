import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/features/tasks/presentation/pages/create_task_page.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/tasks_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(tasksListProvider.notifier).getAllTasks());
  }

  @override
  Widget build(BuildContext context) {
    final tasksList = ref.watch(tasksListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Task Manager'),
      ),
      body: tasksList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (tasks) {
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(task.description),
                trailing: Checkbox(
                  value: task.completed,
                  onChanged: (value) {
                    // TODO(developer): Implement update task functionality
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const CreateTaskPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
