import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_project/to-do_app/splash.dart';
import 'package:get_project/to-do_app/state_controller.dart';
import 'package:get_project/to-do_app/translation.dart';

import 'home_widget.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(TodoController());
  runApp(GetMaterialApp(
      translations: TodoTranslations(),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en'),
      home: const MainPage()));
  // runApp(const MainPage());
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TodoController>(
      builder: (_) => SafeArea(
        child: Get.find<TodoController>().isLoading().value
            ? const SplashScreen()
            : const HomePage(),
      ),
    );
  }

}
