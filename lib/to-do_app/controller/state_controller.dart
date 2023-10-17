import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_project/to-do_app/controller/requests_controller.dart';
import 'package:get_project/to-do_app/data/to_do_object.dart';

// import 'package:get_project/to-do_app/to_do_object.dart';
import 'package:get_storage/get_storage.dart';

import '../../firebase_options.dart';
// import 'firebase_controller.dart';

class TodoController extends GetxController with StateMixin {
  var darkMode = Get.isDarkMode.obs;
  final storage = GetStorage();

  // late final FirebaseController database;
  var locale = Get.deviceLocale.obs;
  late FirebaseAnalytics analytics;
  var loading = true.obs;
  bool started = false;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  restoreData() async {
    Get.changeTheme(
        storage.read("dark") == true ? ThemeData.dark() : ThemeData.light());
    Get.updateLocale(Locale(storage.read('locale')));
  }

  Future<DateTime?> showDate() async {
    return showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
      locale: locale.value,
    );
  }

  void showAddTodoOverlay() {
    DateTime date = DateTime(1900);
    TextEditingController textController = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Todo'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: 'Todo Name',
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      date = await showDate() ?? DateTime.now();
                    },
                    icon: const Icon(Icons.calendar_month))
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                date = await showDate() ?? DateTime.now();
                final name = textController.text;
                var id = await Get.find<RequestsController>()
                    .addTodo(ToDo(name: name, date: date));
                Get.find<RequestsController>()
                    .filteredTodos
                    .add(ToDo(name: name, date: date, id: id.toString()));
                log("add_todo", {'name': name, 'date': date.toString()});
                Get.back(); // Close the overlay
              },
              child: const Text('Save'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
      backgroundColor: Get.isDarkMode ? Colors.black87 : Colors.white70,
    );
  }

  RxBool isLoading() {
    if (!started) {
      started = true;
      init();
    }
    return loading;
  }

  get darkIcon => darkMode.value ? Icons.light : Icons.light_outlined;

  get modeIcon => darkMode.value ? Icons.dark_mode : Icons.light_mode;

  get color => !darkMode.value ? Colors.deepPurple[600] : Colors.blueGrey;

  Future<void> changeTheme() async {
    log("change_theme", {
      'from': darkMode.value ? "dark mode" : "light mode",
      'to': !darkMode.value ? "dark mode" : "light mode",
    });
    darkMode.value = !darkMode.value;
    await storage.write("dark", darkMode.value);
    storage.save();
    Get.changeTheme(Get.isDarkMode ? ThemeData.light() : ThemeData.dark());
  }

  changeLanguage(String? val) async {
    log("changed_language", {
      'from': locale.value!.languageCode,
      'to': val!,
    });
    await storage.write("locale", val);
    storage.save();
    locale.value = Locale(val);
    Get.updateLocale(Locale(val));
    scaffoldKey.currentState?.closeDrawer();
  }

  log([String? event, Map<String, dynamic>? parameters]) async {
    if (event != null && parameters != null) {
      await analytics.logEvent(name: event, parameters: parameters);
    } else if (event != null) {
      analytics.logEvent(name: event);
    } else {
      analytics.logEvent(name: "unknown_event");
    }
  }

  error() async {
    if (kDebugMode) {
      try {
        if (locale.value?.languageCode == ('ar')) {
          throw Exception();
        }
        double i = double.parse("num");
        print(i);
      } on FormatException catch (error, stackTrace) {
        FirebaseCrashlytics.instance.log("inside catch");
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'parser error',
          information: ['double parse a non number', 'more info'],
        );
        if (kDebugMode) {
          print("Error saving ToDo: $error");
        }
        throw const FormatException();
      } on Exception catch (_) {
        print("ERROOOR");
        throw Exception();
      }
    }
  }

  init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.android,
    );
    await Get.find<RequestsController>().init();
    await errorInit();
    await Future.delayed(const Duration(seconds: 1));
    await GetStorage.init();
    Get.find<TodoController>().change(RxStatus.success());
    // database = FirebaseController.getRef();
    analytics = FirebaseAnalytics.instance;
    loading.value = false;
    await restoreData();
    // await fillLogs();
  }

  errorInit() async {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      switch (error.toString()) {
        // case 'Exception':
        //   {
        //     print("Exception 1");
        //     break;
        //   }
        case 'FormatException':
          {
            break;
          }
        default:
          {
            FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
            break;
          }
      }
      return true;
    };
  }

  fillLogs() async {
    for (int i = 0; i < 50; i++) {
      // await analytics.logEvent(name : "list_tile_pressed");
      // await analytics.logEvent(name :"list_tile_pressed");
      // await analytics.logEvent(name :"drop_down_menu_selected");
      // await analytics.logEvent(name :"more_info_selected");
      // await analytics.logEvent(name :"error_occurred");
      // await analytics.logEvent(name :"changed_language", parameters: {
      //   'from': 'en',
      //   'to': 'ar',
      // });
      // await analytics.logEvent(name :"change_theme", parameters :
      //     {
      //   'from': "light mode",
      //   'to': "dark mode",
      // });

      await log("item_deleted");
      await log("item_deleted");
      await log("item_deleted");
      await log("item_deleted");
    }
  }
}
