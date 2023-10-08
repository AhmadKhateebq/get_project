import 'package:flutter/material.dart';
import 'package:get_project/to-do_app/to_do_object.dart';
import 'package:intl/intl.dart';

class ListViewBody extends StatelessWidget {
  const ListViewBody({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    List<ToDo> list = [
      ToDo(date: DateTime.now(), name: "1213121"),
      ToDo(date: DateTime.now(), name: "211.254"),
      ToDo(date: DateTime.now(), name: "3"),
      ToDo(date: DateTime.now(), name: "4"),
      ToDo(date: DateTime.now(), name: "5"),
    ];
    return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(parsNumbers(list[index].name, (locale))),
            subtitle: Text(DateFormat.yMMMd(locale).format(DateTime.now())),
          );
        });
  }
  parsNumbers(String string,String locale){

    // if(locale == 'en'){
    //   return arabicToEnglish(NumberFormat("###,###.##", locale)
    //       .format(double.parse(string)));
    // }
    // else
      if(locale == 'ar'){
      return englishToArabic(NumberFormat("###,###.##", locale)
          .format(double.parse(string)));
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
