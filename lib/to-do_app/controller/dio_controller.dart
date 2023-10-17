import 'dart:convert';

import 'package:dio/dio.dart';

import '../util/consts.dart';
import '../data/to_do_object.dart';

class DioRequests {
  static final _dio = Dio(BaseOptions(baseUrl: firebaseBaseUrl, headers: {
    "Accept": "application/json",
    "Content-Type": "application/json; charset=utf-8",
    "dataType": "json",
  }));
  static final  DioRequests dio = DioRequests._();
  DioRequests._();

  static get instance => dio;

  fetchAll() async {
    await _dio
        .get(
      ("$firebaseUrl.json"),
    )
        .then((value) {
      Map<String, dynamic> resp = jsonDecode(value.toString());
      List<ToDo> todos = [];
      resp.forEach((key, value) {
        todos.add(ToDo.fromJson(key, value));
      });
      return todos;
    });
  }

  fetchFiltered(
      {required localId, required token, anchorCID, required entries}) async {
    return await _dio.get(
      "$firebaseUrl/$localId.json",
      queryParameters: {
        "auth": token,
        "orderBy": "\"cid\"",
        anchorCID != null ? "startAfter" : "": "${anchorCID ?? ""}",
        "limitToFirst": "$entries"
      },
    );
  }

  Future<int> get counter async {
    int c = await getCounter();
    await _dio.put(counterString, data: {
      "counter": c + 1,
    });
    return c;
  }

  Future<int> getCounter() async {
    var resp = (await _dio.get(
        "https://to-do-app-quiz-plus-task-default-rtdb.europe-west1.firebasedatabase.app/counter.json"));
    return (jsonDecode(resp.toString())["counter"]);
  }

  addTodo({
    required localId,
    required token,
    required toDo,
  }) async {
    int c = await counter;
    try {
      var date = toDo.date;
      var resp = await _dio.post("$firebaseUrl/$localId.json?auth=$token",
          data: jsonEncode({
            "date": "${date.year}-${date.month}-${date.day}",
            "name": toDo.name,
            "cid": c,
          }));
      return jsonDecode(resp.data)["name"];
    } catch (e) {
      rethrow;
    }
  }

  deleteTodo({
    required localId,
    required token,
    required todo,
  }) async {
    return await _dio
        .put(("$firebaseUrl/$localId/${todo.id}.json?auth=$token"), data: {
      "name": todo.name,
      "cid": -9,
      "date": "${todo.date.year}-${todo.date.month}-${todo.date.day}"
    });
  }

  search({
    required localId,
    required token,
    required value,
    required cancelToken,
  }) async {
    return await _dio.get(
      "$firebaseBaseUrl/todo/$localId.json",
      queryParameters: {
        "auth": token,
        "orderBy": "\"name\"",
        "startAt": "\"$value\"",
        "limitToFirst": "10"
      },
      cancelToken: cancelToken,
    );
  }

  loginAndRegister(
      {required String email,
      required String password,
      required bool register}) async {
    var resp = await _dio.post(
        ("https://identitytoolkit.googleapis.com/v1/accounts:${register ? "signUp" : "signInWithPassword"}"),
        queryParameters: {
          "key": "AIzaSyChQLf7QcPidBnZ5e0KNyMNmRMwx5zaoCc"
        },
        data: {
          "email": email,
          "password": password,
          "returnSecureToken": "true"
        });
    return jsonDecode(resp.toString());
  }
}
