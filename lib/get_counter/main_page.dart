import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_project/get_class.dart';
import 'package:get_storage/get_storage.dart';

import 'counter_controller.dart';

main() async {

  await GetStorage.init("counter_app");
  log(name : "GETX","GetStorage has been initialized");
  runApp(GetMaterialApp(
    home: Home(),
    theme: setDarkMode(GetStorage("counter_app")),
    translations: Messages(),
    locale: const Locale("en_US"),
  ));
}
setDarkMode(GetStorage box){
  if (box.read("dark_mode") != null) {
    return ((box.read("dark_mode") == 'true') ? ThemeData.dark() : ThemeData.light());
  }
  return ThemeData.light();
}

class Home extends StatelessWidget {
  final box = GetStorage("counter_app");

  Home({super.key});

  @override
  Widget build(context) {
    RxBool isDarkMode = (Get.isDarkMode).obs;
    final Controller c = Get.put(Controller());
    return Scaffold(
        appBar: AppBar(title: Obx(() => Text("Clicks: ${c.count}"))),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('hello'.tr),
              ElevatedButton(
                  child: const Text("Go to Other"),
                  onPressed: () => Get.to(()=> Other())),
              ObxValue(
                (data) => Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Switch(
                        value: isDarkMode.value,
                        onChanged: (val) {
                          isDarkMode.value = val;
                          Get.changeTheme(Get.isDarkMode
                              ? ThemeData.light()
                              : ThemeData.dark());
                          Get.snackbar(
                              "Theme",
                              !Get.isDarkMode
                                  ? "set do dark mode"
                                  : "set to light mode",
                              animationDuration:
                                  const Duration(milliseconds: 500),
                              duration: const Duration(seconds: 1));
                          box.write("dark_mode", isDarkMode.value.toString());
                        },
                      ),
                      Icon(!isDarkMode.value ? Icons.sunny : Icons.dark_mode),
                    ],
                  ),
                ),
                false.obs,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: c.increment,
            child: const Icon(Icons.add)));
  }
  
}

class Other extends StatelessWidget {
  // You can ask Get to find a Controller that is being used by another page and redirect you to it.
  final Controller c = Get.find();

  Other({super.key});

  @override
  Widget build(context) {
    // Access the updated count variable
    return Scaffold(
      body: Center(child: Text("${c.count}")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_back_ios_outlined),
        onPressed: () {
          Get.back();
        },
      ),
    );
  }
}
