import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_project/to-do_app/firebase_controller.dart';
import 'package:get_project/to-do_app/list_view_body.dart';
import 'package:get_project/to-do_app/to_do_object.dart';
import 'package:get_storage/get_storage.dart';

import '../firebase_options.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );
  await GetStorage.init();
  runApp(const HomePage());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var darkMode = Get.isDarkMode.obs;
  final storage = GetStorage();
  final database = FirebaseController.getRef();
  var locale = Get.deviceLocale.obs;

  // static final _otherBox = () => GetStorage('MyPref');
  @override
  void initState() {
    _restoreData();

    super.initState();
  }

  _restoreData() async {
    locale.value = Locale(
        storage.read('locale')); // null check for first time running this
    Get.changeTheme(ThemeData.dark());
    await database.init();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: Messages(),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      locale: locale.value,
      fallbackLocale: const Locale('en'),
      home: SafeArea(
        minimum: const EdgeInsets.fromLTRB(0, 40, 0, 0),
        child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            actions: [
              Obx(
                () => Icon(
                  darkMode.value ? Icons.light : Icons.light_outlined,
                ),
              )
            ],
            title: Text(
              'title'.tr,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          drawer: Drawer(
              width: context.width * (3 / 4),
              child: ListView(
                // padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                children: [
                  Obx(
                    () => Container(
                      color: !darkMode.value
                          ? Colors.deepPurple[600]
                          : Colors.blueGrey,
                      height: context.height * (1 / 4),
                      // child: Image.asset("assets/img.png"),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: Image(
                                  image: AssetImage('assets/flutter.png'),
                                  width: 100,
                                )),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Text(
                                "menu".tr,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListTile(
                    title: Text("add".tr),
                    leading: const Icon(Icons.add),
                    onTap: () async {
                      showAddTodoOverlay();
                    },
                  ),
                  Obx(
                    () => ListTile(
                      title: Text("theme".tr),
                      onTap: () {
                        darkMode.value = !darkMode.value;
                        Get.changeTheme(Get.isDarkMode
                            ? ThemeData.light()
                            : ThemeData.dark());
                      },
                      leading: Icon(
                        darkMode.value ? Icons.dark_mode : Icons.light_mode,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListTile(
                    title: Text("language".tr),
                    leading: const Icon(Icons.translate),
                    trailing: DropdownMenu(
                      dropdownMenuEntries: [
                        DropdownMenuEntry(value: 'en', label: 'English'.tr),
                        DropdownMenuEntry(value: 'ar', label: 'Arabic'.tr),
                      ],
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      hintText: "default_language".tr,
                      initialSelection: 'English',
                      onSelected: (val) async => {
                        await storage.write("locale", val),
                        storage.save(),
                        locale.value = Locale(val!),
                        Get.updateLocale(Locale(val)),
                        scaffoldKey.currentState?.closeDrawer(),
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: Text("more".tr),
                    onTap: () {
                      if (kDebugMode) {
                        print("go to about us screen");
                        print(Get.locale);
                        print(Get.deviceLocale);
                      }
                      showDate();
                    },
                  )
                ],
              )),
          body: Center(
            child: Obx(() => ListViewBody(
                  locale: locale.value!.languageCode,
                )),
          ),
        ),
      ),
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
                final date = await showDate()??DateTime.now();
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

  Future<DateTime?> showDate()  async {
    return showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
      locale: locale.value,
    );
  }
}

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': {
          'title': 'To-Do App',
          'language': 'Language',
          'Arabic': 'العربية',
          'English': 'English',
          'menu': 'Main Menu',
          'theme': 'Change Theme',
          'more': 'about us',
          'add': 'add a todo',
          'default_language': 'English',
        },
        'ar': {
          'title': 'المفكرة',
          'language': 'اللغة',
          'English': "English",
          'Arabic': "العربيه",
          'menu': "القائمه الرئيسيه",
          'theme': "واجهة التطبيق",
          'more': "المزيد عنا",
          'add': "اضف مهمه",
          'default_language': "العربيه",
        }
      };
}
