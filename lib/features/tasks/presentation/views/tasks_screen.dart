import 'package:todo_2025/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo_2025/core/utils/date_utils.dart';
import 'package:todo_2025/features/tasks/presentation/controllers/task_provider.dart';
import 'package:todo_2025/features/tasks/presentation/widgets/add_task_bottom_sheet.dart';
import 'package:todo_2025/features/tasks/presentation/widgets/task_item.dart';
import 'package:todo_2025/features/tasks/data/models/task_model.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo 2025'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTaskBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () => _toggleTheme(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskBottomSheet(context),
        child: const Icon(Icons.add),
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet',
                    style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add a new task',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ],
              ),
            );
          }
          
          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            onReorder: (oldIndex, newIndex) {
              ref.read(taskProvider.notifier).reorderTasks(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskItem(task, context);
            },
          );
        },
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task, BuildContext context) {
    return Padding(
      key: Key(task.id),
      padding: const EdgeInsets.only(bottom: 8),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _deleteTask(context, task.id),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: TaskItem(
          task: task,
          onTap: () => _showEditTaskBottomSheet(context, task),
          onCheckboxChanged: (value) {
            ref.read(taskProvider.notifier).toggleTaskCompletion(task.id);
          },
        ),
      ),
    );
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddTaskBottomSheet(),
    );
  }

  void _showEditTaskBottomSheet(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddTaskBottomSheet(taskToEdit: task),
    );
  }

  void _deleteTask(BuildContext context, String id) {
    ref.read(taskProvider.notifier).deleteTask(id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => ref.read(taskProvider.notifier).undoDelete(),
        ),
      ),
    );
  }

  void _toggleTheme(BuildContext context) {
    final currentTheme = Theme.of(context).brightness == Brightness.dark;
    ref.read(themeProvider.notifier).toggleTheme(!currentTheme);
  }
}