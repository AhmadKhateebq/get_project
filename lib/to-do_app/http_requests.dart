import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_project/to-do_app/login_page.dart';
import 'package:get_project/to-do_app/state_controller.dart';
import 'package:get_project/to-do_app/to_do_object.dart';
import 'package:http/http.dart' as http;

import 'consts.dart';

class RequestsController extends RxController {
  var todos = <ToDo>[].obs;
  RxBool isLoading = true.obs;
  String _token = "";
  Map<String, dynamic> _userCredential = {};

  fetchAllData() {
    if (todos.isEmpty) {
      http
          .get(
        Uri.parse("$firebaseUrl.json"),
      )
          .then((value) {
        Map<String, dynamic> resp = jsonDecode(value.body);
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
      await http.post(
          Uri.parse(
              "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyChQLf7QcPidBnZ5e0KNyMNmRMwx5zaoCc"),
          body: {
            "email": email,
            "password": password,
            "returnSecureToken": "true"
          }).then((value) => (_userCredential = jsonDecode(value.body)));
      // _userCredential.forEach((key, value) {print("$key - $value");});

      _token = _userCredential['idToken']!;
      return fillList();
    } catch (e) {
      // rethrow;
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    http.Response response = await http.post(
        Uri.parse(
            "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyChQLf7QcPidBnZ5e0KNyMNmRMwx5zaoCc"),
        body: {
          "email": email,
          "password": password,
          "returnSecureToken": "true"
        });
    _userCredential = jsonDecode(response.body);
    _token = _userCredential['idToken']!;
    return fillList();
  }

  Future<bool> fillList() async {
    if (!isLoading.value) {
      return true;
    }
    try {
      // print("$getFilteredUrl${_userCredential['localId']}&auth=$_token");
      http.Response value = await http.get(
        Uri.parse(
            "$firebaseUrl/${_userCredential['localId']}.json?auth=$_token"),
      );
      // print(value.body.toString());
      (jsonDecode(value.body) as Map<String, dynamic>).forEach((key, value) {
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

  Future<String> addTodo(ToDo toDo) async {
    try {
     var resp =  await http.post(Uri.parse("$firebaseUrl/${_userCredential['localId']}.json?auth=$_token"),
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
  Future<void> delete(ToDo todo) async{
    var response = await http.delete(Uri.parse("$firebaseUrl/${_userCredential['localId']}/${todo.id}.json?auth=$_token"));
    print(response.body);
  }
  bool validatePassword(String password) {
    if (password.length >= 8) {
      return true;
    } else {
      return false;
    }
  }
bool validatePasswordEmail(String password,String email){
    if(password.isEmpty && !validateEmail(email)){
      return true;
    }else{
      return validatePassword(password);
    }
}
  bool validateEmail(String email) {
    return RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
        .hasMatch(email);
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
