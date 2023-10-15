import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_project/to-do_app/state_controller.dart';

import 'http_requests.dart';
import 'list_view_body.dart';

class HomePage extends GetView<TodoController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: controller.scaffoldKey,
        appBar: AppBar(
          backgroundColor: controller.color,
          actions: [
            Obx(
              () => Icon(controller.darkIcon),
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
              children: [
                Obx(
                  () => Container(
                    color: controller.color,
                    height: context.height * (1 / 4),
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
                    controller.log("list_tile_pressed");
                    controller.showAddTodoOverlay();
                  },
                ),
                Obx(
                  () => ListTile(
                    title: Text("theme".tr),
                    onTap: () {
                      controller.log("list_tile_pressed");
                      controller.changeTheme();
                    },
                    leading: Icon(controller.modeIcon),
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
                      controller.log("drop_down_menu_selected"),
                      controller.changeLanguage(val),
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text("more".tr),
                  onTap: () async {
                    controller.log("more_info_selected");
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                  ),
                  title: Text("crash".tr),
                  onTap: () async {
                    controller.log("error_occurred");
                    controller.error();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                  title: Text("logout".tr),
                  onTap: () async {
                    Get.find<RequestsController>().logout();
                  },
                )
              ],
            )),
        body: Center(
          child: Obx(() => ListViewBody(
                locale: controller.locale.value!.languageCode,
              )),
        ),
      ),
    );
  }
}
