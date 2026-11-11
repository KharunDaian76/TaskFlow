import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/todo.dart';
part 'todo_api.g.dart';

@RestApi(baseUrl: 'https://dummyjson.com')
abstract class TodoApi {
  factory TodoApi(Dio dio, {String baseUrl}) = _TodoApi;

  @GET('/todos')
  Future<TodoResponse> getTodos(@Query('limit') int limit);

  @POST('/todos/add')
  Future<Todo> addTodo(@Body() TodoRequest request);

  @PUT('/todos/{id}')
  Future<Todo> updateTodo(@Path('id') int id, @Body() TodoUpdate request);

  @DELETE('/todos/{id}')
  Future<dynamic> deleteTodo(@Path('id') int id);
}
