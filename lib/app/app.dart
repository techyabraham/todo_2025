import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_2025/app/theme.dart';
import 'package:todo_2025/features/tasks/presentation/views/tasks_screen.dart';

class TodoApp extends ConsumerWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Todo 2025',
      debugShowCheckedModeBanner: false,
      themeMode: appTheme.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const TasksScreen(),
    );
  }
}