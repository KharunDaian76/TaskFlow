import '../../domain/repositories/todo_repository.dart';
import '../api/todo_api.dart';
import '../models/todo.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoApi api;
  TodoRepositoryImpl(this.api);

  @override
  Future<List<Todo>> getTodos() async => (await api.getTodos(30)).todos;

  @override
  Future<Todo> addTodo(String text) async =>
      api.addTodo(TodoRequest(todo: text, completed: false, userId: 1));

  @override
  Future<Todo> updateTodo(int id, {String? text, bool? completed}) async =>
      api.updateTodo(id, TodoUpdate(todo: text, completed: completed));

  @override
  Future<void> deleteTodo(int id) async { await api.deleteTodo(id); }
}
