import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:cancellation_token_http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get_project/to-do_app/login_page.dart';
import 'package:get_project/to-do_app/state_controller.dart';
import 'package:get_project/to-do_app/to_do_object.dart';

import 'consts.dart';

class RequestsController extends RxController {
  final dio = Dio();
  var todos = <ToDo>[].obs;
  RxBool isLoading = true.obs;
  String _token = "";
  Map<String, dynamic> _userCredential = {};
  static String finalSearch = "";
  late ToDo latest;
  static int i = 0;
  var token = CancelToken();
  bool finished = false;

  fetchAllData() {
    if (todos.isEmpty) {
      dio
          .get(
        ("$firebaseUrl.json"),
      )
          .then((value) {
        Map<String, dynamic> resp = jsonDecode(value.toString());
        List<ToDo> todos = [];
        resp.forEach((key, value) {
          todos.add(ToDo.fromJson(key, value));
        });
        this.todos.value = todos;
      });
    }
    return todos;
  }

  Future<bool> signIn(String email, String password) async {
    try {
      await dio.post(
          ("https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword"),
          queryParameters: {
            "key": "AIzaSyChQLf7QcPidBnZ5e0KNyMNmRMwx5zaoCc"
          },
          data: {
            "email": email,
            "password": password,
            "returnSecureToken": "true"
          }).then((value) {
        print(value);
        _userCredential = jsonDecode(value.toString());
      });
      // _userCredential.forEach((key, value) {print("$key - $value");});

      _token = _userCredential['idToken']!;
      return fillList();
    } catch (e) {
      // rethrow;
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    var response = await dio.post(
        ("https://identitytoolkit.googleapis.com/v1/accounts:signUp"),
        queryParameters: {
          "key": "AIzaSyChQLf7QcPidBnZ5e0KNyMNmRMwx5zaoCc"
        },
        data: {
          "email": email,
          "password": password,
          "returnSecureToken": "true"
        });
    _userCredential = jsonDecode(response.data);
    _token = _userCredential['idToken']!;
    return fillList();
  }

  Future<bool> fillList() async {
    if (!isLoading.value) {
      return true;
    }
    try {
      // print("$getFilteredUrl${_userCredential['localId']}&auth=$_token");
      var value = await dio.get(
          "$firebaseUrl/${_userCredential['localId']}.json?",
          queryParameters: {"auth": _token});
      // print(value.body.toString());
      (jsonDecode(value.toString()) as Map<String, dynamic>)
          .forEach((key, value) {
        // if(value['userId'] == _userCredential['localId']){
        todos.add(ToDo(
            date: DateTime.parse(value['date']), name: value['name'], id: key));
        // }
      });
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> search(String value) async {
    if (value == finalSearch) {
      return latest.toString();
    }
    token.cancel("cancelled");
    token = CancelToken();
    finished = false;
    log(value, name: "${i++} SEARCH TERM");
    try {
      final response = await dio.get(
        "$firebaseUrl/${_userCredential['localId']}.json",
        queryParameters: {
          "auth": _token,
          "orderBy": "\"name\"",
          "startAt": "\"$value\""
        },
        cancelToken: token,
      );
      if (finished) {
        token.cancel("cancelled");
        return "-null";
      }
      finished = true;
      final Map<String, dynamic> map = jsonDecode(response.toString());
      log("${map.values.first['name']}", name: "FINISHED");
      finalSearch = value;
      latest = ToDo(
          date: DateTime.parse(map.values.first['date']),
          name: map.values.first['name'],
          id: map.values.first['id']);
      return (map.values.first['name']);
    } on DioException {
      log("CANCELED", name: "SEARCH RESULT FOR $value");
      log("CANCELED REQUEST", name: "NETWORK");
      return "-null";
    }
  }

  Future<String> addTodo(ToDo toDo) async {
    try {
      var resp = await http.post(
          Uri.parse(
              "$firebaseUrl/${_userCredential['localId']}.json?auth=$_token"),
          headers: {
            "Accept": "*/*",
            "Content-Type": "application/json; charset=utf-8",
            "dataType": "json",
          },
          body: jsonEncode({
            "date": toDo.date.toString(),
            "name": toDo.name,
          }));
      return jsonDecode(resp.body)["name"];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(ToDo todo) async {
    var response = await http.delete(Uri.parse(
        "$firebaseUrl/${_userCredential['localId']}/${todo.id}.json?auth=$_token"));
    print(response.body);
  }

  bool validatePassword(String password) {
    if (password.length >= 8) {
      return true;
    } else {
      return false;
    }
  }

  bool validatePasswordEmail(String password, String email) {
    if (password.isEmpty && !validateEmail(email)) {
      return true;
    } else {
      return validatePassword(password);
    }
  }

  bool validateEmail(String email) {
    return RegExp(r'^.+@[a-zA-Z]+\.[a-zA-Z]+(\.?[a-zA-Z]+)$').hasMatch(email);
  }

  void logout() {
    _token = "";
    todos.value = [];
    _userCredential = {};
    Get.find<TodoController>().loading.value = true;
    Get.find<TodoController>().started = false;
    Get.offAll(() => const LoginPage());
  }
}
