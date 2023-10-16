import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_project/to-do_app/state_controller.dart';
import 'package:get_project/to-do_app/to_do_object.dart';
import 'package:intl/intl.dart';

import 'debouncer_class.dart';
import 'http_requests.dart';

class ListViewBody extends StatelessWidget {
  const ListViewBody({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    final debouncer = Debouncer(milliseconds: 300);
    List<ToDo> list = Get.find<RequestsController>().todos;
    final searchController = TextEditingController();
    // final textFieldKey = GlobalKey<EditableTextState>();
    Get.find<TodoController>().log("main_screen_entered");
    return Obx(() => Column(
          children: [
            TextField(
              // key: textFieldKey,
              decoration: const InputDecoration(
                floatingLabelStyle: TextStyle(color: Colors.deepPurple),
                // border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                ),
                labelText: "search",
                labelStyle: TextStyle(color: Colors.black87),
              ),
              controller: searchController,
              onChanged: (val) {
                debouncer.run(() async {
                  print(val);
                  String text =
                      await Get.find<RequestsController>().search(val);
                  if (text != "-null") {
                    if (text.contains(val)) {
                      log(text, name: "SEARCH RESULTS");
                    } else {
                      searchController.text = "couldnt find";
                      log("COULDNT FIND ANY", name: "SEARCH RESULTS");
                    }
                  } else {}
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          Get.find<TodoController>()
                              .log("item_deleted", {'index': index});
                          await Get.find<RequestsController>()
                              .delete(list[index]);
                          list.removeAt(index);
                        },
                      ),
                      title: Text(parsNumbers(list[index].name, (locale))),
                      subtitle: Text(
                          DateFormat.yMMMd(locale).format(list[index].date)),
                    );
                  }),
            ),
          ],
        ));
  }

  parsNumbers(String string, String locale) {
    // if(locale == 'en'){
    //   return arabicToEnglish(NumberFormat("###,###.##", locale)
    //       .format(double.parse(string)));
    // }
    // else
    if (locale == 'ar') {
      return englishToArabic(string);
    }
    return string;
  }

  englishToArabic(String string) {
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < string.length; i++) {
      sb.write(arabicDigits[string[i]] ?? string[i]);
    }
    return sb.toString();
  }

  arabicToEnglish(String string) {
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < string.length; i++) {
      sb.write(englishDigits[string[i]] ?? string[i]);
    }
    return sb.toString();
  }

  static const Map<String, String> arabicDigits = <String, String>{
    '0': '\u0660',
    '1': '\u0661',
    '2': '\u0662',
    '3': '\u0663',
    '4': '\u0664',
    '5': '\u0665',
    '6': '\u0666',
    '7': '\u0667',
    '8': '\u0668',
    '9': '\u0669',
  };
  static const Map<String, String> englishDigits = <String, String>{
    '\u0660': '0',
    '\u0661': '1',
    '\u0662': '2',
    '\u0663': '3',
    '\u0664': '4',
    '\u0665': '5',
    '\u0666': '6',
    '\u0667': '7',
    '\u0668': '8',
    '\u0669': '9',
  };
}
