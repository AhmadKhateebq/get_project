import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_project/to-do_app/to_do_object.dart';
import 'package:get_storage/get_storage.dart';

import '../firebase_options.dart';
import 'firebase_controller.dart';

class TodoController extends GetxController with StateMixin {
  var darkMode = Get.isDarkMode.obs;
  final storage = GetStorage();
  late final FirebaseController database ;
  var locale = Get.deviceLocale.obs;
  late FirebaseAnalytics analytics ;
  var loading = true.obs;
  bool started = false;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  restoreData() async {
    locale.value = Locale(
        storage.read('locale')); // null check for first time running this
    Get.changeTheme(ThemeData.dark());
    await database.init();
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
    TextEditingController textController = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Todo'),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Todo Name',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final date = await showDate() ?? DateTime.now();
                final name = textController.text;
                database.save(ToDo(date: date, name: name));
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
    );
  }
  RxBool isLoading(){

    if(!started) {
      started = true;
      init();
    }
    return loading;
  }
  get darkIcon => darkMode.value ? Icons.light : Icons.light_outlined;

  get modeIcon => darkMode.value ? Icons.dark_mode : Icons.light_mode;

  get color => !darkMode.value ? Colors.deepPurple[600] : Colors.blueGrey;

  void changeTheme() {
    darkMode.value = !darkMode.value;
    Get.changeTheme(Get.isDarkMode ? ThemeData.light() : ThemeData.dark());
  }

  changeLanguage(String? val) async {
    await storage.write("locale", val);
    storage.save();
    locale.value = Locale(val!);
    Get.updateLocale(Locale(val));
    scaffoldKey.currentState?.closeDrawer();
  }

  log([String? message]) async {
    if(message != null){
      await analytics
          .logEvent(name: message);
    }else{
      await analytics
          .logEvent(name: "pressed on list tile", parameters: {'key': 'value'});
      await FirebaseAnalytics.instance.logBeginCheckout(
          value: 10.0,
          currency: 'USD',
          items: [
            AnalyticsEventItem(itemName: 'Socks', itemId: 'xjw73nano', price: 10),
          ],
          coupon: '10PERCENT-OFF');
    }

  }

  error()async {
    if (locale.value?.languageCode == ('ar')) {
      throw Exception();
    }
    if (kDebugMode) {
      try {
        double i = double.parse("num");
        print(i);
      } catch (error, stackTrace) {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'parser error',
          information: ['double parse a non number', 'more info'],
        );
        if (kDebugMode) {
          print("Error saving ToDo: $error");
        }
      }
    }
  }

  init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.android,
    );
    await errorInit();
    await GetStorage.init();
    Get.find<TodoController>().change(RxStatus.success());
    FirebaseController.getRef();
    analytics =  FirebaseAnalytics.instance;
    loading.value = false;
    log("init finished");
  }
  errorInit() async {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
}
