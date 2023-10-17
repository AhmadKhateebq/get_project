import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_project/to-do_app/page/login_page.dart';
import 'package:get_project/to-do_app/controller/state_controller.dart';
import 'package:get_project/to-do_app/util/translation.dart';

import 'controller/requests_controller.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(TodoController());
  Get.put(RequestsController()).dio.init();
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
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
    return const SafeArea(
      child: LoginPage(),
    );
  }
}
