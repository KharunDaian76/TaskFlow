import 'package:json_annotation/json_annotation.dart';
part 'todo.g.dart';

@JsonSerializable()
class Todo {
  final int id;
  final String todo;
  final bool completed;
  final int userId;

  const Todo({required this.id, required this.todo, required this.completed, required this.userId});

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
  Map<String, dynamic> toJson() => _$TodoToJson(this);

  Todo copyWith({String? todo, bool? completed}) => Todo(
    id: id,
    todo: todo ?? this.todo,
    completed: completed ?? this.completed,
    userId: userId,
  );
}

@JsonSerializable()
class TodoResponse {
  final List<Todo> todos;
  const TodoResponse({required this.todos});
  factory TodoResponse.fromJson(Map<String, dynamic> json) => _$TodoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TodoResponseToJson(this);
}

@JsonSerializable()
class TodoRequest {
  final String todo;
  final bool completed;
  final int userId;
  const TodoRequest({required this.todo, required this.completed, required this.userId});
  factory TodoRequest.fromJson(Map<String, dynamic> json) => _$TodoRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TodoRequestToJson(this);
}

@JsonSerializable()
class TodoUpdate {
  final String? todo;
  final bool? completed;
  const TodoUpdate({this.todo, this.completed});
  factory TodoUpdate.fromJson(Map<String, dynamic> json) => _$TodoUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$TodoUpdateToJson(this);
}
