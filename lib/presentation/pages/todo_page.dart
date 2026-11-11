import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/todo.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  int filter = 0;
  String search = '';

  Future<void> openTaskDialog({Todo? task}) async {
    final bloc = context.read<TodoBloc>();
    final value = await showDialog<String>(
      context: context,
      builder: (_) => TaskDialog(initialText: task?.todo ?? ''),
    );
    if (value == null) return;
    if (task == null) {
      bloc.add(AddTodo(value));
    } else {
      bloc.add(EditTodo(task.id, value));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => context.read<TodoBloc>().add(LoadTodos()),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<TodoBloc, TodoState>(
        listenWhen: (previous, current) => previous.messageId != current.messageId,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          if (state.loading && state.todos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final total = state.todos.length;
          final completed = state.todos.where((task) => task.completed).length;
          final tasks = state.todos.where((task) {
            if (filter == 1 && task.completed) return false;
            if (filter == 2 && !task.completed) return false;
            return task.todo.toLowerCase().contains(search.toLowerCase());
          }).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Stay on track', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text('A little progress every day', style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF6556E8), Color(0xFFAA64D9)]),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your progress', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 8),
                          Text('$completed of $total tasks completed',
                              style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: total == 0 ? 0 : completed / total,
                              minHeight: 9,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      onChanged: (value) => setState(() => search = value),
                      decoration: InputDecoration(
                        hintText: 'Search tasks',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.90),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        for (var i = 0; i < 3; i++) ...[
                          ChoiceChip(
                            label: Text(['All', 'Active', 'Done'][i]),
                            selected: filter == i,
                            onSelected: (_) => setState(() => filter = i),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (state.busy || state.loading) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: tasks.isEmpty
                    ? Center(child: Text(total == 0 ? 'No tasks yet. Add your first task.' : 'No matching tasks.'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.90),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              leading: Checkbox(
                                value: task.completed,
                                onChanged: state.busy ? null : (_) => context.read<TodoBloc>().add(ToggleTodo(task.id)),
                              ),
                              title: Text(
                                task.todo,
                                style: TextStyle(
                                  decoration: task.completed ? TextDecoration.lineThrough : null,
                                  color: task.completed ? Colors.grey : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              trailing: PopupMenuButton<String>(
                                enabled: !state.busy,
                                onSelected: (action) {
                                  if (action == 'edit') openTaskDialog(task: task);
                                  if (action == 'delete') context.read<TodoBloc>().add(DeleteTodo(task.id));
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openTaskDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New task'),
      ),
    );
  }
}

class TaskDialog extends StatefulWidget {
  final String initialText;

  const TaskDialog({super.key, required this.initialText});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialText.isEmpty ? 'New task' : 'Edit task'),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 120,
        decoration: const InputDecoration(labelText: 'Task name'),
        onSubmitted: (_) => save(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: save, child: const Text('Save')),
      ],
    );
  }

  void save() {
    final value = controller.text.trim();
    if (value.isNotEmpty) Navigator.pop(context, value);
  }
}
