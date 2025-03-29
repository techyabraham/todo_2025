import 'package:hive/hive.dart';
import 'package:todo_2025/core/constants/hive_constants.dart';
import 'package:todo_2025/features/tasks/data/models/task_model.dart';

class TaskRepository {
  final Box<TaskModel> _tasksBox;

  TaskRepository(this._tasksBox);

  Future<List<TaskModel>> getAllTasks() async {
    return _tasksBox.values.toList();
  }

  Future<void> addTask(TaskModel task) async {
    await _tasksBox.put(task.id, task);
  }

  Future<void> updateTask(TaskModel task) async {
    await _tasksBox.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _tasksBox.delete(id);
  }

  Future<void> reorderTasks(List<TaskModel> tasks) async {
    await _tasksBox.clear();
    await _tasksBox.putAll({for (var task in tasks) task.id: task});
  }
}