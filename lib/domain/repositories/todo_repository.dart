import '../../data/models/todo.dart';

abstract class TodoRepository {
  Future<List<Todo>> getTodos();
  Future<Todo> addTodo(String text);
  Future<Todo> updateTodo(int id, {String? text, bool? completed});
  Future<void> deleteTodo(int id);
}
