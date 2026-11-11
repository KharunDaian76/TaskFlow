abstract class TodoEvent {}
class LoadTodos extends TodoEvent {}
class AddTodo extends TodoEvent {
  final String text;
  AddTodo(this.text);
}
class ToggleTodo extends TodoEvent {
  final int id;
  ToggleTodo(this.id);
}
class EditTodo extends TodoEvent {
  final int id;
  final String text;
  EditTodo(this.id, this.text);
}
class DeleteTodo extends TodoEvent {
  final int id;
  DeleteTodo(this.id);
}
