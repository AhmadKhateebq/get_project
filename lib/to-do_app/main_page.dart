import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_project/to-do_app/list_view_body.dart';
import 'package:get_storage/get_storage.dart';

main() async {
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
  var locale = Get.deviceLocale.obs;

  // static final _otherBox = () => GetStorage('MyPref');
  @override
  void initState() {
    _restoreData();
    super.initState();
  }

  void _restoreData() {
    locale.value = Locale(
        storage.read('locale')); // null check for first time running this
    Get.changeTheme(ThemeData.dark());
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
                        locale.value= Locale(val!),
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

                    },
                  )
                ],
              )),
          body: Center(
            child: Obx(
               () =>
                 ListViewBody(locale: locale.value!.languageCode,)
            ),
          ),
        ),
      ),
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
          'default_language': "العربيه",
        }
      };
}
