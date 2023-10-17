import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:cancellation_token_http/http.dart' as http;
import 'package:flutter/cupertino.dart';
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
  int anchor = -1;
  bool pageLock = false;
  var pageEnd = false;
  final _scrollController = ScrollController();

  void _setupScrollController() {
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _scrollListener() async {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent) {
      if (!pageLock) {
        await printBy();
      }
      if (pageEnd) {
        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent - 50,
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn);
      }
    }
  }

  ScrollController get scrollController {
    _setupScrollController();
    return _scrollController;
  }

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

  printBy() async {
    pageLock = true;
    int entries = 10;
    await fetchDataByPage(entries: entries, anchorCID: anchor);
    pageLock = false;
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
      // return fillList();
      await printBy();
      return true;
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
    // return fillList();
    await printBy();
    return true;
  }

  Future<bool> fillList() async {
    if (!isLoading.value) {
      return true;
    }
    try {
      // print("$getFilteredUrl${_userCredential['localId']}&auth=$_token");
      var value = await dio.get(
          "$firebaseUrl/${_userCredential['localId']}.json?",
          queryParameters: {"auth": _token, "orderBy": "\"cid\""});
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
      return true;
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

  fetchDataByPage({int? anchorCID, required int entries}) async {
    print(anchorCID);
    final response = await dio.get(
      "$firebaseUrl/${_userCredential['localId']}.json",
      queryParameters: {
        "auth": _token,
        "orderBy": "\"cid\"",
        anchorCID != null ? "startAfter" : "": "${anchorCID ?? ""}",
        "limitToFirst": "$entries"
      },
    );
    try {
      final Map<String, dynamic> map = jsonDecode(response.toString());
      map.forEach((key, value) {
        todos.add(ToDo(
            date: DateTime.parse(value['date']),
            name: value['name'],
            id: key,
            cid: value['cid']));
      });
      anchor = todos.last.cid!;
      return true;
    } catch (e) {
      print("eeee");
      pageEnd = true;
      return 0;
    }
  }

  Future<int> getCounter() async {
    var resp = (await dio.get(
        "https://to-do-app-quiz-plus-task-default-rtdb.europe-west1.firebasedatabase.app/counter.json"));
    return (jsonDecode(resp.toString())["counter"]);
  }

  Future<int> get counter async {
    int c = await getCounter();
    print(c);
    await dio.put(counterString, data: {
      "counter": c + 1,
    });
    return c;
  }

  Future<String> addTodo(ToDo toDo) async {
    int c = await counter;
    try {
      var date = toDo.date;
      var resp = await http.post(
          Uri.parse(
              "$firebaseUrl/${_userCredential['localId']}.json?auth=$_token"),
          headers: {
            "Accept": "*/*",
            "Content-Type": "application/json; charset=utf-8",
            "dataType": "json",
          },
          body: jsonEncode({
            "date": "${date.year}-${date.month}-${date.day}",
            "name": toDo.name,
            "cid": c,
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
