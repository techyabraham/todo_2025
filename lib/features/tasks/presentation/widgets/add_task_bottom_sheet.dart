import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:todo_2025/features/tasks/data/models/task_model.dart';
import 'package:todo_2025/features/tasks/presentation/controllers/task_provider.dart';

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  final TaskModel? taskToEdit;

  const AddTaskBottomSheet({super.key, this.taskToEdit});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  Priority _priority = Priority.medium;
  Category _category = Category.personal;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _dueDate = task?.dueDate;
    _priority = task?.priority ?? Priority.medium;
    _category = task?.category ?? Category.personal;
    _isCompleted = task?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.taskToEdit == null ? 'Add Task' : 'Edit Task',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildDatePicker(context),
                const SizedBox(height: 16),
                _buildPrioritySelector(),
                const SizedBox(height: 16),
                _buildCategorySelector(),
                if (widget.taskToEdit != null) ...[
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Completed'),
                    value: _isCompleted,
                    onChanged: (value) {
                      setState(() {
                        _isCompleted = value ?? false;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _submitForm,
                        child: Text(widget.taskToEdit == null ? 'Add Task' : 'Update Task'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: _dueDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              
              if (selectedDate != null) {
                setState(() {
                  _dueDate = selectedDate;
                });
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dueDate == null 
                    ? 'Select due date' 
                    : DateFormat('MMM dd, yyyy').format(_dueDate!),
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        if (_dueDate != null) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _dueDate = null;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Priority'),
        const SizedBox(height: 8),
        SegmentedButton<Priority>(
          segments: const [
            ButtonSegment(
              value: Priority.low,
              label: Text('Low'),
              icon: Icon(Icons.arrow_downward),
            ),
            ButtonSegment(
              value: Priority.medium,
              label: Text('Medium'),
              icon: Icon(Icons.horizontal_rule),
            ),
            ButtonSegment(
              value: Priority.high,
              label: Text('High'),
              icon: Icon(Icons.arrow_upward),
            ),
          ],
          selected: {_priority},
          onSelectionChanged: (Set<Priority> newSelection) {
            setState(() {
              _priority = newSelection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: Category.values.map((category) {
            return FilterChip(
              label: Text(category.toString().split('.').last),
              selected: _category == category,
              onSelected: (selected) {
                setState(() {
                  _category = category;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final task = TaskModel(
        id: widget.taskToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        dueDate: _dueDate,
        priority: _priority,
        category: _category,
        isCompleted: _isCompleted,
      );
      
      if (widget.taskToEdit == null) {
        ref.read(taskProvider.notifier).addTask(task);
      } else {
        ref.read(taskProvider.notifier).updateTask(task);
      }
      
      Navigator.pop(context);
    }
  }
}