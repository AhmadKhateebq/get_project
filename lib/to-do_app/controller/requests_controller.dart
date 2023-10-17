import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_project/to-do_app/controller/dio_controller.dart';
import 'package:get_project/to-do_app/controller/state_controller.dart';
import 'package:get_project/to-do_app/data/to_do_object.dart';
import 'package:get_project/to-do_app/page/login_page.dart';

class RequestsController extends RxController {
  final DioRequests dio = DioRequests.instance;
  var filteredTodos = <ToDo>[].obs;
  RxBool isLoading = true.obs;
  String _token = "";
  Map<String, dynamic> _userCredential = {};
  static String finalSearch = "";
  late List<ToDo> latest;
  static int i = 0;
  var token = CancelToken();
  bool finished = false;
  int anchor = -1;
  var pageLock = false.obs;
  var pageEnd = false.obs;
  List<ToDo> data = [];

  init() {}

  fetchAllData() {
    if (filteredTodos.isEmpty) {
      filteredTodos.value = dio.fetchAll();
    }
    return filteredTodos;
  }

  printBy({bool? reset = false}) async {
    pageLock.value = true;
    int entries = 10;
    await fetchDataByPage(entries: entries, anchorCID: anchor, reset: reset);
    data = filteredTodos;
    pageLock.value = false;
  }

  empty() async {
    pageLock.value = true;
    filteredTodos.value = [];
    data = filteredTodos;
    pageEnd.value = false;
    anchor = -1;
    await printBy(reset: true);
    pageLock.value = false;
  }

  emptyAfterSearch() async {
    pageLock.value = true;
    filteredTodos.value = data;
    pageLock.value = false;
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _userCredential = await dio.loginAndRegister(
          email: email, password: password, register: false);
      _token = _userCredential['idToken']!;
      await printBy();
      return true;
    } catch (e) {
      // rethrow;
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      _userCredential = await dio.loginAndRegister(
          email: email, password: password, register: true);
      _token = _userCredential['idToken']!;
      await printBy();
      return true;
    } catch (e) {
      // rethrow;
      return false;
    }
  }

  Future<List<ToDo>> search(String value) async {
    if (value == "" || value.isEmpty) {
      filteredTodos.value = data;
    }
    if (value == finalSearch) {
      return latest;
    }
    token.cancel("cancelled");
    token = CancelToken();
    finished = false;
    log(value, name: "${i++} SEARCH TERM");
    try {
      final response = await dio.search(
          localId: _userCredential['localId'],
          token: _token,
          value: value,
          cancelToken: token);
      log("${response.statusCode}", name: "CODE ");
      if (finished) {
        token.cancel("cancelled");
        return [];
      }
      finished = true;
      final Map<String, dynamic> map = jsonDecode(response.toString());
      log("${map.values.first['name']}", name: "FINISHED");
      finalSearch = value;
      List<ToDo> results = [];
      map.forEach((key, value) {
        results.add(ToDo(
            date: DateTime.parse(value['date']),
            name: value['name'],
            id: key,
            cid: value['cid']));
      });
      latest = results;
      filteredTodos.value = results;
      return results;
    } on DioException catch (e, s) {
      log("$e", name: "ERROR");
      log("$s", name: "ERROR");
      log("CANCELED", name: "SEARCH RESULT FOR $value");
      log("CANCELED REQUEST", name: "NETWORK");
      return [];
    }
  }

  fetchDataByPage(
      {int? anchorCID, required int entries, bool? reset = false}) async {
    final response = await dio.fetchFiltered(
        localId: _userCredential['localId'],
        token: _token,
        entries: entries,
        anchorCID: anchorCID);
    try {
      if (reset!) {
        List<ToDo> resetData = List.of(data);
        final Map<String, dynamic> map = jsonDecode(response.toString());
        map.forEach((key, value) {
          if (value["cid"] != -9) {
            resetData.add(ToDo(
                date: DateTime.parse(value['date']),
                name: value['name'],
                id: key,
                cid: value['cid']));
          }
        });
        data = resetData;
        anchor = resetData.last.cid!;
        filteredTodos.value = resetData;
        return true;
      } else {
        final Map<String, dynamic> map = jsonDecode(response.toString());
        map.forEach((key, value) {
          if (value["cid"] != -9) {
            filteredTodos.add(ToDo(
                date: DateTime.parse(value['date']),
                name: value['name'],
                id: key,
                cid: value['cid']));
          }
        });
        data = filteredTodos;
        anchor = filteredTodos.last.cid!;
        return true;
      }
    } catch (e) {
      pageEnd.value = true;
      return 0;
    }
  }

  Future<String> addTodo(ToDo toDo) async {
    return await dio.addTodo(
      localId: _userCredential['localId'],
      token: _token,
      toDo: toDo,
    );
  }

  Future<void> delete(ToDo todo) async {
    var response = await dio.deleteTodo(
        localId: _userCredential['localId'], token: _token, todo: todo);
    empty();
    log(response.data.toString());
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
    filteredTodos.value = [];
    _userCredential = {};
    Get.find<TodoController>().loading.value = true;
    Get.find<TodoController>().started = false;
    Get.offAll(() => const LoginPage());
  }

  void cancelRequest() {
    token.cancel("cancelled");
    token = CancelToken();
  }
}
