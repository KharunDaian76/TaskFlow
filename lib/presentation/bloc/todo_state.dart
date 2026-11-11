import '../../data/models/todo.dart';

class TodoState {
  final List<Todo> todos;
  final bool loading;
  final bool busy;
  final String? error;
  final int messageId;

  const TodoState({
    this.todos = const [],
    this.loading = false,
    this.busy = false,
    this.error,
    this.messageId = 0,
  });

  TodoState copyWith({List<Todo>? todos, bool? loading, bool? busy, String? error}) {
    return TodoState(
      todos: todos ?? this.todos,
      loading: loading ?? this.loading,
      busy: busy ?? this.busy,
      error: error,
      messageId: error == null ? messageId : messageId + 1,
    );
  }
}
