import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/todo_repository.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository repository;
  TodoBloc(this.repository) : super(const TodoState()) {
    on<LoadTodos>((event, emit) async {
      emit(state.copyWith(loading: true));
      try {
        final todos = await repository.getTodos();
        emit(state.copyWith(todos: todos, loading: false));
      } catch (_) {
        emit(state.copyWith(loading: false, error: 'Could not load tasks'));
      }
    });
    on<AddTodo>((event, emit) async {
      if (state.busy) return;
      emit(state.copyWith(busy: true));
      try {
        final todo = await repository.addTodo(event.text);
        emit(state.copyWith(todos: [todo, ...state.todos], busy: false));
      } catch (_) {
        emit(state.copyWith(busy: false, error: 'Could not add task'));
      }
    });
    on<ToggleTodo>((event, emit) async {
      if (state.busy) return;
      final index = state.todos.indexWhere((t) => t.id == event.id);
      if (index == -1) return;
      final old = state.todos[index];
      emit(state.copyWith(busy: true));
      try {
        if (old.id <= 254) await repository.updateTodo(old.id, completed: !old.completed);
        final updated = [...state.todos];
        updated[index] = old.copyWith(completed: !old.completed);
        emit(state.copyWith(todos: updated, busy: false));
      } catch (_) {
        emit(state.copyWith(busy: false, error: 'Could not update task'));
      }
    });
    on<EditTodo>((event, emit) async {
      if (state.busy) return;
      final index = state.todos.indexWhere((t) => t.id == event.id);
      if (index == -1) return;
      emit(state.copyWith(busy: true));
      try {
        if (event.id <= 254) await repository.updateTodo(event.id, text: event.text);
        final updated = [...state.todos];
        updated[index] = updated[index].copyWith(todo: event.text);
        emit(state.copyWith(todos: updated, busy: false));
      } catch (_) {
        emit(state.copyWith(busy: false, error: 'Could not edit task'));
      }
    });
    on<DeleteTodo>((event, emit) async {
      if (state.busy) return;
      emit(state.copyWith(busy: true));
      try {
        if (event.id <= 254) await repository.deleteTodo(event.id);
        emit(state.copyWith(todos: state.todos.where((t) => t.id != event.id).toList(), busy: false));
      } catch (_) {
        emit(state.copyWith(busy: false, error: 'Could not delete task'));
      }
    });
  }
}
