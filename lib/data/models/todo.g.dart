// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Todo _$TodoFromJson(Map<String, dynamic> json) => Todo(
  id: (json['id'] as num).toInt(),
  todo: json['todo'] as String,
  completed: json['completed'] as bool,
  userId: (json['userId'] as num).toInt(),
);

Map<String, dynamic> _$TodoToJson(Todo instance) => <String, dynamic>{
  'id': instance.id,
  'todo': instance.todo,
  'completed': instance.completed,
  'userId': instance.userId,
};

TodoResponse _$TodoResponseFromJson(Map<String, dynamic> json) => TodoResponse(
  todos: (json['todos'] as List<dynamic>)
      .map((e) => Todo.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TodoResponseToJson(TodoResponse instance) =>
    <String, dynamic>{'todos': instance.todos};

TodoRequest _$TodoRequestFromJson(Map<String, dynamic> json) => TodoRequest(
  todo: json['todo'] as String,
  completed: json['completed'] as bool,
  userId: (json['userId'] as num).toInt(),
);

Map<String, dynamic> _$TodoRequestToJson(TodoRequest instance) =>
    <String, dynamic>{
      'todo': instance.todo,
      'completed': instance.completed,
      'userId': instance.userId,
    };

TodoUpdate _$TodoUpdateFromJson(Map<String, dynamic> json) => TodoUpdate(
  todo: json['todo'] as String?,
  completed: json['completed'] as bool?,
);

Map<String, dynamic> _$TodoUpdateToJson(TodoUpdate instance) =>
    <String, dynamic>{'todo': instance.todo, 'completed': instance.completed};
