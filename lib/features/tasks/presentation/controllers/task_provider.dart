import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo_2025/core/constants/hive_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_2025/features/tasks/data/repositories/task_repository.dart';
import 'package:todo_2025/features/tasks/data/models/task_model.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<TaskModel>>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskNotifier(repository);
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(Hive.box(HiveConstants.tasksBox));
});

class TaskNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final TaskRepository _repository;
  final List<TaskModel> _deletedTasks = [];
  final List<String> _deletedTaskIds = [];

  TaskNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await _repository.getAllTasks();
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTask(TaskModel task) async {
    state.whenData((tasks) async {
      state = const AsyncValue.loading();
      try {
        await _repository.addTask(task);
        final updatedTasks = await _repository.getAllTasks();
        state = AsyncValue.data(updatedTasks);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }

  Future<void> updateTask(TaskModel task) async {
    state.whenData((tasks) async {
      state = const AsyncValue.loading();
      try {
        await _repository.updateTask(task);
        final updatedTasks = await _repository.getAllTasks();
        state = AsyncValue.data(updatedTasks);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }

  Future<void> deleteTask(String id) async {
    state.whenData((tasks) async {
      state = const AsyncValue.loading();
      try {
        final taskToDelete = tasks.firstWhere((task) => task.id == id);
        _deletedTasks.add(taskToDelete);
        _deletedTaskIds.add(id);
        
        await _repository.deleteTask(id);
        final updatedTasks = await _repository.getAllTasks();
        state = AsyncValue.data(updatedTasks);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }

  Future<void> undoDelete() async {
    if (_deletedTasks.isEmpty) return;
    
    state.whenData((tasks) async {
      state = const AsyncValue.loading();
      try {
        final taskToRestore = _deletedTasks.last;
        await _repository.addTask(taskToRestore);
        
        _deletedTasks.removeLast();
        _deletedTaskIds.removeLast();
        
        final updatedTasks = await _repository.getAllTasks();
        state = AsyncValue.data(updatedTasks);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }

  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    state.whenData((tasks) async {
      state = const AsyncValue.loading();
      try {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final task = tasks.removeAt(oldIndex);
        tasks.insert(newIndex, task);
        
        await _repository.reorderTasks(tasks);
        state = AsyncValue.data(List.from(tasks));
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }

  Future<void> toggleTaskCompletion(String id) async {
    state.whenData((tasks) async {
      state = const AsyncValue.loading();
      try {
        final taskIndex = tasks.indexWhere((task) => task.id == id);
        if (taskIndex != -1) {
          final task = tasks[taskIndex];
          final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
          
          await _repository.updateTask(updatedTask);
          final updatedTasks = await _repository.getAllTasks();
          state = AsyncValue.data(updatedTasks);
        }
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }
}