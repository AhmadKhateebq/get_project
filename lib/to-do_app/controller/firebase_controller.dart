// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:get_project/to-do_app/to_do_object.dart';
//
// class FirebaseController {
//   static final _database = FirebaseDatabase.instance;
//   static final _instance = FirebaseController();
//   final RxList<ToDo> _todos = <ToDo>[].obs;
//
//   FirebaseController() {
//     init();
//   }
//
//   RxList<ToDo> get todos => _todos;
//
//   init() async {
//     _todos.assignAll(await getAll());
//   }
//
//   save(ToDo todo) async {
//     try {
//       todos.add(todo);
//       _database.ref('/todo').push().set(todo.toJson());
//       if (kDebugMode) {
//         print("ToDo saved successfully.");
//       }
//     } catch (error,stackTrace) {
//       await FirebaseCrashlytics.instance.recordError(
//         error,
//         stackTrace,
//         reason: 'a non-fatal error',
//         information: ['further diagnostic information about the error', 'version 2.0'],
//       );
//       if (kDebugMode) {
//         print("Error saving ToDo: $error");
//       }
//     }
//   }
//
//   Future<List<ToDo>> getAll() async {
//     final DataSnapshot snapshot = await _database.ref().child('todo').get();
//     Map<dynamic, dynamic> dataMap = snapshot.value as Map<dynamic, dynamic>;
//     return dataMap.entries.map((e) {
//       final todoMap = e.value as Map<dynamic, dynamic>;
//       return ToDo(
//           id: e.key.toString(),
//           date: DateTime.parse(todoMap['date'] as String),
//           name: todoMap['name'] as String);
//     }).toList();
//   }
//
//   static FirebaseController getRef() => _instance;
// }
