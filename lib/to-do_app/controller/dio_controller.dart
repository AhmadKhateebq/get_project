import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get_project/to-do_app/util/login_interceptor.dart';

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
  static bool isInit = false;
  static get instance => dio;
  init(){
    if(!isInit){
      // addInterceptor(LogInterceptor());
      addInterceptor(LoginInterceptor());
      isInit = true;
    }
  }
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }
  fetchAll() async {
    await _dio
        .get(
      (".json"),
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
      {required localId, anchorCID, required entries}) async {
    return await _dio.get(
      "/todo/$localId.json",
      queryParameters: {
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
        "/counter.json"));
    return (jsonDecode(resp.toString())["counter"]);
  }

  Future<String> addTodo({
    required localId,
    required toDo,
  }) async {
    int c = await counter;
    try {
      var date = toDo.date;
      var resp = await _dio.post("/todo/$localId.json?",
          data: jsonEncode({
            "date": "${date.year}-${date.month}-${date.day}",
            "name": toDo.name,
            "cid": c,
          }));
      return jsonDecode(resp.toString())["name"];
    } catch (e) {
      rethrow;
    }
  }

  deleteTodo({
    required localId,
    required todo,
  }) async {
    return await _dio
        .put(("/todo/$localId/${todo.id}.json"), data: {
      "name": todo.name,
      "cid": -9,
      "date": "${todo.date.year}-${todo.date.month}-${todo.date.day}"
    });
  }

  search({
    required localId,
    required value,
    required cancelToken,
  }) async {
    return await _dio.get(
      "/todo/$localId.json",
      queryParameters: {
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
        ("$loginUrl${register ? "signUp" : "signInWithPassword"}"),
        queryParameters: {
          "key" : key
        },
        data: {
          "email": email,
          "password": password,
          "returnSecureToken": "true"
        });
    return jsonDecode(resp.toString());
  }
}
