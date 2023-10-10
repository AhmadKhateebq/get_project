import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_project/named_navigating/page_2.dart';
import 'package:get_project/named_navigating/page_3.dart';

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Page 1 + id : ${Get.parameters['id']!=null?Get.parameters : "no id given"}"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      Get.back();
                    }, icon: const Icon(Icons.arrow_back_ios_outlined)),
                IconButton(
                    onPressed: () {
                      Get.toNamed("/page2?name=Screen");
                    }, icon: const Icon(Icons.arrow_forward_ios)),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Get.offAllNamed("/page1");
        },
        child: const Text("reset"),
      ),
    );
  }
}
main() {

  runApp(GetMaterialApp(
    theme: ThemeData.dark(),
    title: "Guess Game",
    getPages: [
      GetPage(name: "/page1/:id", page: ()=>const Page1()),
      GetPage(name: "/page1/", page: ()=>const Page1()),
      GetPage(name: "/page2", page: ()=>const Page2()),
      GetPage(name: "/page3", page: ()=>const Page3()),
    ],
    routingCallback: (route){
      log(route!.current);
    },
    unknownRoute: GetPage(name: "/notFound" , page : ()=> const Page1()),
    home: const Page1(),
  ));
}

