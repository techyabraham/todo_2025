import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_2025/app/app.dart';
import 'package:todo_2025/core/constants/hive_constants.dart';
import 'package:todo_2025/features/tasks/data/models/task_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(PriorityAdapter());
  Hive.registerAdapter(CategoryAdapter());

  // Open boxes
  await Hive.openBox<TaskModel>(HiveConstants.tasksBox);

  runApp(
    ProviderScope(  // ← THIS IS THE CRITICAL ADDITION
      child: const TodoApp(),
    ),
  );
}